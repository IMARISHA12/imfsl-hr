-- ============================================================================
-- MIGRATION 013: Mali ya Kampuni — Company Assets, OCR Scanner & AI Fraud Detection
-- Date:       2026-02-16
-- Purpose:    1. Company asset inventory (vehicles, IT, office equipment, infrastructure)
--             2. Asset depreciation tracking (straight-line, declining balance)
--             3. Maintenance scheduling and history
--             4. Attachment registry with live OCR scanning (scanner + camera)
--             5. AI-powered fraud detection on attachments (forgery, tampering, duplicates)
--             6. Technology monitoring dashboard tables
--             7. RLS policies, triggers, functions, views
-- Strategy:   Idempotent — uses IF NOT EXISTS and DROP...IF EXISTS
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: COMPANY ASSET INVENTORY
-- ═══════════════════════════════════════════════════════════════════════

-- ── A1. company_assets — Central registry for ALL company-owned assets ──
CREATE TABLE IF NOT EXISTS public.company_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Classification
  asset_code text UNIQUE NOT NULL,                    -- e.g. VEH-001, IT-042, OFF-017
  asset_category text NOT NULL CHECK (asset_category IN (
    'vehicle', 'it_equipment', 'office_furniture', 'office_equipment',
    'machinery', 'building', 'land', 'software_license', 'infrastructure', 'other'
  )),
  asset_name text NOT NULL,
  description text,

  -- Financial
  purchase_price numeric(15,2) NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'TZS',
  current_book_value numeric(15,2) NOT NULL DEFAULT 0,
  salvage_value numeric(15,2) DEFAULT 0,
  depreciation_method text NOT NULL DEFAULT 'straight_line' CHECK (
    depreciation_method IN ('straight_line', 'declining_balance', 'units_of_production', 'none')
  ),
  depreciation_rate numeric(5,2) DEFAULT 0,           -- Annual % rate
  useful_life_months int DEFAULT 60,                   -- Default 5 years
  purchase_date date,
  warranty_expiry_date date,

  -- Physical
  serial_number text,
  model_number text,
  manufacturer text,
  condition text NOT NULL DEFAULT 'good' CHECK (
    condition IN ('new', 'good', 'fair', 'poor', 'damaged', 'disposed', 'under_repair')
  ),

  -- Location & Assignment
  branch_id uuid,
  department_id uuid,
  assigned_to_employee_id uuid,                        -- Current custodian
  location_description text,
  gps_latitude double precision,
  gps_longitude double precision,
  storage_room text,

  -- Vehicle-specific
  registration_number text,                            -- e.g. T 123 ABC
  engine_number text,
  chassis_number text,
  vehicle_type text,                                   -- sedan, SUV, motorcycle, truck
  fuel_type text,                                      -- petrol, diesel, electric, hybrid
  mileage_km numeric(12,2),
  insurance_policy_number text,
  insurance_expiry date,
  road_license_expiry date,

  -- IT-specific
  ip_address text,
  mac_address text,
  os_version text,
  last_patch_date date,

  -- Status & Lifecycle
  status text NOT NULL DEFAULT 'active' CHECK (
    status IN ('active', 'in_storage', 'maintenance', 'disposed', 'stolen', 'lost', 'transferred', 'auctioned')
  ),
  disposed_date date,
  disposal_method text,
  disposal_value numeric(15,2),
  disposal_approved_by uuid,

  -- Metadata
  tags text[],
  custom_fields jsonb DEFAULT '{}',
  photo_urls text[],
  qr_code_url text,

  -- Audit
  created_by uuid NOT NULL,
  updated_by uuid,
  verified_by uuid,
  verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_company_assets_category ON public.company_assets (asset_category);
CREATE INDEX IF NOT EXISTS idx_company_assets_status ON public.company_assets (status);
CREATE INDEX IF NOT EXISTS idx_company_assets_branch ON public.company_assets (branch_id);
CREATE INDEX IF NOT EXISTS idx_company_assets_department ON public.company_assets (department_id);
CREATE INDEX IF NOT EXISTS idx_company_assets_assigned ON public.company_assets (assigned_to_employee_id);
CREATE INDEX IF NOT EXISTS idx_company_assets_code ON public.company_assets (asset_code);
CREATE INDEX IF NOT EXISTS idx_company_assets_gps ON public.company_assets (gps_latitude, gps_longitude) WHERE gps_latitude IS NOT NULL;

-- ── A2. asset_depreciation — Monthly depreciation tracking ──
CREATE TABLE IF NOT EXISTS public.asset_depreciation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id uuid NOT NULL REFERENCES public.company_assets(id) ON DELETE CASCADE,

  period_year int NOT NULL,
  period_month int NOT NULL CHECK (period_month BETWEEN 1 AND 12),

  opening_book_value numeric(15,2) NOT NULL,
  depreciation_amount numeric(15,2) NOT NULL,
  accumulated_depreciation numeric(15,2) NOT NULL,
  closing_book_value numeric(15,2) NOT NULL,

  depreciation_method text NOT NULL,
  calculation_notes text,

  posted_to_gl boolean DEFAULT false,
  gl_journal_id uuid,

  calculated_at timestamptz NOT NULL DEFAULT now(),
  calculated_by uuid,

  UNIQUE (asset_id, period_year, period_month)
);

CREATE INDEX IF NOT EXISTS idx_asset_depreciation_period ON public.asset_depreciation (period_year, period_month);
CREATE INDEX IF NOT EXISTS idx_asset_depreciation_asset ON public.asset_depreciation (asset_id);

-- ── A3. asset_maintenance — Maintenance scheduling and history ──
CREATE TABLE IF NOT EXISTS public.asset_maintenance (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id uuid NOT NULL REFERENCES public.company_assets(id) ON DELETE CASCADE,

  maintenance_type text NOT NULL CHECK (maintenance_type IN (
    'preventive', 'corrective', 'emergency', 'inspection', 'calibration', 'upgrade'
  )),
  priority text NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),

  title text NOT NULL,
  description text,

  -- Scheduling
  scheduled_date date,
  due_date date,
  started_at timestamptz,
  completed_at timestamptz,

  -- Cost
  estimated_cost numeric(15,2),
  actual_cost numeric(15,2),
  currency text DEFAULT 'TZS',
  vendor_id uuid,
  vendor_name text,

  -- Assignment
  assigned_to uuid,
  approved_by uuid,

  -- Status
  status text NOT NULL DEFAULT 'scheduled' CHECK (
    status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'overdue')
  ),

  -- Notes & Evidence
  work_notes text,
  parts_replaced text[],
  attachment_ids uuid[],

  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_asset_maintenance_asset ON public.asset_maintenance (asset_id);
CREATE INDEX IF NOT EXISTS idx_asset_maintenance_status ON public.asset_maintenance (status);
CREATE INDEX IF NOT EXISTS idx_asset_maintenance_due ON public.asset_maintenance (due_date) WHERE status IN ('scheduled', 'overdue');
CREATE INDEX IF NOT EXISTS idx_asset_maintenance_scheduled ON public.asset_maintenance (scheduled_date);

