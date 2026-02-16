-- ============================================================================
-- MALI YA KAMPUNI - Company Assets & Technology Monitoring
-- Full Supabase Migration with Business Logic, OCR, AI Fraud Detection
-- ============================================================================

-- 1. COMPANY ASSETS TABLE (Mali ya Kampuni)
CREATE TABLE IF NOT EXISTS company_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_tag VARCHAR(50) UNIQUE NOT NULL,
  asset_name VARCHAR(255) NOT NULL,
  asset_category VARCHAR(50) NOT NULL CHECK (asset_category IN (
    'vehicle', 'it_equipment', 'office_furniture', 'machinery',
    'building', 'land', 'software_license', 'other'
  )),
  asset_subcategory VARCHAR(100),
  description TEXT,
  serial_number VARCHAR(100),
  registration_number VARCHAR(50),
  manufacturer VARCHAR(100),
  model VARCHAR(100),
  purchase_date DATE NOT NULL,
  purchase_price NUMERIC(15,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'TZS',
  current_value NUMERIC(15,2),
  depreciation_method VARCHAR(30) DEFAULT 'straight_line' CHECK (depreciation_method IN (
    'straight_line', 'declining_balance', 'units_of_production', 'none'
  )),
  useful_life_years INT,
  salvage_value NUMERIC(15,2) DEFAULT 0,
  annual_depreciation_rate NUMERIC(5,2),
  accumulated_depreciation NUMERIC(15,2) DEFAULT 0,
  condition VARCHAR(20) DEFAULT 'good' CHECK (condition IN (
    'new', 'good', 'fair', 'poor', 'damaged', 'disposed'
  )),
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN (
    'active', 'maintenance', 'disposed', 'stolen', 'transferred', 'leased_out'
  )),
  location_branch_id UUID,
  location_description VARCHAR(255),
  gps_latitude DOUBLE PRECISION,
  gps_longitude DOUBLE PRECISION,
  assigned_to UUID,
  assigned_department VARCHAR(100),
  warranty_expiry DATE,
  insurance_policy_number VARCHAR(100),
  insurance_expiry DATE,
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  photo_url TEXT,
  documents_json JSONB DEFAULT '[]'::jsonb,
  ocr_verified BOOLEAN DEFAULT FALSE,
  ocr_verification_id UUID,
  fraud_check_status VARCHAR(20) DEFAULT 'pending' CHECK (fraud_check_status IN (
    'pending', 'clean', 'flagged', 'investigating', 'cleared', 'confirmed_fraud'
  )),
  fraud_risk_score INT DEFAULT 0 CHECK (fraud_risk_score BETWEEN 0 AND 100),
  created_by UUID NOT NULL,
  updated_by UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. ASSET MAINTENANCE RECORDS
CREATE TABLE IF NOT EXISTS asset_maintenance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id UUID NOT NULL REFERENCES company_assets(id) ON DELETE CASCADE,
  maintenance_type VARCHAR(30) NOT NULL CHECK (maintenance_type IN (
    'preventive', 'corrective', 'emergency', 'inspection', 'upgrade'
  )),
  description TEXT NOT NULL,
  scheduled_date DATE,
  completed_date DATE,
  cost NUMERIC(15,2),
  currency VARCHAR(3) DEFAULT 'TZS',
  vendor_id UUID,
  vendor_name VARCHAR(255),
  technician_name VARCHAR(255),
  status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN (
    'scheduled', 'in_progress', 'completed', 'cancelled', 'overdue'
  )),
  priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN (
    'low', 'medium', 'high', 'critical'
  )),
  notes TEXT,
  attachment_urls JSONB DEFAULT '[]'::jsonb,
  ocr_receipt_id UUID,
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. ASSET DEPRECIATION LEDGER
CREATE TABLE IF NOT EXISTS asset_depreciation_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id UUID NOT NULL REFERENCES company_assets(id) ON DELETE CASCADE,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  opening_value NUMERIC(15,2) NOT NULL,
  depreciation_amount NUMERIC(15,2) NOT NULL,
  closing_value NUMERIC(15,2) NOT NULL,
  accumulated_depreciation NUMERIC(15,2) NOT NULL,
  method_used VARCHAR(30) NOT NULL,
  calculated_by VARCHAR(20) DEFAULT 'system',
  gl_journal_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. ASSET OCR SCANS (Scanner & Photo OCR for document verification)
