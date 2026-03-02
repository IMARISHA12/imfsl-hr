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