-- ── A4. asset_transfer_history — Track asset movements between employees/branches ──
CREATE TABLE IF NOT EXISTS public.asset_transfer_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id uuid NOT NULL REFERENCES public.company_assets(id) ON DELETE CASCADE,

  transfer_type text NOT NULL CHECK (transfer_type IN (
    'assignment', 'branch_transfer', 'department_transfer', 'return', 'disposal'
  )),

  from_employee_id uuid,
  to_employee_id uuid,
  from_branch_id uuid,
  to_branch_id uuid,
  from_department_id uuid,
  to_department_id uuid,

  transfer_date timestamptz NOT NULL DEFAULT now(),
  reason text,
  condition_at_transfer text,

  approved_by uuid,
  approved_at timestamptz,

  -- Handover evidence
  handover_photo_url text,
  handover_signature_url text,
  handover_notes text,
  attachment_ids uuid[],

  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_asset_transfer_asset ON public.asset_transfer_history (asset_id);
CREATE INDEX IF NOT EXISTS idx_asset_transfer_date ON public.asset_transfer_history (transfer_date);

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: ATTACHMENT REGISTRY WITH OCR & FRAUD DETECTION
-- ═══════════════════════════════════════════════════════════════════════

-- ── B1. asset_attachments — Every document/photo attached to any record ──
CREATE TABLE IF NOT EXISTS public.asset_attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- What this attachment belongs to
  entity_type text NOT NULL CHECK (entity_type IN (
    'company_asset', 'maintenance', 'transfer', 'collateral',
    'loan', 'employee', 'vendor', 'expense', 'receipt', 'invoice',
    'insurance', 'valuation', 'inspection', 'general'
  )),
  entity_id uuid NOT NULL,

  -- File metadata
  file_name text NOT NULL,
  file_type text NOT NULL,                             -- pdf, jpg, png, etc.
  mime_type text,
  file_size_bytes bigint,
  storage_path text NOT NULL,                          -- Supabase Storage path
  storage_bucket text NOT NULL DEFAULT 'attachments',
  public_url text,
  thumbnail_url text,

  -- Source
  capture_method text NOT NULL DEFAULT 'upload' CHECK (capture_method IN (
    'upload', 'camera_capture', 'scanner', 'ocr_scanner', 'email', 'api', 'whatsapp'
  )),
  capture_device text,                                 -- e.g. "iPhone 15", "Epson Scanner L3250"
  capture_location_lat double precision,
  capture_location_lng double precision,
  captured_at timestamptz DEFAULT now(),

  -- Hash for integrity & duplicate detection
  file_hash_sha256 text,
  file_hash_md5 text,
  perceptual_hash text,                                -- For image similarity detection

  -- OCR Status
  ocr_status text DEFAULT 'pending' CHECK (ocr_status IN (
    'pending', 'processing', 'completed', 'failed', 'skipped', 'not_applicable'
  )),
  ocr_scan_id uuid,                                    -- FK to attachment_ocr_scans

  -- Fraud Status
  fraud_check_status text DEFAULT 'pending' CHECK (fraud_check_status IN (
    'pending', 'processing', 'clean', 'suspicious', 'fraudulent', 'review_required', 'skipped'
  )),
  fraud_check_id uuid,                                 -- FK to attachment_fraud_checks
  fraud_risk_score int DEFAULT 0 CHECK (fraud_risk_score BETWEEN 0 AND 100),

  -- Verification
  is_verified boolean DEFAULT false,
  verified_by uuid,
  verified_at timestamptz,
  rejection_reason text,

  -- Tags & Classification
  document_type text,                                  -- invoice, receipt, license, insurance_cert, etc.
  tags text[],
  ai_detected_type text,                               -- AI-classified document type

  -- Status
  status text NOT NULL DEFAULT 'active' CHECK (
    status IN ('active', 'archived', 'deleted', 'quarantined', 'under_review')
  ),

  -- Audit
  uploaded_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_asset_attachments_entity ON public.asset_attachments (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_asset_attachments_status ON public.asset_attachments (status);
CREATE INDEX IF NOT EXISTS idx_asset_attachments_ocr ON public.asset_attachments (ocr_status) WHERE ocr_status IN ('pending', 'processing');
CREATE INDEX IF NOT EXISTS idx_asset_attachments_fraud ON public.asset_attachments (fraud_check_status) WHERE fraud_check_status IN ('suspicious', 'fraudulent', 'review_required');
CREATE INDEX IF NOT EXISTS idx_asset_attachments_hash ON public.asset_attachments (file_hash_sha256);
CREATE INDEX IF NOT EXISTS idx_asset_attachments_phash ON public.asset_attachments (perceptual_hash) WHERE perceptual_hash IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_asset_attachments_uploaded ON public.asset_attachments (uploaded_by, created_at DESC);

-- ── B2. attachment_ocr_scans — Live OCR results from scanner/camera ──
CREATE TABLE IF NOT EXISTS public.attachment_ocr_scans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attachment_id uuid NOT NULL REFERENCES public.asset_attachments(id) ON DELETE CASCADE,

  -- OCR Engine
  ocr_engine text NOT NULL DEFAULT 'tesseract' CHECK (ocr_engine IN (
    'tesseract', 'google_vision', 'aws_textract', 'azure_cognitive',
    'gemini_vision', 'claude_vision', 'apple_vision', 'on_device'
  )),
  ocr_mode text NOT NULL DEFAULT 'auto' CHECK (ocr_mode IN (
    'auto', 'scanner', 'camera_live', 'camera_snapshot', 'document', 'receipt', 'id_card'
  )),

  -- Raw Output
  raw_text text,
  raw_text_language text,                              -- Detected language (sw, en, etc.)
  word_count int DEFAULT 0,

  -- Structured Extraction
  extracted_fields jsonb DEFAULT '{}',                 -- Key-value pairs extracted
  -- Example: {"invoice_number": "INV-001", "total": 150000, "date": "2026-01-15", "vendor": "ABC Ltd"}

  extracted_line_items jsonb DEFAULT '[]',             -- For invoices/receipts
  -- Example: [{"description": "Fuel", "qty": 1, "unit_price": 50000, "total": 50000}]

  extracted_dates jsonb DEFAULT '[]',                  -- All dates found in document
  extracted_amounts jsonb DEFAULT '[]',                -- All monetary amounts found
  extracted_names jsonb DEFAULT '[]',                  -- All person/company names found

  -- Quality Metrics
  confidence_score double precision DEFAULT 0 CHECK (confidence_score BETWEEN 0 AND 1),
  image_quality_score double precision DEFAULT 0,      -- 0-1, blur/contrast/resolution
  page_count int DEFAULT 1,

  -- Regions (for highlighting in UI)
  text_regions jsonb DEFAULT '[]',                     -- [{x, y, w, h, text, confidence}]

  -- Processing
  processing_started_at timestamptz,
  processing_completed_at timestamptz,
  processing_duration_ms int,

  status text NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'processing', 'completed', 'failed', 'retrying')
  ),
  error_message text,
  retry_count int DEFAULT 0,

  -- Metadata
  source_image_dimensions jsonb,                       -- {width, height, dpi}
  preprocessing_applied text[],                        -- ['deskew', 'denoise', 'contrast_enhance']

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_attachment_ocr_attachment ON public.attachment_ocr_scans (attachment_id);
CREATE INDEX IF NOT EXISTS idx_attachment_ocr_status ON public.attachment_ocr_scans (status);
CREATE INDEX IF NOT EXISTS idx_attachment_ocr_confidence ON public.attachment_ocr_scans (confidence_score);