CREATE TABLE IF NOT EXISTS asset_ocr_scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id UUID REFERENCES company_assets(id) ON DELETE SET NULL,
  maintenance_id UUID REFERENCES asset_maintenance_records(id) ON DELETE SET NULL,
  scan_type VARCHAR(30) NOT NULL CHECK (scan_type IN (
    'purchase_receipt', 'warranty_card', 'insurance_doc', 'maintenance_receipt',
    'registration_doc', 'valuation_report', 'photo_verification', 'live_capture'
  )),
  original_filename VARCHAR(255),
  storage_path TEXT NOT NULL,
  file_size_bytes BIGINT,
  mime_type VARCHAR(50),
  image_hash VARCHAR(128),
  hash_algorithm VARCHAR(10) DEFAULT 'sha256',
  ocr_engine VARCHAR(30) DEFAULT 'gemini_flash',
  ocr_status VARCHAR(20) DEFAULT 'pending' CHECK (ocr_status IN (
    'pending', 'processing', 'completed', 'failed', 'needs_review'
  )),
  extracted_text TEXT,
  extracted_fields JSONB,
  confidence_score NUMERIC(5,4),
  detected_language VARCHAR(10),
  is_live_capture BOOLEAN DEFAULT FALSE,
  capture_latitude DOUBLE PRECISION,
  capture_longitude DOUBLE PRECISION,
  capture_timestamp TIMESTAMPTZ,
  device_info JSONB,
  -- AI Fraud Detection Fields
  fraud_analysis_status VARCHAR(20) DEFAULT 'pending' CHECK (fraud_analysis_status IN (
    'pending', 'analyzing', 'clean', 'suspicious', 'fraudulent'
  )),
  fraud_risk_score INT DEFAULT 0 CHECK (fraud_risk_score BETWEEN 0 AND 100),
  fraud_indicators JSONB DEFAULT '[]'::jsonb,
  fraud_analysis_details JSONB,
  is_duplicate BOOLEAN DEFAULT FALSE,
  duplicate_of_id UUID REFERENCES asset_ocr_scans(id),
  metadata_tampering_detected BOOLEAN DEFAULT FALSE,
  image_manipulation_detected BOOLEAN DEFAULT FALSE,
  -- Verification
  verified_by UUID,
  verified_at TIMESTAMPTZ,
  verification_notes TEXT,
  uploaded_by UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. ASSET TRANSFER LOG
CREATE TABLE IF NOT EXISTS asset_transfers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id UUID NOT NULL REFERENCES company_assets(id) ON DELETE CASCADE,
  from_branch_id UUID,
  to_branch_id UUID,
  from_department VARCHAR(100),
  to_department VARCHAR(100),
  from_assigned_to UUID,
  to_assigned_to UUID,
  transfer_date DATE NOT NULL,
  reason TEXT,
  authorized_by UUID NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
    'pending', 'approved', 'in_transit', 'completed', 'rejected'
  )),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. TECHNOLOGY MONITORING DASHBOARD DATA
CREATE TABLE IF NOT EXISTS tech_monitoring_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_type VARCHAR(30) NOT NULL CHECK (snapshot_type IN (
    'server', 'application', 'network', 'database', 'storage', 'security'
  )),
  component_name VARCHAR(100) NOT NULL,
  health_status VARCHAR(20) NOT NULL CHECK (health_status IN (
    'healthy', 'degraded', 'critical', 'offline', 'maintenance'
  )),
  uptime_percentage NUMERIC(5,2),
  response_time_ms INT,
  cpu_usage_percent NUMERIC(5,2),
  memory_usage_percent NUMERIC(5,2),
  disk_usage_percent NUMERIC(5,2),
  active_connections INT,
  error_rate_percent NUMERIC(5,2),
  metrics_json JSONB,
  alert_count INT DEFAULT 0,
  last_incident_at TIMESTAMPTZ,
  checked_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. AI FRAUD ANALYSIS RULES (for OCR document fraud detection)
