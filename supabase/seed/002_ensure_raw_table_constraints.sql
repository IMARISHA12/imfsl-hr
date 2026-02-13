-- Verify existing constraints the Edge Function depends on.
-- raw_borrowers already has: UNIQUE(loandisk_id, branch_id)
-- clients does NOT have a unique constraint on external_reference_id,
-- so the Edge Function uses a select-then-insert/update pattern.
--
-- This file is kept as documentation. No DDL changes needed.

DO $$
BEGIN
  -- Verify raw_borrowers constraint exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'raw_borrowers_loandisk_id_branch_id_key'
  ) THEN
    RAISE WARNING 'raw_borrowers_loandisk_id_branch_id_key constraint is MISSING — Edge Function upsert will fail';
  ELSE
    RAISE NOTICE 'raw_borrowers_loandisk_id_branch_id_key constraint OK';
  END IF;
END
$$;
