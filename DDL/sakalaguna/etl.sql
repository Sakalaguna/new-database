-- sakalaguna, schema etl — the ETL engine's own machinery inside the new DB.
-- Own schema, outside the team's mochan namespace: cross-DB transactional
-- atomicity is impossible anywhere else, so the outbox row commits WITH the
-- business write; pg_notify is only the doorbell.

CREATE SCHEMA IF NOT EXISTS etl;

CREATE TABLE IF NOT EXISTS etl.outbox (
  outbox_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  table_name TEXT        NOT NULL,
  op         TEXT        NOT NULL,
  row_id     TEXT        NOT NULL,
  row_data   JSONB       NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION etl.notify_outbox() RETURNS trigger AS $$
DECLARE
  v_row jsonb;
  v_id  text;
BEGIN
  v_row := to_jsonb(COALESCE(NEW, OLD));
  v_id  := COALESCE(v_row ->> TG_ARGV[0], '');
  INSERT INTO etl.outbox (table_name, op, row_id, row_data)
  VALUES (TG_TABLE_NAME, TG_OP, v_id, v_row);
  PERFORM pg_notify(
    'etl_changes',
    jsonb_build_object('table', TG_TABLE_NAME, 'op', TG_OP, 'id', v_id, 'row', v_row)::text
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- One trigger per reverse-synced table; the argument is that table's PK column.
-- Live on master_operator; add a table's line when its reverse sync turns on:
-- CREATE TRIGGER trg_etl_notify AFTER INSERT OR UPDATE OR DELETE ON mochan.master_supplier_sub
--     FOR EACH ROW EXECUTE FUNCTION etl.notify_outbox('supplier_sub_id');
-- CREATE TRIGGER trg_etl_notify AFTER INSERT OR UPDATE OR DELETE ON mochan.master_supplier_sub_ledger
--     FOR EACH ROW EXECUTE FUNCTION etl.notify_outbox('supplier_sub_ledger_id');

-- The function runs with INVOKER rights: every role writing mochan.* needs
-- USAGE on schema etl + INSERT on etl.outbox (sakala verified; grant any other
-- team writer roles the same).
