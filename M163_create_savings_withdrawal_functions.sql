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