-- ── B3. attachment_fraud_checks — AI fraud detection results ──
CREATE TABLE IF NOT EXISTS public.attachment_fraud_checks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attachment_id uuid NOT NULL REFERENCES public.asset_attachments(id) ON DELETE CASCADE,

  -- Analysis Type
  check_type text NOT NULL DEFAULT 'comprehensive' CHECK (check_type IN (
    'comprehensive', 'image_forensics', 'document_verification',
    'duplicate_detection', 'metadata_analysis', 'cross_reference'
  )),

  -- Risk Assessment
  risk_score int NOT NULL DEFAULT 0 CHECK (risk_score BETWEEN 0 AND 100),
  risk_level text NOT NULL DEFAULT 'low' CHECK (risk_level IN (
    'clean', 'low', 'medium', 'high', 'critical'
  )),
  verdict text NOT NULL DEFAULT 'pending' CHECK (verdict IN (
    'pending', 'authentic', 'suspicious', 'fraudulent', 'inconclusive'
  )),

  -- Detection Flags (each flag is a fraud signal)
  fraud_flags jsonb NOT NULL DEFAULT '[]',
  -- Example: [
  --   {"flag": "metadata_tampered", "severity": "high", "detail": "EXIF date modified"},
  --   {"flag": "duplicate_hash", "severity": "critical", "detail": "Exact match with attachment #xyz"},
  --   {"flag": "text_inconsistency", "severity": "medium", "detail": "Date on document doesn't match filename"}
  -- ]

  -- Image Forensics
  exif_analysis jsonb DEFAULT '{}',                    -- EXIF metadata analysis
  ela_score double precision,                          -- Error Level Analysis (0-1, higher = more editing)
  noise_analysis jsonb DEFAULT '{}',                   -- Noise pattern inconsistencies
  copy_move_detection jsonb DEFAULT '{}',              -- Cloned regions detected
  splicing_detection jsonb DEFAULT '{}',               -- Spliced regions detected

  -- Document Verification
  template_match_score double precision,               -- How well it matches known templates
  font_consistency_score double precision,             -- Font uniformity analysis
  alignment_score double precision,                    -- Text/element alignment regularity
  watermark_detected boolean DEFAULT false,
  digital_signature_valid boolean,

  -- Duplicate & Cross-Reference
  duplicate_of_attachment_id uuid,                     -- If this is a duplicate
  similarity_score double precision,                   -- 0-1 similarity to closest match
  cross_reference_results jsonb DEFAULT '[]',          -- Matches found in other records

  -- Amount Verification (for financial docs)
  declared_amount numeric(15,2),
  ocr_extracted_amount numeric(15,2),
  amount_discrepancy boolean DEFAULT false,
  amount_discrepancy_pct double precision,

  -- Date Verification
  declared_date date,
  metadata_date date,                                  -- From EXIF/PDF metadata
  date_discrepancy boolean DEFAULT false,

  -- AI Model Info
  ai_model_used text,
  ai_model_version text,
  ai_confidence double precision,
  ai_reasoning text,                                   -- AI explanation of the verdict

  -- Human Review
  reviewed_by uuid,
  reviewed_at timestamptz,
  review_verdict text CHECK (review_verdict IN (
    'confirmed_authentic', 'confirmed_fraud', 'false_positive', 'inconclusive'
  )),
  review_notes text,

  -- Processing
  processing_started_at timestamptz,
  processing_completed_at timestamptz,
  processing_duration_ms int,

  status text NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'processing', 'completed', 'failed', 'skipped')
  ),
  error_message text,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fraud_check_attachment ON public.attachment_fraud_checks (attachment_id);
CREATE INDEX IF NOT EXISTS idx_fraud_check_risk ON public.attachment_fraud_checks (risk_level) WHERE risk_level IN ('high', 'critical');
CREATE INDEX IF NOT EXISTS idx_fraud_check_verdict ON public.attachment_fraud_checks (verdict);
CREATE INDEX IF NOT EXISTS idx_fraud_check_review ON public.attachment_fraud_checks (status, reviewed_by) WHERE reviewed_by IS NULL AND risk_level IN ('high', 'critical');
CREATE INDEX IF NOT EXISTS idx_fraud_check_duplicate ON public.attachment_fraud_checks (duplicate_of_attachment_id) WHERE duplicate_of_attachment_id IS NOT NULL;

-- ── B4. fraud_detection_rules — Configurable rules engine ──
CREATE TABLE IF NOT EXISTS public.fraud_detection_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  rule_code text UNIQUE NOT NULL,                      -- e.g. 'DUPLICATE_HASH', 'EXIF_TAMPER', 'AMOUNT_MISMATCH'
  rule_name text NOT NULL,
  description text,

  category text NOT NULL CHECK (category IN (
    'image_forensics', 'document_verification', 'duplicate_detection',
    'metadata_analysis', 'cross_reference', 'amount_verification', 'behavioral'
  )),

  -- Rule Configuration
  severity text NOT NULL DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  risk_score_contribution int NOT NULL DEFAULT 10 CHECK (risk_score_contribution BETWEEN 0 AND 100),

  -- Thresholds
  threshold_config jsonb DEFAULT '{}',
  -- Example: {"max_ela_score": 0.7, "min_confidence": 0.5, "similarity_threshold": 0.95}

  -- Applicability
  applies_to_file_types text[] DEFAULT ARRAY['pdf', 'jpg', 'png'],
  applies_to_entity_types text[],

  -- Status
  is_active boolean NOT NULL DEFAULT true,

  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Seed default fraud detection rules
