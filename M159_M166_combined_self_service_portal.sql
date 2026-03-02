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
-- M162: create_support_ticket_functions
-- 5 stored procedures for support ticket management

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_create_support_ticket
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_create_support_ticket(
  p_customer_id UUID,
  p_category VARCHAR,
  p_subject VARCHAR,
  p_message TEXT,
  p_related_loan_id UUID DEFAULT NULL,
  p_related_transaction_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_ticket_number VARCHAR(20);
  v_ticket_id UUID;
  v_seq INT;
  v_result JSONB;
BEGIN
  -- Generate ticket number: TKT-YYYYMMDD-NNNN
  SELECT COALESCE(MAX(
    CAST(SUBSTRING(ticket_number FROM 14) AS INT)
  ), 0) + 1
  INTO v_seq
  FROM imfsl_support_tickets
  WHERE ticket_number LIKE 'TKT-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-%';

  v_ticket_number := 'TKT-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(v_seq::TEXT, 4, '0');

  -- Create ticket
  INSERT INTO imfsl_support_tickets (
    customer_id, ticket_number, category, subject,
    related_loan_id, related_transaction_id
  ) VALUES (
    p_customer_id, v_ticket_number, p_category, p_subject,
    p_related_loan_id, p_related_transaction_id
  )
  RETURNING id INTO v_ticket_id;

  -- Add initial message
  INSERT INTO imfsl_support_ticket_messages (
    ticket_id, sender_type, sender_id, message
  ) VALUES (
    v_ticket_id, 'CUSTOMER', p_customer_id, p_message
  );

  -- Return ticket
  SELECT jsonb_build_object(
    'id', t.id,
    'ticket_number', t.ticket_number,
    'category', t.category,
    'subject', t.subject,
    'status', t.status,
    'priority', t.priority,
    'created_at', t.created_at
  ) INTO v_result
  FROM imfsl_support_tickets t
  WHERE t.id = v_ticket_id;

  RETURN v_result;
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_add_ticket_message
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_add_ticket_message(
  p_ticket_id UUID,
  p_sender_type VARCHAR,
  p_sender_id UUID,
  p_message TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_ticket_status VARCHAR;
  v_msg_id UUID;
BEGIN
  -- Check ticket exists and is not closed
  SELECT status INTO v_ticket_status
  FROM imfsl_support_tickets WHERE id = p_ticket_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ticket not found';
  END IF;

  IF v_ticket_status = 'CLOSED' THEN
    RAISE EXCEPTION 'Cannot add message to a closed ticket';
  END IF;

  -- Insert message
  INSERT INTO imfsl_support_ticket_messages (
    ticket_id, sender_type, sender_id, message
  ) VALUES (
    p_ticket_id, p_sender_type, p_sender_id, p_message
  )
  RETURNING id INTO v_msg_id;

  -- Update ticket timestamp
  UPDATE imfsl_support_tickets
  SET updated_at = NOW()
  WHERE id = p_ticket_id;

  RETURN jsonb_build_object(
    'id', v_msg_id,
    'ticket_id', p_ticket_id,
    'sender_type', p_sender_type,
    'message', p_message,
    'created_at', NOW()
  );
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_get_customer_tickets
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_get_customer_tickets(
  p_customer_id UUID,
  p_status VARCHAR DEFAULT NULL,
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', t.id,
      'ticket_number', t.ticket_number,
      'category', t.category,
      'subject', t.subject,
      'status', t.status,
      'priority', t.priority,
      'assigned_staff_id', t.assigned_staff_id,
      'created_at', t.created_at,
      'updated_at', t.updated_at,
      'message_count', (SELECT COUNT(*) FROM imfsl_support_ticket_messages m WHERE m.ticket_id = t.id),
      'last_message_at', (SELECT MAX(m.created_at) FROM imfsl_support_ticket_messages m WHERE m.ticket_id = t.id)
    ) AS row_data,
    t.created_at
    FROM imfsl_support_tickets t
    WHERE t.customer_id = p_customer_id
      AND (p_status IS NULL OR t.status = p_status)
    ORDER BY t.created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) sub;

  RETURN v_result;
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_get_ticket_detail
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_get_ticket_detail(
  p_ticket_id UUID,
  p_customer_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_ticket JSONB;
  v_messages JSONB;
BEGIN
  -- Get ticket (with optional customer ownership check)
  SELECT jsonb_build_object(
    'id', t.id,
    'ticket_number', t.ticket_number,
    'category', t.category,
    'subject', t.subject,
    'status', t.status,
    'priority', t.priority,
    'related_loan_id', t.related_loan_id,
    'related_transaction_id', t.related_transaction_id,
    'assigned_staff_id', t.assigned_staff_id,
    'resolved_at', t.resolved_at,
    'resolution_notes', t.resolution_notes,
    'created_at', t.created_at,
    'updated_at', t.updated_at
  ) INTO v_ticket
  FROM imfsl_support_tickets t
  WHERE t.id = p_ticket_id
    AND (p_customer_id IS NULL OR t.customer_id = p_customer_id);

  IF v_ticket IS NULL THEN
    RAISE EXCEPTION 'Ticket not found or access denied';
  END IF;

  -- Get messages
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', m.id,
      'sender_type', m.sender_type,
      'sender_id', m.sender_id,
      'message', m.message,
      'created_at', m.created_at
    ) ORDER BY m.created_at ASC
  ), '[]'::JSONB)
  INTO v_messages
  FROM imfsl_support_ticket_messages m
  WHERE m.ticket_id = p_ticket_id;

  RETURN v_ticket || jsonb_build_object('messages', v_messages);
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_admin_manage_ticket
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_admin_manage_ticket(
  p_ticket_id UUID,
  p_action VARCHAR,
  p_staff_id UUID,
  p_notes TEXT DEFAULT NULL,
  p_priority VARCHAR DEFAULT NULL,
  p_assigned_to UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_ticket imfsl_support_tickets%ROWTYPE;
BEGIN
  SELECT * INTO v_ticket FROM imfsl_support_tickets WHERE id = p_ticket_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ticket not found';
  END IF;

  CASE p_action
    WHEN 'assign' THEN
      UPDATE imfsl_support_tickets
      SET assigned_staff_id = COALESCE(p_assigned_to, p_staff_id),
          status = CASE WHEN status = 'OPEN' THEN 'IN_PROGRESS' ELSE status END,
          updated_at = NOW()
      WHERE id = p_ticket_id;

      -- System message
      INSERT INTO imfsl_support_ticket_messages (ticket_id, sender_type, sender_id, message)
      VALUES (p_ticket_id, 'SYSTEM', p_staff_id,
        'Ticket assigned to staff member.');

    WHEN 'update_status' THEN
      IF p_notes IS NULL THEN
        RAISE EXCEPTION 'Status value required in notes parameter';
      END IF;
      UPDATE imfsl_support_tickets
      SET status = p_notes, updated_at = NOW()
      WHERE id = p_ticket_id;

    WHEN 'update_priority' THEN
      IF p_priority IS NULL THEN
        RAISE EXCEPTION 'Priority value required';
      END IF;
      UPDATE imfsl_support_tickets
      SET priority = p_priority, updated_at = NOW()
      WHERE id = p_ticket_id;

    WHEN 'resolve' THEN
      UPDATE imfsl_support_tickets
      SET status = 'RESOLVED',
          resolved_at = NOW(),
          resolved_by = p_staff_id,
          resolution_notes = p_notes,
          updated_at = NOW()
      WHERE id = p_ticket_id;

      INSERT INTO imfsl_support_ticket_messages (ticket_id, sender_type, sender_id, message)
      VALUES (p_ticket_id, 'SYSTEM', p_staff_id,
        'Ticket resolved: ' || COALESCE(p_notes, 'No notes'));

    WHEN 'close' THEN
      UPDATE imfsl_support_tickets
      SET status = 'CLOSED', updated_at = NOW()
      WHERE id = p_ticket_id;

      INSERT INTO imfsl_support_ticket_messages (ticket_id, sender_type, sender_id, message)
      VALUES (p_ticket_id, 'SYSTEM', p_staff_id, 'Ticket closed.');

    ELSE
      RAISE EXCEPTION 'Unknown action: %', p_action;
  END CASE;

  -- Return updated ticket
  RETURN (SELECT jsonb_build_object(
    'id', t.id,
    'ticket_number', t.ticket_number,
    'status', t.status,
    'priority', t.priority,
    'assigned_staff_id', t.assigned_staff_id,
    'resolved_at', t.resolved_at,
    'updated_at', t.updated_at
  ) FROM imfsl_support_tickets t WHERE t.id = p_ticket_id);
END;
$$;
-- M163: create_savings_withdrawal_functions
-- 3 stored procedures for savings withdrawal management

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_request_savings_withdrawal
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_request_savings_withdrawal(
  p_customer_id UUID,
  p_savings_account_id UUID,
  p_amount NUMERIC,
  p_channel VARCHAR DEFAULT 'MPESA',
  p_destination_phone VARCHAR DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_account imfsl_savings_accounts%ROWTYPE;
  v_withdrawal_number VARCHAR(20);
  v_withdrawal_id UUID;
  v_seq INT;
  v_rows_updated INT;
BEGIN
  -- Validate account ownership and status
  SELECT * INTO v_account
  FROM imfsl_savings_accounts
  WHERE id = p_savings_account_id AND customer_id = p_customer_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Savings account not found or does not belong to customer';
  END IF;

  IF v_account.status != 'ACTIVE' THEN
    RAISE EXCEPTION 'Savings account is not active (status: %)', v_account.status;
  END IF;

  -- Atomically check and reduce available_balance (prevents race conditions)
  UPDATE imfsl_savings_accounts
  SET available_balance = available_balance - p_amount,
      updated_at = NOW()
  WHERE id = p_savings_account_id
    AND customer_id = p_customer_id
    AND available_balance >= p_amount;

  GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

  IF v_rows_updated = 0 THEN
    RAISE EXCEPTION 'Insufficient available balance for withdrawal of %', p_amount;
  END IF;

  -- Generate withdrawal number: WDR-YYYYMMDD-NNNN
  SELECT COALESCE(MAX(
    CAST(SUBSTRING(withdrawal_number FROM 14) AS INT)
  ), 0) + 1
  INTO v_seq
  FROM imfsl_savings_withdrawals
  WHERE withdrawal_number LIKE 'WDR-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-%';

  v_withdrawal_number := 'WDR-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(v_seq::TEXT, 4, '0');

  -- Create withdrawal record
  INSERT INTO imfsl_savings_withdrawals (
    customer_id, savings_account_id, withdrawal_number,
    amount, channel, destination_phone, status
  ) VALUES (
    p_customer_id, p_savings_account_id, v_withdrawal_number,
    p_amount, p_channel, p_destination_phone, 'PENDING'
  )
  RETURNING id INTO v_withdrawal_id;

  RETURN jsonb_build_object(
    'id', v_withdrawal_id,
    'withdrawal_number', v_withdrawal_number,
    'amount', p_amount,
    'channel', p_channel,
    'status', 'PENDING',
    'created_at', NOW()
  );
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_process_savings_withdrawal
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_process_savings_withdrawal(
  p_withdrawal_id UUID,
  p_staff_id UUID,
  p_action VARCHAR,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_withdrawal imfsl_savings_withdrawals%ROWTYPE;
BEGIN
  SELECT * INTO v_withdrawal
  FROM imfsl_savings_withdrawals
  WHERE id = p_withdrawal_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Withdrawal not found';
  END IF;

  IF v_withdrawal.status != 'PENDING' THEN
    RAISE EXCEPTION 'Withdrawal is not in PENDING status (current: %)', v_withdrawal.status;
  END IF;

  CASE p_action
    WHEN 'APPROVE' THEN
      UPDATE imfsl_savings_withdrawals
      SET status = 'APPROVED',
          approved_by = p_staff_id,
          approved_at = NOW(),
          updated_at = NOW()
      WHERE id = p_withdrawal_id;

      -- Note: For MPESA channel, the edge function will trigger B2C disbursement
      -- and update status to PROCESSING → COMPLETED/FAILED via callback

    WHEN 'REJECT' THEN
      -- Restore available_balance
      UPDATE imfsl_savings_accounts
      SET available_balance = available_balance + v_withdrawal.amount,
          updated_at = NOW()
      WHERE id = v_withdrawal.savings_account_id;

      UPDATE imfsl_savings_withdrawals
      SET status = 'REJECTED',
          rejection_reason = p_reason,
          updated_at = NOW()
      WHERE id = p_withdrawal_id;

    ELSE
      RAISE EXCEPTION 'Unknown action: %. Use APPROVE or REJECT', p_action;
  END CASE;

  RETURN (SELECT jsonb_build_object(
    'id', w.id,
    'withdrawal_number', w.withdrawal_number,
    'amount', w.amount,
    'status', w.status,
    'approved_by', w.approved_by,
    'approved_at', w.approved_at,
    'rejection_reason', w.rejection_reason,
    'updated_at', w.updated_at
  ) FROM imfsl_savings_withdrawals w WHERE w.id = p_withdrawal_id);
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_get_customer_withdrawals
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_get_customer_withdrawals(
  p_customer_id UUID,
  p_status VARCHAR DEFAULT NULL,
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', w.id,
      'withdrawal_number', w.withdrawal_number,
      'amount', w.amount,
      'channel', w.channel,
      'destination_phone', w.destination_phone,
      'status', w.status,
      'rejection_reason', w.rejection_reason,
      'completed_at', w.completed_at,
      'created_at', w.created_at,
      'account_number', sa.account_number,
      'product_name', sp.product_name
    ) AS row_data,
    w.created_at
    FROM imfsl_savings_withdrawals w
    JOIN imfsl_savings_accounts sa ON sa.id = w.savings_account_id
    LEFT JOIN imfsl_savings_products sp ON sp.id = sa.product_id
    WHERE w.customer_id = p_customer_id
      AND (p_status IS NULL OR w.status = p_status)
    ORDER BY w.created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) sub;

  RETURN v_result;
END;
$$;
-- M164: create_guarantor_self_service_functions
-- 4 stored procedures for guarantor self-service management

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_get_my_guarantor_commitments
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_get_my_guarantor_commitments(
  p_customer_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', g.id,
      'loan_id', g.loan_id,
      'borrower_name', c.full_name,
      'guarantee_amount', g.guarantee_amount,
      'relationship', g.relationship,
      'customer_response', g.customer_response,
      'responded_at', g.responded_at,
      'loan_number', l.loan_number,
      'loan_amount', l.principal_amount,
      'loan_status', l.status,
      'created_at', g.created_at
    ) AS row_data,
    g.created_at
    FROM imfsl_guarantors g
    JOIN imfsl_loans l ON l.id = g.loan_id
    JOIN customers c ON c.id = l.customer_id
    WHERE g.guarantor_customer_id = p_customer_id
    ORDER BY g.created_at DESC
  ) sub;

  RETURN v_result;
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_respond_to_guarantor_request
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_respond_to_guarantor_request(
  p_guarantor_id UUID,
  p_customer_id UUID,
  p_response VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_guarantor imfsl_guarantors%ROWTYPE;
BEGIN
  IF p_response NOT IN ('ACCEPTED', 'DECLINED') THEN
    RAISE EXCEPTION 'Response must be ACCEPTED or DECLINED';
  END IF;

  SELECT * INTO v_guarantor
  FROM imfsl_guarantors
  WHERE id = p_guarantor_id AND guarantor_customer_id = p_customer_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Guarantor record not found or does not belong to customer';
  END IF;

  IF v_guarantor.customer_response IS NOT NULL AND v_guarantor.customer_response != 'PENDING' THEN
    RAISE EXCEPTION 'Already responded to this guarantor request';
  END IF;

  UPDATE imfsl_guarantors
  SET customer_response = p_response,
      responded_at = NOW()
  WHERE id = p_guarantor_id;

  RETURN jsonb_build_object(
    'id', p_guarantor_id,
    'customer_response', p_response,
    'responded_at', NOW()
  );
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_get_my_guarantor_invites
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_get_my_guarantor_invites(
  p_customer_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_phone VARCHAR;
  v_national_id VARCHAR;
  v_result JSONB;
BEGIN
  -- Get customer phone and national_id for matching
  SELECT phone_number, national_id
  INTO v_phone, v_national_id
  FROM customers
  WHERE id = p_customer_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Customer not found';
  END IF;

  -- Find unlinked guarantor records matching by phone or national_id
  SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', g.id,
      'loan_id', g.loan_id,
      'borrower_name', c.full_name,
      'guarantee_amount', g.guarantee_amount,
      'relationship', g.relationship,
      'guarantor_name', g.guarantor_name,
      'guarantor_phone', g.phone_number,
      'loan_number', l.loan_number,
      'loan_amount', l.principal_amount,
      'created_at', g.created_at
    ) AS row_data,
    g.created_at
    FROM imfsl_guarantors g
    JOIN imfsl_loans l ON l.id = g.loan_id
    JOIN customers c ON c.id = l.customer_id
    WHERE g.guarantor_customer_id IS NULL
      AND (
        (v_phone IS NOT NULL AND g.phone_number = v_phone)
        OR (v_national_id IS NOT NULL AND g.national_id = v_national_id)
      )
    ORDER BY g.created_at DESC
  ) sub;

  RETURN v_result;
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_link_guarantor_to_customer
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_link_guarantor_to_customer(
  p_guarantor_id UUID,
  p_customer_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_phone VARCHAR;
  v_national_id VARCHAR;
  v_guarantor imfsl_guarantors%ROWTYPE;
BEGIN
  -- Get customer identifiers
  SELECT phone_number, national_id
  INTO v_phone, v_national_id
  FROM customers
  WHERE id = p_customer_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Customer not found';
  END IF;

  -- Verify the guarantor record matches and is unlinked
  SELECT * INTO v_guarantor
  FROM imfsl_guarantors
  WHERE id = p_guarantor_id
    AND guarantor_customer_id IS NULL
    AND (
      (v_phone IS NOT NULL AND phone_number = v_phone)
      OR (v_national_id IS NOT NULL AND national_id = v_national_id)
    );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Guarantor record not found, already linked, or does not match customer';
  END IF;

  -- Link the record
  UPDATE imfsl_guarantors
  SET guarantor_customer_id = p_customer_id,
      customer_response = 'PENDING'
  WHERE id = p_guarantor_id;

  RETURN jsonb_build_object(
    'id', p_guarantor_id,
    'guarantor_customer_id', p_customer_id,
    'customer_response', 'PENDING',
    'message', 'Guarantor record linked. Please accept or decline.'
  );
END;
$$;
-- M165: create_customer_restructure_request_function
-- 2 stored procedures for customer-initiated loan restructure requests

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_customer_request_restructure
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_customer_request_restructure(
  p_customer_id UUID,
  p_loan_id UUID,
  p_restructure_type VARCHAR,
  p_reason TEXT,
  p_requested_term INT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_loan imfsl_loans%ROWTYPE;
  v_existing_pending INT;
  v_restructure_id UUID;
  v_new_terms JSONB;
BEGIN
  -- Validate loan ownership and status
  SELECT * INTO v_loan
  FROM imfsl_loans
  WHERE id = p_loan_id AND customer_id = p_customer_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Loan not found or does not belong to customer';
  END IF;

  IF v_loan.status NOT IN ('ACTIVE', 'OVERDUE') THEN
    RAISE EXCEPTION 'Only ACTIVE or OVERDUE loans can be restructured (current: %)', v_loan.status;
  END IF;

  -- Check for existing pending restructure
  SELECT COUNT(*) INTO v_existing_pending
  FROM imfsl_loan_restructures
  WHERE loan_id = p_loan_id AND status = 'PENDING';

  IF v_existing_pending > 0 THEN
    RAISE EXCEPTION 'A pending restructure request already exists for this loan';
  END IF;

  -- Validate restructure type
  IF p_restructure_type NOT IN ('EXTENSION', 'REFINANCE', 'RESCHEDULING') THEN
    RAISE EXCEPTION 'Invalid restructure type. Use: EXTENSION, REFINANCE, or RESCHEDULING';
  END IF;

  -- Build new_terms JSONB
  v_new_terms := jsonb_build_object(
    'restructure_type', p_restructure_type,
    'reason', p_reason,
    'requested_by', 'CUSTOMER',
    'original_term', v_loan.tenure_months,
    'outstanding_balance', v_loan.outstanding_balance
  );

  IF p_requested_term IS NOT NULL THEN
    v_new_terms := v_new_terms || jsonb_build_object('requested_term', p_requested_term);
  END IF;

  -- Create restructure request (triggers existing approval workflow via trigger)
  INSERT INTO imfsl_loan_restructures (
    loan_id, restructure_type, new_terms, reason, status
  ) VALUES (
    p_loan_id, p_restructure_type, v_new_terms, p_reason, 'PENDING'
  )
  RETURNING id INTO v_restructure_id;

  RETURN jsonb_build_object(
    'id', v_restructure_id,
    'loan_id', p_loan_id,
    'restructure_type', p_restructure_type,
    'status', 'PENDING',
    'message', 'Restructure request submitted for approval',
    'created_at', NOW()
  );
END;
$$;

-- ══════════════════════════════════════════════════════════════════════
-- fn_imfsl_get_customer_restructure_requests
-- ══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION fn_imfsl_get_customer_restructure_requests(
  p_customer_id UUID,
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', r.id,
      'loan_id', r.loan_id,
      'loan_number', l.loan_number,
      'restructure_type', r.restructure_type,
      'reason', r.reason,
      'new_terms', r.new_terms,
      'status', r.status,
      'created_at', r.created_at,
      'outstanding_balance', l.outstanding_balance,
      'approval_progress', (
        SELECT jsonb_build_object(
          'current_step', COALESCE(MAX(s.step_number), 0),
          'total_steps', (
            SELECT ar.required_levels
            FROM imfsl_approval_rules ar
            WHERE ar.entity_type = 'RESTRUCTURE'
              AND ar.is_active = true
            ORDER BY ar.priority DESC
            LIMIT 1
          )
        )
        FROM imfsl_approval_steps s
        WHERE s.entity_type = 'RESTRUCTURE'
          AND s.entity_id = r.id
          AND s.decision = 'APPROVED'
      )
    ) AS row_data,
    r.created_at
    FROM imfsl_loan_restructures r
    JOIN imfsl_loans l ON l.id = r.loan_id
    WHERE l.customer_id = p_customer_id
    ORDER BY r.created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) sub;

  RETURN v_result;
END;
$$;
-- M166: grant_execute_and_rls
-- GRANT EXECUTE on all new functions + Retool anon read policies

-- ══════════════════════════════════════════════════════════════════════
-- GRANT EXECUTE
-- ══════════════════════════════════════════════════════════════════════

-- Support ticket functions
GRANT EXECUTE ON FUNCTION fn_imfsl_create_support_ticket(UUID, VARCHAR, VARCHAR, TEXT, UUID, UUID) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_add_ticket_message(UUID, VARCHAR, UUID, TEXT) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_get_customer_tickets(UUID, VARCHAR, INT, INT) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_get_ticket_detail(UUID, UUID) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_admin_manage_ticket(UUID, VARCHAR, UUID, TEXT, VARCHAR, UUID) TO authenticated, service_role;

-- Savings withdrawal functions
GRANT EXECUTE ON FUNCTION fn_imfsl_request_savings_withdrawal(UUID, UUID, NUMERIC, VARCHAR, VARCHAR) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_process_savings_withdrawal(UUID, UUID, VARCHAR, TEXT) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_get_customer_withdrawals(UUID, VARCHAR, INT, INT) TO authenticated, service_role;

-- Guarantor self-service functions
GRANT EXECUTE ON FUNCTION fn_imfsl_get_my_guarantor_commitments(UUID) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_respond_to_guarantor_request(UUID, UUID, VARCHAR) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_get_my_guarantor_invites(UUID) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_link_guarantor_to_customer(UUID, UUID) TO authenticated, service_role;

-- Customer restructure functions
GRANT EXECUTE ON FUNCTION fn_imfsl_customer_request_restructure(UUID, UUID, VARCHAR, TEXT, INT) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION fn_imfsl_get_customer_restructure_requests(UUID, INT, INT) TO authenticated, service_role;

-- ══════════════════════════════════════════════════════════════════════
-- Retool anon read policies (for Retool dashboards)
-- ══════════════════════════════════════════════════════════════════════

CREATE POLICY retool_anon_read_support_tickets ON imfsl_support_tickets
  FOR SELECT TO anon USING (true);

CREATE POLICY retool_anon_read_ticket_messages ON imfsl_support_ticket_messages
  FOR SELECT TO anon USING (true);

CREATE POLICY retool_anon_read_savings_withdrawals ON imfsl_savings_withdrawals
  FOR SELECT TO anon USING (true);

-- ══════════════════════════════════════════════════════════════════════
-- Update imfsl_guarantors RLS for customer self-service
-- ══════════════════════════════════════════════════════════════════════

-- Allow customers to read guarantor records linked to them
CREATE POLICY guarantors_customer_self_service_select ON imfsl_guarantors
  FOR SELECT TO authenticated
  USING (
    guarantor_customer_id IN (
      SELECT id FROM customers
      WHERE auth_user_id = (SELECT auth.uid())
    )
  );