CREATE TABLE IF NOT EXISTS ocr_fraud_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_name VARCHAR(100) NOT NULL,
  rule_code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  rule_type VARCHAR(30) CHECK (rule_type IN (
    'duplicate_detection', 'metadata_analysis', 'image_manipulation',
    'amount_anomaly', 'date_anomaly', 'vendor_verification', 'pattern_matching'
  )),
  severity VARCHAR(10) DEFAULT 'medium' CHECK (severity IN (
    'low', 'medium', 'high', 'critical'
  )),
  threshold_value NUMERIC(10,2),
  is_active BOOLEAN DEFAULT TRUE,
  rule_config JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_company_assets_category ON company_assets(asset_category);
CREATE INDEX IF NOT EXISTS idx_company_assets_status ON company_assets(status);
CREATE INDEX IF NOT EXISTS idx_company_assets_branch ON company_assets(location_branch_id);
CREATE INDEX IF NOT EXISTS idx_company_assets_fraud ON company_assets(fraud_check_status);
CREATE INDEX IF NOT EXISTS idx_company_assets_tag ON company_assets(asset_tag);
CREATE INDEX IF NOT EXISTS idx_maintenance_asset ON asset_maintenance_records(asset_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON asset_maintenance_records(status);
CREATE INDEX IF NOT EXISTS idx_maintenance_next ON asset_maintenance_records(scheduled_date) WHERE status = 'scheduled';
CREATE INDEX IF NOT EXISTS idx_depreciation_asset ON asset_depreciation_ledger(asset_id);
CREATE INDEX IF NOT EXISTS idx_ocr_scans_asset ON asset_ocr_scans(asset_id);
CREATE INDEX IF NOT EXISTS idx_ocr_scans_fraud ON asset_ocr_scans(fraud_analysis_status);
CREATE INDEX IF NOT EXISTS idx_ocr_scans_hash ON asset_ocr_scans(image_hash);
CREATE INDEX IF NOT EXISTS idx_tech_monitoring_type ON tech_monitoring_snapshots(snapshot_type);
CREATE INDEX IF NOT EXISTS idx_tech_monitoring_time ON tech_monitoring_snapshots(checked_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================
ALTER TABLE company_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_maintenance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_depreciation_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_ocr_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE tech_monitoring_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE ocr_fraud_rules ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Authenticated users can read all, write with proper roles
CREATE POLICY "Authenticated users can view company assets"
  ON company_assets FOR SELECT TO authenticated USING (true);

CREATE POLICY "Staff can insert company assets"
  ON company_assets FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Staff can update own assets"
  ON company_assets FOR UPDATE TO authenticated USING (auth.uid() = created_by OR auth.uid() = assigned_to);

CREATE POLICY "Authenticated users can view maintenance"
  ON asset_maintenance_records FOR SELECT TO authenticated USING (true);

CREATE POLICY "Staff can insert maintenance"
  ON asset_maintenance_records FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Authenticated users can view depreciation"
  ON asset_depreciation_ledger FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can view OCR scans"
  ON asset_ocr_scans FOR SELECT TO authenticated USING (true);

CREATE POLICY "Staff can insert OCR scans"
  ON asset_ocr_scans FOR INSERT TO authenticated WITH CHECK (auth.uid() = uploaded_by);

CREATE POLICY "Authenticated users can view transfers"
  ON asset_transfers FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can view tech monitoring"
  ON tech_monitoring_snapshots FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can view fraud rules"
  ON ocr_fraud_rules FOR SELECT TO authenticated USING (true);

-- ============================================================================
-- BUSINESS LOGIC FUNCTIONS
-- ============================================================================

-- Function 1: Calculate asset depreciation
CREATE OR REPLACE FUNCTION fn_calculate_asset_depreciation(
  p_asset_id UUID,
  p_period_end DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
  asset_id UUID,
  current_value NUMERIC,
  depreciation_this_period NUMERIC,
  accumulated_depreciation NUMERIC,
  book_value NUMERIC
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_asset company_assets%ROWTYPE;
  v_age_years NUMERIC;
  v_annual_dep NUMERIC;
  v_period_dep NUMERIC;
  v_accum_dep NUMERIC;
  v_book_value NUMERIC;
BEGIN
  SELECT * INTO v_asset FROM company_assets WHERE id = p_asset_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Asset not found: %', p_asset_id;
  END IF;

  v_age_years := EXTRACT(YEAR FROM age(p_period_end, v_asset.purchase_date))
    + EXTRACT(MONTH FROM age(p_period_end, v_asset.purchase_date)) / 12.0;

  IF v_asset.depreciation_method = 'straight_line' AND v_asset.useful_life_years > 0 THEN
    v_annual_dep := (v_asset.purchase_price - COALESCE(v_asset.salvage_value, 0))
      / v_asset.useful_life_years;
    v_accum_dep := LEAST(v_annual_dep * v_age_years,
      v_asset.purchase_price - COALESCE(v_asset.salvage_value, 0));
    v_period_dep := v_annual_dep / 12;
  ELSIF v_asset.depreciation_method = 'declining_balance' AND v_asset.annual_depreciation_rate > 0 THEN
    v_accum_dep := v_asset.purchase_price * (1 - POWER(1 - v_asset.annual_depreciation_rate/100, v_age_years));
    v_accum_dep := LEAST(v_accum_dep, v_asset.purchase_price - COALESCE(v_asset.salvage_value, 0));
    v_period_dep := (v_asset.purchase_price - v_accum_dep) * (v_asset.annual_depreciation_rate/100) / 12;
  ELSE
    v_accum_dep := 0;
    v_period_dep := 0;
  END IF;

  v_book_value := v_asset.purchase_price - v_accum_dep;

  RETURN QUERY SELECT
    p_asset_id,
    v_asset.purchase_price,
    v_period_dep,
    v_accum_dep,
    v_book_value;
END;
$$;

-- Function 2: Get company asset KPI summary
CREATE OR REPLACE FUNCTION fn_company_asset_kpis()
RETURNS TABLE(
  total_assets BIGINT,
  total_asset_value NUMERIC,
  total_depreciation NUMERIC,
  net_book_value NUMERIC,
  maintenance_due_count BIGINT,
  maintenance_overdue_count BIGINT,
  assets_by_category JSONB,
  assets_by_status JSONB,
  assets_by_condition JSONB,
  fraud_flagged_count BIGINT,
  ocr_pending_count BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY SELECT
    COUNT(*)::BIGINT AS total_assets,
    COALESCE(SUM(ca.purchase_price), 0)::NUMERIC AS total_asset_value,
    COALESCE(SUM(ca.accumulated_depreciation), 0)::NUMERIC AS total_depreciation,
    COALESCE(SUM(ca.purchase_price - ca.accumulated_depreciation), 0)::NUMERIC AS net_book_value,
    (SELECT COUNT(*) FROM asset_maintenance_records
     WHERE status = 'scheduled' AND scheduled_date <= CURRENT_DATE + INTERVAL '30 days')::BIGINT AS maintenance_due_count,
    (SELECT COUNT(*) FROM asset_maintenance_records
     WHERE status = 'scheduled' AND scheduled_date < CURRENT_DATE)::BIGINT AS maintenance_overdue_count,
    (SELECT jsonb_object_agg(asset_category, cnt)
     FROM (SELECT asset_category, COUNT(*) AS cnt FROM company_assets WHERE status = 'active' GROUP BY asset_category) sub
    ) AS assets_by_category,
    (SELECT jsonb_object_agg(status, cnt)
     FROM (SELECT status, COUNT(*) AS cnt FROM company_assets GROUP BY status) sub
    ) AS assets_by_status,
    (SELECT jsonb_object_agg(condition, cnt)
     FROM (SELECT condition, COUNT(*) AS cnt FROM company_assets WHERE status = 'active' GROUP BY condition) sub
    ) AS assets_by_condition,
    (SELECT COUNT(*) FROM company_assets WHERE fraud_check_status IN ('flagged', 'investigating'))::BIGINT AS fraud_flagged_count,
    (SELECT COUNT(*) FROM asset_ocr_scans WHERE ocr_status = 'pending')::BIGINT AS ocr_pending_count
  FROM company_assets ca
  WHERE ca.status != 'disposed';
END;
$$;

-- Function 3: AI-powered OCR Fraud Detection Analysis
CREATE OR REPLACE FUNCTION fn_ocr_fraud_analysis(
  p_scan_id UUID
)
RETURNS TABLE(
  scan_id UUID,
  risk_score INT,
  is_suspicious BOOLEAN,
  fraud_indicators JSONB,
  analysis_summary TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_scan asset_ocr_scans%ROWTYPE;
  v_risk INT := 0;
  v_indicators JSONB := '[]'::JSONB;
  v_summary TEXT := '';
  v_dup_count INT;
  v_similar_amount_count INT;
BEGIN
  SELECT * INTO v_scan FROM asset_ocr_scans WHERE id = p_scan_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'OCR scan not found: %', p_scan_id;
  END IF;

  -- Rule 1: Duplicate image hash detection
  SELECT COUNT(*) INTO v_dup_count
  FROM asset_ocr_scans
  WHERE image_hash = v_scan.image_hash
    AND id != v_scan.id
    AND image_hash IS NOT NULL;
  IF v_dup_count > 0 THEN
    v_risk := v_risk + 40;
    v_indicators := v_indicators || jsonb_build_array(jsonb_build_object(
      'rule', 'DUPLICATE_IMAGE',
      'severity', 'critical',
      'message', format('Picha hii imepatikana mara %s nyingine kwenye mfumo (This image found %s other times in system)', v_dup_count, v_dup_count),
      'count', v_dup_count
    ));
  END IF;

  -- Rule 2: Low confidence OCR score
  IF v_scan.confidence_score IS NOT NULL AND v_scan.confidence_score < 0.6 THEN
    v_risk := v_risk + 20;
    v_indicators := v_indicators || jsonb_build_array(jsonb_build_object(
      'rule', 'LOW_OCR_CONFIDENCE',
      'severity', 'high',
      'message', format('Ubora wa OCR ni mdogo: %.1f%% (OCR confidence low: %.1f%%)', v_scan.confidence_score * 100, v_scan.confidence_score * 100),
      'confidence', v_scan.confidence_score
    ));
  END IF;

  -- Rule 3: Missing live capture GPS for live_capture type
  IF v_scan.is_live_capture AND (v_scan.capture_latitude IS NULL OR v_scan.capture_longitude IS NULL) THEN
    v_risk := v_risk + 25;
    v_indicators := v_indicators || jsonb_build_array(jsonb_build_object(
      'rule', 'MISSING_GPS_LIVE_CAPTURE',
      'severity', 'high',
      'message', 'Picha ya moja kwa moja haina taarifa za GPS (Live capture missing GPS data)'
    ));
  END IF;

  -- Rule 4: Timestamp anomaly (capture time far from upload time)
  IF v_scan.capture_timestamp IS NOT NULL AND
     ABS(EXTRACT(EPOCH FROM (v_scan.created_at - v_scan.capture_timestamp))) > 86400 THEN
    v_risk := v_risk + 15;
    v_indicators := v_indicators || jsonb_build_array(jsonb_build_object(
      'rule', 'TIMESTAMP_ANOMALY',
      'severity', 'medium',
      'message', 'Muda wa picha na muda wa kupakia havilingani (Capture and upload timestamps don''t match)',
      'time_diff_hours', ROUND(ABS(EXTRACT(EPOCH FROM (v_scan.created_at - v_scan.capture_timestamp))) / 3600)
    ));
  END IF;

  -- Rule 5: Metadata tampering indicators
  IF v_scan.metadata_tampering_detected THEN
    v_risk := v_risk + 35;
    v_indicators := v_indicators || jsonb_build_array(jsonb_build_object(
      'rule', 'METADATA_TAMPERING',
      'severity', 'critical',
      'message', 'ONYO: Metadata ya picha imeonyesha dalili za kubadilishwa (WARNING: Image metadata shows signs of tampering)'
    ));
  END IF;

  -- Cap risk score at 100
  v_risk := LEAST(v_risk, 100);

  -- Build summary
  IF v_risk >= 70 THEN
    v_summary := 'HATARI KUBWA: Hati hii ina dalili nyingi za udanganyifu. Inahitaji uchunguzi wa haraka. (HIGH RISK: Document shows multiple fraud indicators. Requires immediate investigation.)';
  ELSIF v_risk >= 40 THEN
    v_summary := 'HATARI YA WASTANI: Hati hii ina dalili za mashaka. Inahitaji ukaguzi. (MEDIUM RISK: Document shows suspicious indicators. Requires review.)';
  ELSIF v_risk > 0 THEN
    v_summary := 'HATARI NDOGO: Dalili ndogo zimepatikana. (LOW RISK: Minor indicators found.)';
  ELSE
    v_summary := 'SAFI: Hakuna dalili za udanganyifu zilizopatikana. (CLEAN: No fraud indicators found.)';
  END IF;

  -- Update the scan record
  UPDATE asset_ocr_scans SET
    fraud_risk_score = v_risk,
    fraud_analysis_status = CASE
      WHEN v_risk >= 70 THEN 'fraudulent'
      WHEN v_risk >= 40 THEN 'suspicious'
      ELSE 'clean'
    END,
    fraud_indicators = v_indicators,
    fraud_analysis_details = jsonb_build_object(
      'analyzed_at', now(),
      'risk_score', v_risk,
      'summary', v_summary,
      'rules_checked', 5
    ),
    is_duplicate = (v_dup_count > 0)
  WHERE id = p_scan_id;

  -- If risk is high, create fraud alert
  IF v_risk >= 40 THEN
    INSERT INTO fraud_alerts (
      alert_type, severity, fraud_score, detection_method,
      evidence, status, detected_at
    ) VALUES (
      'ocr_document_fraud',
      CASE WHEN v_risk >= 70 THEN 'critical' ELSE 'high' END,
      v_risk,
      'ai_ocr_analysis',
      jsonb_build_object(
        'scan_id', p_scan_id,
        'asset_id', v_scan.asset_id,
        'indicators', v_indicators,
        'summary', v_summary
      ),
      'open',
      now()
    );
  END IF;

  -- Also update the parent asset's fraud status if linked
  IF v_scan.asset_id IS NOT NULL AND v_risk >= 40 THEN
    UPDATE company_assets SET
      fraud_check_status = CASE WHEN v_risk >= 70 THEN 'flagged' ELSE 'investigating' END,
      fraud_risk_score = GREATEST(fraud_risk_score, v_risk)
    WHERE id = v_scan.asset_id;
  ELSIF v_scan.asset_id IS NOT NULL THEN
    UPDATE company_assets SET
      fraud_check_status = 'clean',
      ocr_verified = TRUE,
      ocr_verification_id = p_scan_id
    WHERE id = v_scan.asset_id AND fraud_check_status = 'pending';
  END IF;

  RETURN QUERY SELECT p_scan_id, v_risk, (v_risk >= 40), v_indicators, v_summary;
END;
$$;

-- Function 4: Technology Health Dashboard Summary
CREATE OR REPLACE FUNCTION fn_tech_health_dashboard()
RETURNS TABLE(
  overall_health VARCHAR,
  total_components BIGINT,
  healthy_count BIGINT,
  degraded_count BIGINT,
  critical_count BIGINT,
  offline_count BIGINT,
  avg_uptime NUMERIC,
  avg_response_time INT,
  active_alerts BIGINT,
  components_detail JSONB
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  WITH latest_snapshots AS (
    SELECT DISTINCT ON (component_name)
      *
    FROM tech_monitoring_snapshots
    ORDER BY component_name, checked_at DESC
  )
  SELECT
    CASE
      WHEN COUNT(*) FILTER (WHERE ls.health_status = 'critical') > 0 THEN 'critical'::VARCHAR
      WHEN COUNT(*) FILTER (WHERE ls.health_status = 'degraded') > 0 THEN 'degraded'::VARCHAR
      WHEN COUNT(*) FILTER (WHERE ls.health_status = 'offline') > 0 THEN 'warning'::VARCHAR
      ELSE 'healthy'::VARCHAR
    END AS overall_health,
    COUNT(*)::BIGINT AS total_components,
    COUNT(*) FILTER (WHERE ls.health_status = 'healthy')::BIGINT AS healthy_count,
    COUNT(*) FILTER (WHERE ls.health_status = 'degraded')::BIGINT AS degraded_count,
    COUNT(*) FILTER (WHERE ls.health_status = 'critical')::BIGINT AS critical_count,
    COUNT(*) FILTER (WHERE ls.health_status = 'offline')::BIGINT AS offline_count,
    COALESCE(AVG(ls.uptime_percentage), 0)::NUMERIC AS avg_uptime,
    COALESCE(AVG(ls.response_time_ms), 0)::INT AS avg_response_time,
    (SELECT COUNT(*) FROM alert_logs WHERE status = 'open' OR status IS NULL)::BIGINT AS active_alerts,
    (SELECT jsonb_agg(jsonb_build_object(
      'name', ls2.component_name,
      'type', ls2.snapshot_type,
      'status', ls2.health_status,
      'uptime', ls2.uptime_percentage,
      'response_time', ls2.response_time_ms,
      'cpu', ls2.cpu_usage_percent,
      'memory', ls2.memory_usage_percent,
      'disk', ls2.disk_usage_percent,
      'last_check', ls2.checked_at
    )) FROM latest_snapshots ls2) AS components_detail
  FROM latest_snapshots ls;
END;
$$;

-- Function 5: Register new company asset with auto OCR trigger
CREATE OR REPLACE FUNCTION fn_register_company_asset(
  p_asset_name VARCHAR,
  p_asset_category VARCHAR,
  p_serial_number VARCHAR DEFAULT NULL,
  p_registration_number VARCHAR DEFAULT NULL,
  p_purchase_date DATE DEFAULT CURRENT_DATE,
  p_purchase_price NUMERIC DEFAULT 0,
  p_useful_life_years INT DEFAULT 5,
  p_depreciation_method VARCHAR DEFAULT 'straight_line',
  p_location_description VARCHAR DEFAULT NULL,
  p_assigned_department VARCHAR DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_photo_url TEXT DEFAULT NULL
)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_asset_id UUID;
  v_tag VARCHAR(50);
  v_salvage NUMERIC;
BEGIN
  -- Generate asset tag: CAT-YYYYMM-XXXX
  v_tag := UPPER(LEFT(p_asset_category, 3)) || '-' ||
           TO_CHAR(CURRENT_DATE, 'YYYYMM') || '-' ||
           LPAD(FLOOR(RANDOM() * 9999 + 1)::TEXT, 4, '0');

  -- Calculate salvage value (10% of purchase price)
  v_salvage := p_purchase_price * 0.10;

  INSERT INTO company_assets (
    asset_tag, asset_name, asset_category, serial_number,
    registration_number, purchase_date, purchase_price,
    useful_life_years, salvage_value, depreciation_method,
    annual_depreciation_rate, location_description,
    assigned_department, description, photo_url, created_by
  ) VALUES (
    v_tag, p_asset_name, p_asset_category, p_serial_number,
    p_registration_number, p_purchase_date, p_purchase_price,
    p_useful_life_years, v_salvage, p_depreciation_method,
    CASE WHEN p_depreciation_method = 'declining_balance' THEN 20.0
         WHEN p_depreciation_method = 'straight_line' AND p_useful_life_years > 0 THEN (100.0 / p_useful_life_years)
         ELSE 0 END,
    p_location_description, p_assigned_department, p_description,
    p_photo_url, auth.uid()
  )
  RETURNING id INTO v_asset_id;

  RETURN v_asset_id;
END;
$$;

-- Function 6: GPS Fleet Tracking Summary
CREATE OR REPLACE FUNCTION fn_fleet_gps_summary()
RETURNS TABLE(
  total_vehicles BIGINT,
  active_tracking BIGINT,
  immobilized BIGINT,
  offline BIGINT,
  vehicle_locations JSONB
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::BIGINT,
    COUNT(*) FILTER (WHERE ft.current_gps_state = 'active')::BIGINT,
    COUNT(*) FILTER (WHERE ft.is_immobilized = TRUE)::BIGINT,
    COUNT(*) FILTER (WHERE ft.current_gps_state = 'offline' OR ft.last_ping_time < now() - INTERVAL '1 hour')::BIGINT,
    jsonb_agg(jsonb_build_object(
      'vehicle_id', ft.vehicle_id,
      'imei', ft.gps_device_imei,
      'lat', ft.last_location_lat,
      'lng', ft.last_location_long,
      'state', ft.current_gps_state,
      'immobilized', ft.is_immobilized,
      'last_ping', ft.last_ping_time
    )) AS vehicle_locations
  FROM fin_iot_tracking ft;
END;
$$;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_company_assets_updated
  BEFORE UPDATE ON company_assets
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_maintenance_updated
  BEFORE UPDATE ON asset_maintenance_records
  FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- Trigger: Auto-run fraud analysis after OCR completes
CREATE OR REPLACE FUNCTION fn_auto_fraud_check_on_ocr()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.ocr_status = 'completed' AND OLD.ocr_status != 'completed' THEN
    PERFORM fn_ocr_fraud_analysis(NEW.id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auto_fraud_check
  AFTER UPDATE ON asset_ocr_scans
  FOR EACH ROW EXECUTE FUNCTION fn_auto_fraud_check_on_ocr();

-- Trigger: Alert on overdue maintenance
CREATE OR REPLACE FUNCTION fn_maintenance_overdue_alert()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'scheduled' AND NEW.scheduled_date < CURRENT_DATE THEN
    INSERT INTO system_alerts (alert_type, message, severity)
    VALUES (
      'maintenance_overdue',
      format('Matengenezo ya mali %s yamechelewa (Maintenance for asset overdue)', NEW.asset_id),
      'warning'
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_maintenance_overdue
  AFTER INSERT OR UPDATE ON asset_maintenance_records
  FOR EACH ROW EXECUTE FUNCTION fn_maintenance_overdue_alert();

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION fn_calculate_asset_depreciation TO authenticated;
GRANT EXECUTE ON FUNCTION fn_company_asset_kpis TO authenticated;
GRANT EXECUTE ON FUNCTION fn_ocr_fraud_analysis TO authenticated;
GRANT EXECUTE ON FUNCTION fn_tech_health_dashboard TO authenticated;
GRANT EXECUTE ON FUNCTION fn_register_company_asset TO authenticated;
GRANT EXECUTE ON FUNCTION fn_fleet_gps_summary TO authenticated;