INSERT INTO public.fraud_detection_rules (rule_code, rule_name, description, category, severity, risk_score_contribution, threshold_config)
VALUES
  ('DUPLICATE_HASH_EXACT', 'Exact Duplicate Detection', 'File has identical SHA-256 hash to another attachment', 'duplicate_detection', 'critical', 30, '{"match_type": "exact"}'),
  ('DUPLICATE_PERCEPTUAL', 'Visual Duplicate Detection', 'Image is visually very similar to another attachment', 'duplicate_detection', 'high', 25, '{"similarity_threshold": 0.95}'),
  ('EXIF_DATE_TAMPERED', 'EXIF Date Tampering', 'EXIF creation date has been modified after file creation', 'metadata_analysis', 'high', 20, '{}'),
  ('EXIF_GPS_MISMATCH', 'EXIF GPS Inconsistency', 'EXIF GPS location does not match claimed location', 'metadata_analysis', 'medium', 15, '{"max_distance_km": 5}'),
  ('EXIF_SOFTWARE_EDIT', 'Photo Editing Software Detected', 'EXIF data shows file was opened in image editing software', 'image_forensics', 'medium', 15, '{"flagged_software": ["Photoshop", "GIMP", "Paint.NET"]}'),
  ('ELA_HIGH_SCORE', 'Error Level Analysis Anomaly', 'ELA reveals inconsistent compression levels indicating editing', 'image_forensics', 'high', 25, '{"max_ela_score": 0.7}'),
  ('COPY_MOVE_DETECTED', 'Copy-Move Forgery', 'Cloned/duplicated regions detected within the image', 'image_forensics', 'critical', 35, '{}'),
  ('AMOUNT_MISMATCH', 'Amount Discrepancy', 'Declared amount differs from OCR-extracted amount', 'amount_verification', 'high', 20, '{"max_variance_pct": 5}'),
  ('DATE_MISMATCH', 'Date Discrepancy', 'Document date differs from metadata/claimed date', 'document_verification', 'medium', 15, '{"max_days_variance": 3}'),
  ('FONT_INCONSISTENCY', 'Font Inconsistency', 'Multiple font types detected in an area that should be uniform', 'document_verification', 'high', 20, '{}'),
  ('LOW_QUALITY_DELIBERATE', 'Deliberately Low Quality', 'Image appears intentionally degraded to obscure details', 'image_forensics', 'medium', 15, '{"min_quality_score": 0.3}'),
  ('RESUBMISSION', 'Document Resubmission', 'Same document submitted for different transactions/claims', 'cross_reference', 'critical', 30, '{}'),
  ('FUTURE_DATE', 'Future Date on Document', 'Document contains a date in the future', 'document_verification', 'high', 20, '{}'),
  ('METADATA_STRIPPED', 'Metadata Deliberately Stripped', 'All EXIF/metadata removed — common fraud concealment technique', 'metadata_analysis', 'medium', 15, '{}'),
  ('OCR_TEXT_OVERLAY', 'Text Overlay Detected', 'OCR detects text layered over existing text (potential alteration)', 'document_verification', 'high', 25, '{}')
ON CONFLICT (rule_code) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════════
-- PART C: TECHNOLOGY MONITORING
-- ═══════════════════════════════════════════════════════════════════════

-- ── C1. tech_monitoring_checks — Server/app/network health snapshots ──
CREATE TABLE IF NOT EXISTS public.tech_monitoring_checks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  system_name text NOT NULL,                           -- 'supabase_db', 'edge_functions', 'storage', 'auth', 'network'
  system_type text NOT NULL CHECK (system_type IN (
    'database', 'edge_function', 'storage', 'auth', 'network', 'api', 'cron', 'external_service'
  )),

  -- Check Results
  status text NOT NULL CHECK (status IN ('healthy', 'degraded', 'down', 'unknown')),
  response_time_ms int,
  uptime_pct double precision,                         -- Rolling uptime percentage

  -- Metrics
  metrics jsonb DEFAULT '{}',
  -- Example for DB: {"connections_active": 15, "connections_max": 100, "query_avg_ms": 23, "disk_usage_pct": 45}
  -- Example for Edge: {"invocations_1h": 342, "error_rate_pct": 0.2, "avg_latency_ms": 180}

  error_message text,
  check_source text DEFAULT 'automated',               -- 'automated', 'manual', 'external_monitor'

  checked_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tech_monitoring_system ON public.tech_monitoring_checks (system_name, checked_at DESC);
CREATE INDEX IF NOT EXISTS idx_tech_monitoring_status ON public.tech_monitoring_checks (status) WHERE status != 'healthy';

