-- Ensure the raw_borrowers table has the unique constraint the Edge Function depends on.
-- This is idempotent — safe to run multiple times.

DO $$
BEGIN
  -- Add unique constraint on (external_id, provider) if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'raw_borrowers_external_id_provider_key'
  ) THEN
    BEGIN
      ALTER TABLE raw_borrowers
        ADD CONSTRAINT raw_borrowers_external_id_provider_key
        UNIQUE (external_id, provider);
    EXCEPTION WHEN undefined_column THEN
      RAISE NOTICE 'raw_borrowers table may not have external_id/provider columns yet';
    END;
  END IF;

  -- Add unique constraint on clients.external_reference_id if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'clients_external_reference_id_key'
  ) THEN
    BEGIN
      ALTER TABLE clients
        ADD CONSTRAINT clients_external_reference_id_key
        UNIQUE (external_reference_id);
    EXCEPTION WHEN undefined_column THEN
      RAISE NOTICE 'clients table may not have external_reference_id column yet';
    END;
  END IF;
END
$$;
