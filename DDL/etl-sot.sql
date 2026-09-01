-- ============================================================
-- SOT FRAMEWORK
-- PostgreSQL DDL
-- ============================================================


-- ============================================================
-- 1. SOT SYSTEMS
-- ============================================================

CREATE TABLE sot_systems (
    system_id BIGSERIAL PRIMARY KEY,

    system_code VARCHAR(50) NOT NULL UNIQUE,

    system_name VARCHAR(100) NOT NULL,

    system_type VARCHAR(30) NOT NULL,

    description TEXT,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP
);

COMMENT ON TABLE sot_systems IS
'Master system yang terlibat dalam framework Source of Truth.';

COMMENT ON COLUMN sot_systems.system_type IS
'APPLICATION, DATABASE, REPORTING, EXTERNAL';


-- ============================================================
-- 2. SOT MODULES
-- ============================================================

CREATE TABLE sot_modules (
    module_id BIGSERIAL PRIMARY KEY,

    module_code VARCHAR(50) NOT NULL UNIQUE,

    module_name VARCHAR(100) NOT NULL,

    description TEXT,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP
);

COMMENT ON TABLE sot_modules IS
'Master domain atau modul bisnis yang digunakan oleh proses SOT.';


-- ============================================================
-- 3. SOT BUSINESS PROCESSES
-- ============================================================

CREATE TABLE sot_business_processes (
    process_id BIGSERIAL PRIMARY KEY,

    module_id BIGINT NOT NULL,

    process_code VARCHAR(100) NOT NULL UNIQUE,

    process_name VARCHAR(150) NOT NULL,

    description TEXT,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    CONSTRAINT fk_sot_business_processes_module
        FOREIGN KEY (module_id)
        REFERENCES sot_modules(module_id)
);

COMMENT ON TABLE sot_business_processes IS
'Master proses bisnis yang dikontrol atau terlibat dalam framework SOT.';


CREATE INDEX idx_sot_business_processes_module
    ON sot_business_processes(module_id);


-- ============================================================
-- 4. SOT DATA ENTITIES
-- ============================================================

CREATE TABLE sot_data_entities (
    entity_id BIGSERIAL PRIMARY KEY,

    entity_code VARCHAR(100) NOT NULL UNIQUE,

    entity_name VARCHAR(150) NOT NULL,

    description TEXT,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP
);

COMMENT ON TABLE sot_data_entities IS
'Definisi logical business entity yang dikelola oleh framework SOT.';



-- ============================================================
-- 6. SOT ENTITY TABLES
-- ============================================================

CREATE TABLE sot_entity_tables (
    entity_table_id BIGSERIAL PRIMARY KEY,

    entity_id BIGINT NOT NULL,

    system_id BIGINT NOT NULL,

    schema_name VARCHAR(100) NOT NULL,

    table_name VARCHAR(150) NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    CONSTRAINT fk_sot_entity_tables_entity
        FOREIGN KEY (entity_id)
        REFERENCES sot_data_entities(entity_id),

    CONSTRAINT fk_sot_entity_tables_system
        FOREIGN KEY (system_id)
        REFERENCES sot_systems(system_id),

    CONSTRAINT uq_sot_entity_tables
        UNIQUE (system_id, schema_name, table_name)
);

COMMENT ON TABLE sot_entity_tables IS
'Mapping logical data entity ke physical table pada masing-masing system.';


CREATE INDEX idx_sot_entity_tables_entity
    ON sot_entity_tables(entity_id);

CREATE INDEX idx_sot_entity_tables_system
    ON sot_entity_tables(system_id);


-- ============================================================
-- 7. SOT SOURCE OF TRUTH
-- ============================================================

CREATE TABLE sot_config (
    sot_id BIGSERIAL PRIMARY KEY,

    entity_id BIGINT NOT NULL,

    process_id BIGINT NOT NULL,

    source_system_id BIGINT NOT NULL,

    target_system_id BIGINT,

    sync_direction VARCHAR(20) NOT NULL,

    sync_mode VARCHAR(20) NOT NULL,

    status VARCHAR(20) NOT NULL,

    effective_from DATE NOT NULL,

    cutover_at TIMESTAMP,

    notes VARCHAR(255),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    updated_by VARCHAR(50),

    CONSTRAINT fk_sot_sot_entity
        FOREIGN KEY (entity_id)
        REFERENCES sot_data_entities(entity_id),

    CONSTRAINT fk_sot_sot_process
        FOREIGN KEY (process_id)
        REFERENCES sot_business_processes(process_id),

    CONSTRAINT fk_sot_sot_source_system
        FOREIGN KEY (source_system_id)
        REFERENCES sot_systems(system_id),

    CONSTRAINT fk_sot_sot_target_system
        FOREIGN KEY (target_system_id)
        REFERENCES sot_systems(system_id),

    CONSTRAINT uq_sot_config
        UNIQUE (entity_id, effective_from)
);

COMMENT ON TABLE sot_config IS
'Konfigurasi Source of Truth untuk menentukan system yang menjadi sumber kebenaran data dan arah sinkronisasi.';

COMMENT ON COLUMN sot_config.sync_direction IS
'LEGACY_TO_NEW, NEW_TO_LEGACY, BIDIRECTIONAL, NONE';

COMMENT ON COLUMN sot_config.sync_mode IS
'CDC, API, BATCH, MANUAL';

COMMENT ON COLUMN sot_config.status IS
'MIGRATING, COMPLETED, PAUSED';


CREATE INDEX idx_sot_sot_process
    ON sot_config(process_id);

CREATE INDEX idx_sot_sot_source_system
    ON sot_config(source_system_id);

CREATE INDEX idx_sot_sot_target_system
    ON sot_config(target_system_id);

CREATE INDEX idx_sot_sot_entity
    ON sot_config(entity_id);

CREATE INDEX idx_sot_sot_status
    ON sot_config(status);