-- ── C2. asset_system_alerts — Real-time alerts for assets & technology ──
CREATE TABLE IF NOT EXISTS public.asset_system_alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  alert_source text NOT NULL CHECK (alert_source IN (
    'asset_monitoring', 'tech_monitoring', 'fraud_detection', 'ocr_processing',
    'maintenance_due', 'depreciation', 'insurance_expiry', 'license_expiry',
    'gps_geofence', 'asset_movement'
  )),

  severity text NOT NULL CHECK (severity IN ('info', 'warning', 'error', 'critical')),

  title text NOT NULL,
  message text NOT NULL,

  -- Reference
  entity_type text,
  entity_id uuid,

  -- Assignment
  assigned_to uuid,

  -- Status
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'acknowledged', 'resolved', 'dismissed')),
  acknowledged_by uuid,
  acknowledged_at timestamptz,
  resolved_by uuid,
  resolved_at timestamptz,
  resolution_notes text,

  -- Metadata
  metadata jsonb DEFAULT '{}',

  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_asset_alerts_source ON public.asset_system_alerts (alert_source, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_asset_alerts_severity ON public.asset_system_alerts (severity) WHERE status = 'open';
CREATE INDEX IF NOT EXISTS idx_asset_alerts_status ON public.asset_system_alerts (status, created_at DESC);


-- ═══════════════════════════════════════════════════════════════════════
-- PART D: VIEWS — Dashboards & Reporting
-- ═══════════════════════════════════════════════════════════════════════

-- ── D1. v_company_asset_summary — Asset portfolio KPIs ──
CREATE OR REPLACE VIEW public.v_company_asset_summary AS
SELECT
  asset_category,
  count(*) AS total_assets,
  count(*) FILTER (WHERE status = 'active') AS active_assets,
  count(*) FILTER (WHERE status = 'maintenance') AS in_maintenance,
  count(*) FILTER (WHERE status = 'disposed') AS disposed,
  coalesce(sum(purchase_price), 0) AS total_purchase_value,
  coalesce(sum(current_book_value), 0) AS total_book_value,
  coalesce(sum(purchase_price) - sum(current_book_value), 0) AS total_depreciation,
  CASE WHEN sum(purchase_price) > 0
    THEN round(((sum(purchase_price) - sum(current_book_value)) / sum(purchase_price) * 100)::numeric, 2)
    ELSE 0
  END AS depreciation_pct
FROM public.company_assets
GROUP BY asset_category
ORDER BY total_purchase_value DESC;

-- ── D2. v_maintenance_due — Assets needing maintenance ──
CREATE OR REPLACE VIEW public.v_maintenance_due AS
SELECT
  m.id AS maintenance_id,
  m.asset_id,
  a.asset_code,
  a.asset_name,
  a.asset_category,
  m.maintenance_type,
  m.priority,
  m.title,
  m.due_date,
  m.status AS maintenance_status,
  m.estimated_cost,
  m.assigned_to,
  CASE
    WHEN m.due_date < current_date AND m.status IN ('scheduled', 'overdue') THEN 'overdue'
    WHEN m.due_date = current_date THEN 'due_today'
    WHEN m.due_date <= current_date + interval '7 days' THEN 'due_this_week'
    ELSE 'upcoming'
  END AS urgency
FROM public.asset_maintenance m
JOIN public.company_assets a ON a.id = m.asset_id
WHERE m.status IN ('scheduled', 'in_progress', 'overdue')
ORDER BY
  CASE m.priority
    WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4
  END,
  m.due_date ASC;

-- ── D3. v_fraud_alerts_dashboard — Fraud detection overview ──
CREATE OR REPLACE VIEW public.v_fraud_alerts_dashboard AS
SELECT
  fc.id AS fraud_check_id,
  fc.attachment_id,
  att.file_name,
  att.entity_type,
  att.entity_id,
  att.capture_method,
  att.uploaded_by,
  fc.risk_score,
  fc.risk_level,
  fc.verdict,
  fc.fraud_flags,
  fc.ai_reasoning,
  fc.reviewed_by,
  fc.review_verdict,
  fc.created_at AS detected_at,
  att.created_at AS uploaded_at,
  CASE
    WHEN fc.risk_level = 'critical' THEN 1
    WHEN fc.risk_level = 'high' THEN 2
    WHEN fc.risk_level = 'medium' THEN 3
    ELSE 4
  END AS priority_order
FROM public.attachment_fraud_checks fc
JOIN public.asset_attachments att ON att.id = fc.attachment_id
WHERE fc.verdict IN ('suspicious', 'fraudulent', 'inconclusive')
   OR fc.risk_level IN ('high', 'critical')
ORDER BY priority_order, fc.created_at DESC;

-- ── D4. v_tech_system_health — Latest health status per system ──
CREATE OR REPLACE VIEW public.v_tech_system_health AS
SELECT DISTINCT ON (system_name)
  system_name,
  system_type,
  status,
  response_time_ms,
  uptime_pct,
  metrics,
  error_message,
  checked_at,
  CASE
    WHEN status = 'healthy' THEN 'green'
    WHEN status = 'degraded' THEN 'yellow'
    WHEN status = 'down' THEN 'red'
    ELSE 'gray'
  END AS status_color
FROM public.tech_monitoring_checks
ORDER BY system_name, checked_at DESC;

-- ── D5. v_asset_insurance_expiring — Assets with expiring insurance ──
CREATE OR REPLACE VIEW public.v_asset_insurance_expiring AS
SELECT
  id,
  asset_code,
  asset_name,
  asset_category,
  insurance_policy_number,
  insurance_expiry,
  current_date AS as_of_date,
  insurance_expiry - current_date AS days_until_expiry,
  CASE
    WHEN insurance_expiry < current_date THEN 'expired'
    WHEN insurance_expiry <= current_date + interval '30 days' THEN 'expiring_soon'
    WHEN insurance_expiry <= current_date + interval '90 days' THEN 'expiring_quarter'
    ELSE 'valid'
  END AS insurance_status
FROM public.company_assets
WHERE insurance_expiry IS NOT NULL
  AND status = 'active'
ORDER BY insurance_expiry ASC;


-- ═══════════════════════════════════════════════════════════════════════
-- PART E: FUNCTIONS — Business Logic
-- ═══════════════════════════════════════════════════════════════════════

-- ── E1. fn_calculate_depreciation — Monthly depreciation calculation ──
CREATE OR REPLACE FUNCTION public.fn_calculate_depreciation(
  p_asset_id uuid,
  p_year int DEFAULT extract(year FROM current_date)::int,
  p_month int DEFAULT extract(month FROM current_date)::int
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_asset record;
  v_prev record;
  v_opening numeric(15,2);
  v_depreciation numeric(15,2);
  v_accumulated numeric(15,2);
  v_closing numeric(15,2);
BEGIN
  -- Get asset details
  SELECT * INTO v_asset FROM public.company_assets WHERE id = p_asset_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Asset not found');
  END IF;

  IF v_asset.depreciation_method = 'none' THEN
    RETURN jsonb_build_object('success', false, 'error', 'No depreciation for this asset');
  END IF;

  -- Get previous period's closing value
  SELECT * INTO v_prev FROM public.asset_depreciation
  WHERE asset_id = p_asset_id
  ORDER BY period_year DESC, period_month DESC
  LIMIT 1;

  IF v_prev IS NOT NULL THEN
    v_opening := v_prev.closing_book_value;
    v_accumulated := v_prev.accumulated_depreciation;
  ELSE
    v_opening := v_asset.purchase_price;
    v_accumulated := 0;
  END IF;

  -- Don't depreciate below salvage value
  IF v_opening <= coalesce(v_asset.salvage_value, 0) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Asset fully depreciated');
  END IF;

  -- Calculate monthly depreciation
  IF v_asset.depreciation_method = 'straight_line' THEN
    v_depreciation := (v_asset.purchase_price - coalesce(v_asset.salvage_value, 0))
                      / coalesce(v_asset.useful_life_months, 60);
  ELSIF v_asset.depreciation_method = 'declining_balance' THEN
    v_depreciation := v_opening * (coalesce(v_asset.depreciation_rate, 20) / 100 / 12);
  ELSE
    v_depreciation := 0;
  END IF;

  -- Don't depreciate below salvage value
  IF (v_opening - v_depreciation) < coalesce(v_asset.salvage_value, 0) THEN
    v_depreciation := v_opening - coalesce(v_asset.salvage_value, 0);
  END IF;

  v_closing := v_opening - v_depreciation;
  v_accumulated := v_accumulated + v_depreciation;

  -- Insert depreciation record
  INSERT INTO public.asset_depreciation (
    asset_id, period_year, period_month,
    opening_book_value, depreciation_amount, accumulated_depreciation, closing_book_value,
    depreciation_method
  ) VALUES (
    p_asset_id, p_year, p_month,
    v_opening, v_depreciation, v_accumulated, v_closing,
    v_asset.depreciation_method
  )
  ON CONFLICT (asset_id, period_year, period_month) DO UPDATE SET
    opening_book_value = EXCLUDED.opening_book_value,
    depreciation_amount = EXCLUDED.depreciation_amount,
    accumulated_depreciation = EXCLUDED.accumulated_depreciation,
    closing_book_value = EXCLUDED.closing_book_value,
    calculated_at = now();

  -- Update asset's current book value
  UPDATE public.company_assets SET
    current_book_value = v_closing,
    updated_at = now()
  WHERE id = p_asset_id;

  RETURN jsonb_build_object(
    'success', true,
    'asset_id', p_asset_id,
    'period', format('%s-%s', p_year, lpad(p_month::text, 2, '0')),
    'opening', v_opening,
    'depreciation', v_depreciation,
    'accumulated', v_accumulated,
    'closing', v_closing
  );
END;
$$;

-- ── E2. fn_check_duplicate_attachment — Fast duplicate detection ──
CREATE OR REPLACE FUNCTION public.fn_check_duplicate_attachment(
  p_file_hash text,
  p_perceptual_hash text DEFAULT NULL,
  p_exclude_id uuid DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_exact_match record;
  v_visual_matches jsonb;
BEGIN
  -- Check exact hash match
  SELECT id, entity_type, entity_id, file_name, uploaded_by, created_at
  INTO v_exact_match
  FROM public.asset_attachments
  WHERE file_hash_sha256 = p_file_hash
    AND (p_exclude_id IS NULL OR id != p_exclude_id)
    AND status = 'active'
  LIMIT 1;

  IF v_exact_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'is_duplicate', true,
      'match_type', 'exact',
      'matching_attachment_id', v_exact_match.id,
      'matching_entity_type', v_exact_match.entity_type,
      'matching_entity_id', v_exact_match.entity_id,
      'matching_file_name', v_exact_match.file_name,
      'risk_score', 30
    );
  END IF;

  -- Check perceptual hash similarity (for images)
  IF p_perceptual_hash IS NOT NULL THEN
    SELECT jsonb_agg(jsonb_build_object(
      'attachment_id', id,
      'file_name', file_name,
      'entity_type', entity_type
    ))
    INTO v_visual_matches
    FROM public.asset_attachments
    WHERE perceptual_hash = p_perceptual_hash
      AND (p_exclude_id IS NULL OR id != p_exclude_id)
      AND status = 'active';

    IF v_visual_matches IS NOT NULL AND jsonb_array_length(v_visual_matches) > 0 THEN
      RETURN jsonb_build_object(
        'is_duplicate', true,
        'match_type', 'visual',
        'matches', v_visual_matches,
        'risk_score', 25
      );
    END IF;
  END IF;

  RETURN jsonb_build_object('is_duplicate', false, 'risk_score', 0);
END;
$$;

-- ── E3. fn_generate_asset_code — Auto-generate unique asset codes ──
CREATE OR REPLACE FUNCTION public.fn_generate_asset_code(p_category text)
RETURNS text LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_prefix text;
  v_next_num int;
  v_code text;
BEGIN
  v_prefix := CASE p_category
    WHEN 'vehicle' THEN 'VEH'
    WHEN 'it_equipment' THEN 'IT'
    WHEN 'office_furniture' THEN 'FRN'
    WHEN 'office_equipment' THEN 'OEQ'
    WHEN 'machinery' THEN 'MCH'
    WHEN 'building' THEN 'BLD'
    WHEN 'land' THEN 'LND'
    WHEN 'software_license' THEN 'SWL'
    WHEN 'infrastructure' THEN 'INF'
    ELSE 'OTH'
  END;

  SELECT coalesce(max(
    regexp_replace(asset_code, '^[A-Z]+-', '')::int
  ), 0) + 1
  INTO v_next_num
  FROM public.company_assets
  WHERE asset_code LIKE v_prefix || '-%';

  v_code := v_prefix || '-' || lpad(v_next_num::text, 4, '0');

  RETURN v_code;
END;
$$;

-- ── E4. fn_asset_fraud_alert — Auto-create alert when fraud detected ──
CREATE OR REPLACE FUNCTION public.fn_asset_fraud_alert()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Only fire when verdict changes to suspicious or fraudulent
  IF NEW.verdict IN ('suspicious', 'fraudulent')
     AND (OLD IS NULL OR OLD.verdict IS DISTINCT FROM NEW.verdict) THEN

    -- Create system alert
    INSERT INTO public.asset_system_alerts (
      alert_source, severity, title, message,
      entity_type, entity_id, metadata
    ) VALUES (
      'fraud_detection',
      CASE WHEN NEW.verdict = 'fraudulent' THEN 'critical' ELSE 'warning' END,
      CASE WHEN NEW.verdict = 'fraudulent'
        THEN 'UDANGANYIFU: Hati ya ulaghai imegunduliwa!'
        ELSE 'TAHADHARI: Hati yenye mashaka imegunduliwa'
      END,
      format('Attachment %s has been flagged as %s (risk score: %s/100). %s',
        NEW.attachment_id, NEW.verdict, NEW.risk_score,
        coalesce(NEW.ai_reasoning, 'AI analysis complete')),
      'attachment',
      NEW.attachment_id,
      jsonb_build_object(
        'fraud_check_id', NEW.id,
        'risk_score', NEW.risk_score,
        'risk_level', NEW.risk_level,
        'flags', NEW.fraud_flags,
        'ai_reasoning', NEW.ai_reasoning
      )
    );

    -- Also quarantine the attachment
    UPDATE public.asset_attachments SET
      status = CASE WHEN NEW.verdict = 'fraudulent' THEN 'quarantined' ELSE 'under_review' END,
      fraud_risk_score = NEW.risk_score,
      updated_at = now()
    WHERE id = NEW.attachment_id;

    -- Send notification to admin/finance
    PERFORM public.fn_send_notification(
      NULL, 'admin', 'fraud_detected',
      CASE WHEN NEW.verdict = 'fraudulent'
        THEN 'DHARURA: Hati ya ulaghai imegunduliwa!'
        ELSE 'Tahadhari: Hati yenye mashaka'
      END,
      format('Risk score: %s/100. %s', NEW.risk_score, coalesce(NEW.ai_reasoning, '')),
      jsonb_build_object(
        'fraud_check_id', NEW.id,
        'attachment_id', NEW.attachment_id,
        'risk_level', NEW.risk_level
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

-- Attach fraud alert trigger
DROP TRIGGER IF EXISTS trg_fraud_detection_alert ON public.attachment_fraud_checks;
CREATE TRIGGER trg_fraud_detection_alert
  AFTER INSERT OR UPDATE ON public.attachment_fraud_checks
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_asset_fraud_alert();

-- ── E5. fn_auto_flag_maintenance_overdue — Check and flag overdue maintenance ──
CREATE OR REPLACE FUNCTION public.fn_auto_flag_maintenance_overdue()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_count int;
BEGIN
  -- Mark overdue maintenance
  UPDATE public.asset_maintenance SET
    status = 'overdue',
    updated_at = now()
  WHERE status = 'scheduled'
    AND due_date < current_date;

  GET DIAGNOSTICS v_count = ROW_COUNT;

  -- Create alerts for newly overdue items
  INSERT INTO public.asset_system_alerts (
    alert_source, severity, title, message,
    entity_type, entity_id, metadata
  )
  SELECT
    'maintenance_due',
    CASE WHEN m.priority = 'critical' THEN 'critical'
         WHEN m.priority = 'high' THEN 'error'
         ELSE 'warning'
    END,
    format('Matengenezo Yamechelewa: %s', a.asset_name),
    format('Maintenance "%s" for %s (%s) was due on %s',
      m.title, a.asset_name, a.asset_code, m.due_date),
    'maintenance',
    m.id,
    jsonb_build_object(
      'asset_id', m.asset_id,
      'priority', m.priority,
      'due_date', m.due_date,
      'days_overdue', current_date - m.due_date
    )
  FROM public.asset_maintenance m
  JOIN public.company_assets a ON a.id = m.asset_id
  WHERE m.status = 'overdue'
    AND m.due_date = current_date - interval '1 day'; -- Only alert once

  RETURN jsonb_build_object('success', true, 'overdue_count', v_count);
END;
$$;

-- ── E6. fn_insurance_expiry_check — Check expiring insurance ──
CREATE OR REPLACE FUNCTION public.fn_insurance_expiry_check()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_count int := 0;
BEGIN
  INSERT INTO public.asset_system_alerts (
    alert_source, severity, title, message,
    entity_type, entity_id, metadata
  )
  SELECT
    'insurance_expiry',
    CASE
      WHEN insurance_expiry < current_date THEN 'critical'
      WHEN insurance_expiry <= current_date + interval '7 days' THEN 'error'
      ELSE 'warning'
    END,
    CASE
      WHEN insurance_expiry < current_date
        THEN format('BIMA IMEISHA: %s (%s)', asset_name, asset_code)
      ELSE format('Bima Inakaribia Kuisha: %s (%s)', asset_name, asset_code)
    END,
    format('Insurance policy %s for %s expires on %s (%s days)',
      insurance_policy_number, asset_name, insurance_expiry,
      insurance_expiry - current_date),
    'company_asset',
    id,
    jsonb_build_object(
      'insurance_policy', insurance_policy_number,
      'expiry_date', insurance_expiry,
      'days_remaining', insurance_expiry - current_date
    )
  FROM public.company_assets
  WHERE status = 'active'
    AND insurance_expiry IS NOT NULL
    AND insurance_expiry BETWEEN current_date - interval '1 day' AND current_date + interval '30 days';

  GET DIAGNOSTICS v_count = ROW_COUNT;

  RETURN jsonb_build_object('success', true, 'alerts_created', v_count);
END;
$$;


-- ═══════════════════════════════════════════════════════════════════════
-- PART F: ROW LEVEL SECURITY POLICIES
-- ═══════════════════════════════════════════════════════════════════════

-- ── F1. company_assets RLS ──
ALTER TABLE public.company_assets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS company_assets_read ON public.company_assets;
CREATE POLICY company_assets_read ON public.company_assets
  FOR SELECT USING (
    auth.role() IN ('authenticated', 'service_role')
  );

DROP POLICY IF EXISTS company_assets_write ON public.company_assets;
CREATE POLICY company_assets_write ON public.company_assets
  FOR ALL USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'finance', 'asset_manager')
    )
  );

-- ── F2. asset_depreciation RLS ──
ALTER TABLE public.asset_depreciation ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS asset_depreciation_read ON public.asset_depreciation;
CREATE POLICY asset_depreciation_read ON public.asset_depreciation
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS asset_depreciation_write ON public.asset_depreciation;
CREATE POLICY asset_depreciation_write ON public.asset_depreciation
  FOR ALL USING (auth.role() = 'service_role');

-- ── F3. asset_maintenance RLS ──
ALTER TABLE public.asset_maintenance ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS asset_maintenance_read ON public.asset_maintenance;
CREATE POLICY asset_maintenance_read ON public.asset_maintenance
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS asset_maintenance_write ON public.asset_maintenance;
CREATE POLICY asset_maintenance_write ON public.asset_maintenance
  FOR ALL USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'finance', 'asset_manager')
    )
  );

