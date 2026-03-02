-- M161: alter_guarantors_add_customer_columns
-- Adds self-service columns to imfsl_guarantors for customer management

ALTER TABLE imfsl_guarantors
  ADD COLUMN IF NOT EXISTS customer_response VARCHAR(20)
    CHECK (customer_response IN ('PENDING', 'ACCEPTED', 'DECLINED'));

ALTER TABLE imfsl_guarantors
  ADD COLUMN IF NOT EXISTS responded_at TIMESTAMPTZ;

ALTER TABLE imfsl_guarantors
  ADD COLUMN IF NOT EXISTS guarantor_customer_id UUID REFERENCES customers(id);

-- Index for self-service lookups
CREATE INDEX IF NOT EXISTS idx_guarantors_customer_id
  ON imfsl_guarantors(guarantor_customer_id);
