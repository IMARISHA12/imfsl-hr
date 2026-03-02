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
