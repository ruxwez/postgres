-- A background worker loaded with shared_preload_libraries, not an extension.
SELECT assert_true(current_setting('pg_failover_slots.synchronize_slot_names', true) IS NOT NULL, 'pg_failover_slots: settings registered');
