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