-- ── F4. asset_transfer_history RLS ──
ALTER TABLE public.asset_transfer_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS asset_transfer_read ON public.asset_transfer_history;
CREATE POLICY asset_transfer_read ON public.asset_transfer_history
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS asset_transfer_write ON public.asset_transfer_history;
CREATE POLICY asset_transfer_write ON public.asset_transfer_history
  FOR ALL USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'asset_manager')
    )
  );

-- ── F5. asset_attachments RLS ──
ALTER TABLE public.asset_attachments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS asset_attachments_read ON public.asset_attachments;
CREATE POLICY asset_attachments_read ON public.asset_attachments
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS asset_attachments_insert ON public.asset_attachments;
CREATE POLICY asset_attachments_insert ON public.asset_attachments
  FOR INSERT WITH CHECK (
    uploaded_by = auth.uid()
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS asset_attachments_admin ON public.asset_attachments;
CREATE POLICY asset_attachments_admin ON public.asset_attachments
  FOR ALL USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'finance', 'asset_manager')
    )
  );

-- ── F6. attachment_ocr_scans RLS ──
ALTER TABLE public.attachment_ocr_scans ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ocr_scans_read ON public.attachment_ocr_scans;
CREATE POLICY ocr_scans_read ON public.attachment_ocr_scans
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS ocr_scans_write ON public.attachment_ocr_scans;
CREATE POLICY ocr_scans_write ON public.attachment_ocr_scans
  FOR ALL USING (auth.role() = 'service_role');

