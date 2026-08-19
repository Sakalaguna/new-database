-- =========================================================
-- 1. SYSTEMS
-- =========================================================

CREATE TABLE systems (
    system_id BIGSERIAL PRIMARY KEY,
    system_code VARCHAR(50) NOT NULL UNIQUE,
    system_name VARCHAR(100) NOT NULL,
    system_type VARCHAR(30) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

COMMENT ON TABLE systems IS
'Master system yang terlibat dalam arsitektur ERP dan proses migrasi.';

COMMENT ON COLUMN systems.system_type IS
'APPLICATION, DATABASE, REPORTING, EXTERNAL';


-- =========================================================
-- 2. MODULES
-- =========================================================

CREATE TABLE modules (
    module_id BIGSERIAL PRIMARY KEY,
    system_id BIGINT NOT NULL,
    module_code VARCHAR(50) NOT NULL,
    module_name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_modules_system
        FOREIGN KEY (system_id)
        REFERENCES systems(system_id),

    CONSTRAINT uq_modules_system_code
        UNIQUE (system_id, module_code)
);

COMMENT ON TABLE modules IS
'Master modul yang dimiliki oleh suatu system.';


-- =========================================================
-- 3. BUSINESS PROCESSES
-- =========================================================

CREATE TABLE business_processes (
    process_id BIGSERIAL PRIMARY KEY,
    module_id BIGINT NOT NULL,
    process_code VARCHAR(100) NOT NULL UNIQUE,
    process_name VARCHAR(150) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_business_processes_module
        FOREIGN KEY (module_id)
        REFERENCES modules(module_id)
);

COMMENT ON TABLE business_processes IS
'Master proses bisnis yang dijalankan oleh suatu modul.';


-- =========================================================
-- 4. DATA ENTITIES
-- =========================================================

CREATE TABLE data_entities (
    entity_id BIGSERIAL PRIMARY KEY,
    entity_code VARCHAR(100) NOT NULL UNIQUE,
    entity_name VARCHAR(150) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

COMMENT ON TABLE data_entities IS
'Definisi logical business entity yang dikelola oleh system.';


-- =========================================================
-- 5. PROCESS SYSTEMS
-- =========================================================

CREATE TABLE process_systems (
    process_system_id BIGSERIAL PRIMARY KEY,
    process_id BIGINT NOT NULL,
    system_id BIGINT NOT NULL,
    role VARCHAR(30) NOT NULL,
    sequence_no INT NOT NULL DEFAULT 1,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_process_systems_process
        FOREIGN KEY (process_id)
        REFERENCES business_processes(process_id),

    CONSTRAINT fk_process_systems_system
        FOREIGN KEY (system_id)
        REFERENCES systems(system_id),

    CONSTRAINT uq_process_systems
        UNIQUE (process_id, system_id)
);

COMMENT ON TABLE process_systems IS
'Mapping system yang terlibat dalam suatu business process.';

COMMENT ON COLUMN process_systems.role IS
'SOT, SOURCE, TARGET, VALIDATOR, REPORTING';


-- =========================================================
-- 6. ENTITY TABLES
-- =========================================================

CREATE TABLE entity_tables (
    entity_table_id BIGSERIAL PRIMARY KEY,
    entity_id BIGINT NOT NULL,
    system_id BIGINT NOT NULL,
    schema_name VARCHAR(100),
    table_name VARCHAR(150) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_entity_tables_entity
        FOREIGN KEY (entity_id)
        REFERENCES data_entities(entity_id),

    CONSTRAINT fk_entity_tables_system
        FOREIGN KEY (system_id)
        REFERENCES systems(system_id),

    CONSTRAINT uq_entity_tables_system_table
        UNIQUE (system_id, schema_name, table_name)
);

COMMENT ON TABLE entity_tables IS
'Mapping logical data entity ke physical table pada masing-masing system.';


-- =========================================================
-- 7. SOURCE OF TRUTH
-- =========================================================

CREATE TABLE source_of_truth (
    sot_id BIGSERIAL PRIMARY KEY,

    entity_code VARCHAR(100) NOT NULL,

    process_id BIGINT NOT NULL,

    source_system_code VARCHAR(50),
    target_system_code VARCHAR(50),

    sync_direction VARCHAR(20) NOT NULL,

    sync_mode VARCHAR(20) NOT NULL,

    status VARCHAR(20) NOT NULL,

    effective_from DATE NOT NULL,

    cutover_at TIMESTAMP,

    notes VARCHAR(255),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    updated_by VARCHAR(50),

    CONSTRAINT fk_sot_entity
        FOREIGN KEY (entity_code)
        REFERENCES data_entities(entity_code),

    CONSTRAINT fk_sot_process
        FOREIGN KEY (process_id)
        REFERENCES business_processes(process_id),

    CONSTRAINT fk_sot_source_system
        FOREIGN KEY (source_system_code)
        REFERENCES systems(system_code),

    CONSTRAINT fk_sot_target_system
        FOREIGN KEY (target_system_code)
        REFERENCES systems(system_code),

    CONSTRAINT uq_sot_entity_effective
        UNIQUE (entity_code, effective_from)
);

COMMENT ON TABLE source_of_truth IS
'Table untuk menyimpan konfigurasi Source of Truth dan arah sinkronisasi data.';

COMMENT ON COLUMN source_of_truth.entity_code IS
'Identitas data yang dikontrol. Contoh: OPERATOR, SUPPLIER, PRODUCT.';

COMMENT ON COLUMN source_of_truth.process_id IS
'Proses bisnis yang mengontrol data.';

COMMENT ON COLUMN source_of_truth.sync_direction IS
'LEGACY_TO_NEW, NEW_TO_LEGACY, BIDIRECTIONAL, NONE';

COMMENT ON COLUMN source_of_truth.sync_mode IS
'Contoh: CDC, API, BATCH, MANUAL';

COMMENT ON COLUMN source_of_truth.status IS
'MIGRATING, COMPLETED, PAUSED';


-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX idx_process_systems_process
    ON process_systems(process_id);

CREATE INDEX idx_process_systems_system
    ON process_systems(system_id);

CREATE INDEX idx_entity_tables_entity
    ON entity_tables(entity_id);

CREATE INDEX idx_entity_tables_system
    ON entity_tables(system_id);

CREATE INDEX idx_sot_source_system
    ON source_of_truth(source_system_code);

CREATE INDEX idx_sot_target_system
    ON source_of_truth(target_system_code);

CREATE INDEX idx_sot_process
    ON source_of_truth(process_id);

CREATE INDEX idx_sot_entity
    ON source_of_truth(entity_code);