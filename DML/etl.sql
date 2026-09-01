INSERT INTO sot_systems
(
    system_code,
    system_name,
    system_type,
    description,
    status
)
VALUES
(
    'DTR',
    'DTR',
    'APPLICATION',
    'System DTR.',
    'ACTIVE'
),
(
    'POS',
    'POS',
    'APPLICATION',
    'System POS.',
    'ACTIVE'
),
(
    'ISAT',
    'ISAT',
    'APPLICATION',
    'System ISAT sebagai source system dan Source of Truth pada fase migrasi awal.',
    'ACTIVE'
),
(
    'POSTGRES',
    'PostgreSQL Sakalaguna',
    'DATABASE',
    'Database PostgreSQL baru Sakalaguna sebagai target migrasi.',
    'ACTIVE'
);


INSERT INTO sot_modules
(
    module_code,
    module_name,
    description,
    status
)
VALUES
(
    'MASTER_DATA',
    'Master Data',
    'Modul untuk pengelolaan master data yang digunakan dalam proses migrasi dan sinkronisasi antar system.',
    'ACTIVE'
);

INSERT INTO sot_business_processes
(
    module_id,
    process_code,
    process_name,
    description,
    status
)
SELECT
    m.module_id,
    p.process_code,
    p.process_name,
    p.description,
    'ACTIVE'
FROM sot_modules m
CROSS JOIN
(
    VALUES
    (
        'OPERATOR_MANAGEMENT',
        'Operator Management',
        'Pengelolaan master data operator.'
    ),
    (
        'PRODUCT_MANAGEMENT',
        'Product Management',
        'Pengelolaan master data product.'
    ),
    (
        'RESELLER_MANAGEMENT',
        'Reseller Management',
        'Pengelolaan master data reseller.'
    ),
    (
        'SUPPLIER_MANAGEMENT',
        'Supplier Management',
        'Pengelolaan master data supplier.'
    ),
    (
        'TERMINAL_MANAGEMENT',
        'Terminal Management',
        'Pengelolaan master data terminal.'
    )
) AS p
(
    process_code,
    process_name,
    description
)
WHERE m.module_code = 'MASTER_DATA';


INSERT INTO sot_data_entities
(
    entity_code,
    entity_name,
    description,
    status
)
VALUES
(
    'OPERATOR',
    'Operator',
    'Logical entity untuk master operator.',
    'ACTIVE'
),
(
    'PRODUCT',
    'Product',
    'Logical entity untuk master product.',
    'ACTIVE'
),
(
    'RESELLER',
    'Reseller',
    'Logical entity untuk master reseller.',
    'ACTIVE'
),
(
    'SUPPLIER',
    'Supplier',
    'Logical entity untuk master supplier.',
    'ACTIVE'
),
(
    'TERMINAL',
    'Terminal',
    'Logical entity untuk master terminal.',
    'ACTIVE'
);



INSERT INTO sot_entity_tables
(
    entity_id,
    system_id,
    schema_name,
    table_name,
    is_primary,
    status
)
SELECT
    e.entity_id,
    s.system_id,
    t.schema_name,
    t.table_name,
    t.is_primary,
    'ACTIVE'
FROM
(
    VALUES
    ('OPERATOR',  'ISAT',     'dbo',    'tirs_Operator',       true),
    ('OPERATOR',  'POSTGRES', 'public', 'master_operator',     true),

    ('PRODUCT',   'ISAT',     'dbo',    'tirs_Produk',         true),
    ('PRODUCT',   'POSTGRES', 'public', 'master_product',       true),

    ('RESELLER',  'ISAT',     'dbo',    'tirs_MasterReseller', true),
    ('RESELLER',  'POSTGRES', 'public', 'master_reseller',      true),

    ('SUPPLIER',  'ISAT',     'dbo',    'tirs_Suplier',         true),
    ('SUPPLIER',  'POSTGRES', 'public', 'master_supplier',       true),

    ('TERMINAL',  'ISAT',     'dbo',    'tirs_Terminal',        true),
    ('TERMINAL',  'POSTGRES', 'public', 'master_terminal',      true)
) AS t
(
    entity_code,
    system_code,
    schema_name,
    table_name,
    is_primary
)
JOIN sot_data_entities e
    ON e.entity_code = t.entity_code
JOIN sot_systems s
    ON s.system_code = t.system_code;


INSERT INTO sot_config
(
    entity_id,
    process_id,
    source_system_id,
    target_system_id,
    sync_direction,
    sync_mode,
    status,
    effective_from,
    notes
)
SELECT
    e.entity_id,
    bp.process_id,
    src.system_id,
    tgt.system_id,
    'LEGACY_TO_NEW',
    'API',
    'MIGRATING',
    CURRENT_DATE,
    x.notes
FROM
(
    VALUES
    (
        'OPERATOR',
        'OPERATOR_MANAGEMENT',
        'Migrasi master operator dari ISAT ke PostgreSQL.'
    ),
    (
        'PRODUCT',
        'PRODUCT_MANAGEMENT',
        'Migrasi master product dari ISAT ke PostgreSQL.'
    ),
    (
        'RESELLER',
        'RESELLER_MANAGEMENT',
        'Migrasi master reseller dari ISAT ke PostgreSQL.'
    ),
    (
        'SUPPLIER',
        'SUPPLIER_MANAGEMENT',
        'Migrasi master supplier dari ISAT ke PostgreSQL.'
    ),
    (
        'TERMINAL',
        'TERMINAL_MANAGEMENT',
        'Migrasi master terminal dari ISAT ke PostgreSQL.'
    )
) AS x
(
    entity_code,
    process_code,
    notes
)
JOIN sot_data_entities e
    ON e.entity_code = x.entity_code
JOIN sot_business_processes bp
    ON bp.process_code = x.process_code
JOIN sot_systems src
    ON src.system_code = 'ISAT'
JOIN sot_systems tgt
    ON tgt.system_code = 'POSTGRES';


== Query Report ==

SELECT
    sot.sot_id,
    e.entity_code,
    e.entity_name,
    bp.process_code,
    bp.process_name,
    src.system_code AS source_system,
    src_tbl.schema_name AS source_schema,
    src_tbl.table_name AS source_table,
    tgt.system_code AS target_system,
    tgt_tbl.schema_name AS target_schema,
    tgt_tbl.table_name AS target_table,
    sot.sync_direction,
    sot.sync_mode,
    sot.status,
    sot.effective_from,
    sot.cutover_at,
    sot.notes
FROM sot_config sot
JOIN sot_data_entities e
    ON e.entity_id = sot.entity_id
JOIN sot_business_processes bp
    ON bp.process_id = sot.process_id
JOIN sot_systems src
    ON src.system_id = sot.source_system_id
LEFT JOIN sot_systems tgt
    ON tgt.system_id = sot.target_system_id
LEFT JOIN sot_entity_tables src_tbl
    ON src_tbl.entity_id = sot.entity_id
    AND src_tbl.system_id = sot.source_system_id
    AND src_tbl.is_primary = true
LEFT JOIN sot_entity_tables tgt_tbl
    ON tgt_tbl.entity_id = sot.entity_id
    AND tgt_tbl.system_id = sot.target_system_id
    AND tgt_tbl.is_primary = true
ORDER BY
    e.entity_code;