-- ── F7. attachment_fraud_checks RLS ──
ALTER TABLE public.attachment_fraud_checks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS fraud_checks_read ON public.attachment_fraud_checks;
CREATE POLICY fraud_checks_read ON public.attachment_fraud_checks
  FOR SELECT USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'finance', 'auditor', 'asset_manager')
    )
  );

DROP POLICY IF EXISTS fraud_checks_write ON public.attachment_fraud_checks;
CREATE POLICY fraud_checks_write ON public.attachment_fraud_checks
  FOR ALL USING (auth.role() = 'service_role');

-- ── F8. fraud_detection_rules RLS ──
ALTER TABLE public.fraud_detection_rules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS fraud_rules_read ON public.fraud_detection_rules;
CREATE POLICY fraud_rules_read ON public.fraud_detection_rules
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS fraud_rules_write ON public.fraud_detection_rules;
CREATE POLICY fraud_rules_write ON public.fraud_detection_rules
  FOR ALL USING (auth.role() = 'service_role');

-- ── F9. tech_monitoring_checks RLS ──
ALTER TABLE public.tech_monitoring_checks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tech_monitoring_read ON public.tech_monitoring_checks;
CREATE POLICY tech_monitoring_read ON public.tech_monitoring_checks
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS tech_monitoring_write ON public.tech_monitoring_checks;
CREATE POLICY tech_monitoring_write ON public.tech_monitoring_checks
  FOR ALL USING (auth.role() = 'service_role');

-- ── F10. asset_system_alerts RLS ──
ALTER TABLE public.asset_system_alerts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS asset_alerts_read ON public.asset_system_alerts;
CREATE POLICY asset_alerts_read ON public.asset_system_alerts
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS asset_alerts_write ON public.asset_system_alerts;
CREATE POLICY asset_alerts_write ON public.asset_system_alerts
  FOR ALL USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'asset_manager')
    )
  );


-- ═══════════════════════════════════════════════════════════════════════
-- PART G: TRIGGERS — Auto-update, Audit, Notifications
-- ═══════════════════════════════════════════════════════════════════════

