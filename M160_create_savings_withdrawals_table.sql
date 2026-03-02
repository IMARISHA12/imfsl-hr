-- M160: create_savings_withdrawals_table
-- Creates savings withdrawal request table for customer self-service withdrawals

CREATE TABLE IF NOT EXISTS imfsl_savings_withdrawals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES customers(id),
  savings_account_id UUID NOT NULL REFERENCES imfsl_savings_accounts(id),
  withdrawal_number VARCHAR(20) NOT NULL UNIQUE,
  amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  channel VARCHAR(20) NOT NULL DEFAULT 'MPESA' CHECK (channel IN ('MPESA', 'BANK', 'CASH')),
  destination_phone VARCHAR(20),
  destination_bank_account VARCHAR(50),
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
    'PENDING', 'APPROVED', 'PROCESSING', 'COMPLETED', 'FAILED', 'REJECTED'
  )),
  mpesa_disbursement_id UUID REFERENCES mpesa_disbursements(id),
  approved_by UUID REFERENCES staff(id),
  approved_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════
-- INDEXES
-- ══════════════════════════════════════════════════════════════════════

CREATE INDEX idx_savings_withdrawals_customer ON imfsl_savings_withdrawals(customer_id);
CREATE INDEX idx_savings_withdrawals_account ON imfsl_savings_withdrawals(savings_account_id);
CREATE INDEX idx_savings_withdrawals_status ON imfsl_savings_withdrawals(status);
CREATE INDEX idx_savings_withdrawals_number ON imfsl_savings_withdrawals(withdrawal_number);

-- ══════════════════════════════════════════════════════════════════════
-- RLS
-- ══════════════════════════════════════════════════════════════════════

ALTER TABLE imfsl_savings_withdrawals ENABLE ROW LEVEL SECURITY;

-- Customers see own withdrawals
CREATE POLICY withdrawals_customer_select ON imfsl_savings_withdrawals
  FOR SELECT TO authenticated
  USING (
    customer_id IN (
      SELECT id FROM customers
      WHERE auth_user_id = (SELECT auth.uid())
    )
  );

-- Staff see all withdrawals
CREATE POLICY withdrawals_staff_select ON imfsl_savings_withdrawals
  FOR SELECT TO authenticated
  USING (
    (SELECT fn_current_staff_system_role()) IN ('ADMIN', 'MANAGER', 'OFFICER', 'TELLER')
  );

-- Service role full access
CREATE POLICY withdrawals_service_all ON imfsl_savings_withdrawals
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);
