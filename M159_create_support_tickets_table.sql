-- M159: create_support_tickets_table
-- Creates support tickets and ticket messages tables for customer self-service

-- ══════════════════════════════════════════════════════════════════════
-- TABLE: imfsl_support_tickets
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS imfsl_support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES customers(id),
  ticket_number VARCHAR(20) NOT NULL UNIQUE,
  category VARCHAR(50) NOT NULL CHECK (category IN (
    'LOAN_DISPUTE', 'PAYMENT_ISSUE', 'ACCOUNT_INQUIRY', 'M_PESA_PROBLEM',
    'KYC_ISSUE', 'GENERAL_INQUIRY', 'COMPLAINT', 'SAVINGS_ISSUE'
  )),
  subject VARCHAR(200) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN (
    'OPEN', 'IN_PROGRESS', 'WAITING_CUSTOMER', 'RESOLVED', 'CLOSED'
  )),
  priority VARCHAR(10) NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN (
    'LOW', 'MEDIUM', 'HIGH', 'URGENT'
  )),
  related_loan_id UUID REFERENCES imfsl_loans(id),
  related_transaction_id UUID REFERENCES mpesa_transactions(id),
  assigned_staff_id UUID REFERENCES staff(id),
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES staff(id),
  resolution_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════
-- TABLE: imfsl_support_ticket_messages
-- ══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS imfsl_support_ticket_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES imfsl_support_tickets(id),
  sender_type VARCHAR(10) NOT NULL CHECK (sender_type IN ('CUSTOMER', 'STAFF', 'SYSTEM')),
  sender_id UUID NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ══════════════════════════════════════════════════════════════════════
-- INDEXES
-- ══════════════════════════════════════════════════════════════════════

CREATE INDEX idx_support_tickets_customer_id ON imfsl_support_tickets(customer_id);
CREATE INDEX idx_support_tickets_status ON imfsl_support_tickets(status);
CREATE INDEX idx_support_tickets_category ON imfsl_support_tickets(category);
CREATE INDEX idx_support_tickets_ticket_number ON imfsl_support_tickets(ticket_number);
CREATE INDEX idx_support_tickets_assigned_staff ON imfsl_support_tickets(assigned_staff_id);
CREATE INDEX idx_support_ticket_msgs_ticket_created ON imfsl_support_ticket_messages(ticket_id, created_at);

-- ══════════════════════════════════════════════════════════════════════
-- RLS
-- ══════════════════════════════════════════════════════════════════════

ALTER TABLE imfsl_support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE imfsl_support_ticket_messages ENABLE ROW LEVEL SECURITY;

-- Customers see own tickets
CREATE POLICY support_tickets_customer_select ON imfsl_support_tickets
  FOR SELECT TO authenticated
  USING (
    customer_id IN (
      SELECT id FROM customers
      WHERE auth_user_id = (SELECT auth.uid())
    )
  );

-- Staff see all tickets based on role
CREATE POLICY support_tickets_staff_select ON imfsl_support_tickets
  FOR SELECT TO authenticated
  USING (
    (SELECT fn_current_staff_system_role()) IN ('ADMIN', 'MANAGER', 'OFFICER')
  );

-- Service role full access
CREATE POLICY support_tickets_service_all ON imfsl_support_tickets
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- Messages: customers see messages on their own tickets
CREATE POLICY ticket_messages_customer_select ON imfsl_support_ticket_messages
  FOR SELECT TO authenticated
  USING (
    ticket_id IN (
      SELECT t.id FROM imfsl_support_tickets t
      JOIN customers c ON c.id = t.customer_id
      WHERE c.auth_user_id = (SELECT auth.uid())
    )
  );

-- Messages: staff see all
CREATE POLICY ticket_messages_staff_select ON imfsl_support_ticket_messages
  FOR SELECT TO authenticated
  USING (
    (SELECT fn_current_staff_system_role()) IN ('ADMIN', 'MANAGER', 'OFFICER')
  );

-- Messages: service role full access
CREATE POLICY ticket_messages_service_all ON imfsl_support_ticket_messages
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);
