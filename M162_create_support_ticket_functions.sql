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