-- ── G1. Auto-update updated_at on company_assets ──
CREATE OR REPLACE FUNCTION public.fn_update_timestamp()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DO $$ BEGIN
  DROP TRIGGER IF EXISTS trg_company_assets_updated ON public.company_assets;
  CREATE TRIGGER trg_company_assets_updated
    BEFORE UPDATE ON public.company_assets
    FOR EACH ROW EXECUTE FUNCTION public.fn_update_timestamp();

  DROP TRIGGER IF EXISTS trg_asset_attachments_updated ON public.asset_attachments;
  CREATE TRIGGER trg_asset_attachments_updated
    BEFORE UPDATE ON public.asset_attachments
    FOR EACH ROW EXECUTE FUNCTION public.fn_update_timestamp();

  DROP TRIGGER IF EXISTS trg_asset_maintenance_updated ON public.asset_maintenance;
  CREATE TRIGGER trg_asset_maintenance_updated
    BEFORE UPDATE ON public.asset_maintenance
    FOR EACH ROW EXECUTE FUNCTION public.fn_update_timestamp();
END $$;

-- ── G2. Audit trigger for company_assets changes ──
DO $$ BEGIN
  DROP TRIGGER IF EXISTS trg_audit_company_assets ON public.company_assets;
  CREATE TRIGGER trg_audit_company_assets
    AFTER INSERT OR UPDATE OR DELETE ON public.company_assets
    FOR EACH ROW EXECUTE FUNCTION public.fn_hr_audit_trigger();

  DROP TRIGGER IF EXISTS trg_audit_asset_attachments ON public.asset_attachments;
  CREATE TRIGGER trg_audit_asset_attachments
    AFTER INSERT OR UPDATE OR DELETE ON public.asset_attachments
    FOR EACH ROW EXECUTE FUNCTION public.fn_hr_audit_trigger();
END $$;

-- ── G3. Auto-notify on asset status change ──
CREATE OR REPLACE FUNCTION public.fn_asset_status_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Notify admin of asset status changes
    PERFORM public.fn_send_notification(
      NULL, 'admin', 'asset_status_change',
      format('Mali ya Kampuni: %s — %s', NEW.asset_name, NEW.status),
      format('Asset %s (%s) status changed from %s to %s',
        NEW.asset_name, NEW.asset_code, OLD.status, NEW.status),
      jsonb_build_object(
        'asset_id', NEW.id,
        'asset_code', NEW.asset_code,
        'old_status', OLD.status,
        'new_status', NEW.status
      )
    );

    -- If disposed, create disposal alert
    IF NEW.status = 'disposed' THEN
      INSERT INTO public.asset_system_alerts (
        alert_source, severity, title, message,
        entity_type, entity_id, metadata
      ) VALUES (
        'asset_monitoring', 'warning',
        format('Mali Imetolewa: %s', NEW.asset_name),
        format('%s (%s) has been disposed. Method: %s, Value: %s',
          NEW.asset_name, NEW.asset_code,
          coalesce(NEW.disposal_method, 'N/A'),
          coalesce(NEW.disposal_value::text, 'N/A')),
        'company_asset', NEW.id,
        jsonb_build_object(
          'disposal_method', NEW.disposal_method,
          'disposal_value', NEW.disposal_value,
          'book_value_at_disposal', NEW.current_book_value
        )
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_asset_status_notify ON public.company_assets;
CREATE TRIGGER trg_asset_status_notify
  AFTER UPDATE ON public.company_assets
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION public.fn_asset_status_notify();


-- ═══════════════════════════════════════════════════════════════════════
-- PART H: GRANTS
-- ═══════════════════════════════════════════════════════════════════════

GRANT SELECT ON public.company_assets TO authenticated;
GRANT SELECT ON public.asset_depreciation TO authenticated;
GRANT SELECT ON public.asset_maintenance TO authenticated;
GRANT SELECT ON public.asset_transfer_history TO authenticated;
GRANT SELECT, INSERT ON public.asset_attachments TO authenticated;
GRANT SELECT ON public.attachment_ocr_scans TO authenticated;
GRANT SELECT ON public.attachment_fraud_checks TO authenticated;
GRANT SELECT ON public.fraud_detection_rules TO authenticated;
GRANT SELECT ON public.tech_monitoring_checks TO authenticated;
GRANT SELECT, UPDATE ON public.asset_system_alerts TO authenticated;

GRANT ALL ON public.company_assets TO service_role;
GRANT ALL ON public.asset_depreciation TO service_role;
GRANT ALL ON public.asset_maintenance TO service_role;
GRANT ALL ON public.asset_transfer_history TO service_role;
GRANT ALL ON public.asset_attachments TO service_role;
GRANT ALL ON public.attachment_ocr_scans TO service_role;
GRANT ALL ON public.attachment_fraud_checks TO service_role;
GRANT ALL ON public.fraud_detection_rules TO service_role;
GRANT ALL ON public.tech_monitoring_checks TO service_role;
GRANT ALL ON public.asset_system_alerts TO service_role;

GRANT SELECT ON public.v_company_asset_summary TO authenticated;
GRANT SELECT ON public.v_maintenance_due TO authenticated;
GRANT SELECT ON public.v_fraud_alerts_dashboard TO authenticated;
GRANT SELECT ON public.v_tech_system_health TO authenticated;
GRANT SELECT ON public.v_asset_insurance_expiring TO authenticated;

GRANT EXECUTE ON FUNCTION public.fn_calculate_depreciation TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_check_duplicate_attachment TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_generate_asset_code TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_auto_flag_maintenance_overdue TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_insurance_expiry_check TO service_role;


-- ═══════════════════════════════════════════════════════════════════════
-- VERIFICATION
-- ═══════════════════════════════════════════════════════════════════════
DO $$
DECLARE
  v_tables text[];
  v_missing text[];
  v_t text;
BEGIN
  v_tables := ARRAY[
    'company_assets', 'asset_depreciation', 'asset_maintenance',
    'asset_transfer_history', 'asset_attachments', 'attachment_ocr_scans',
    'attachment_fraud_checks', 'fraud_detection_rules',
    'tech_monitoring_checks', 'asset_system_alerts'
  ];

  v_missing := '{}';

  FOREACH v_t IN ARRAY v_tables LOOP
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = v_t
    ) THEN
      v_missing := array_append(v_missing, v_t);
    END IF;
  END LOOP;

  IF array_length(v_missing, 1) > 0 THEN
    RAISE EXCEPTION 'Missing tables: %', array_to_string(v_missing, ', ');
  END IF;

  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE 'MIGRATION 013 COMPLETE — Mali ya Kampuni + OCR + Fraud Detection';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE 'Tables created: %', array_length(v_tables, 1);
  RAISE NOTICE 'Views created: 5';
  RAISE NOTICE 'Functions created: 6';
  RAISE NOTICE 'RLS policies: 20';
  RAISE NOTICE 'Triggers: 6';
  RAISE NOTICE 'Fraud rules seeded: 15';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
END $$;
