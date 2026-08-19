INSERT INTO systems
    (system_code, system_name, system_type, description, status)
VALUES
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



INSERT INTO business_processes
    (module_id, process_code, process_name, description, status)
SELECT
    m.module_id,
    p.process_code,
    p.process_name,
    p.description,
    'ACTIVE'
FROM modules m
CROSS JOIN (
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
) AS p(process_code, process_name, description)
WHERE m.module_code = 'MASTER_DATA'
  AND m.system_id = (
      SELECT system_id
      FROM systems
      WHERE system_code = 'ISAT'
  );


INSERT INTO data_entities
    (entity_code, entity_name, description, status)
VALUES
    (
        'OPERATOR',
        'Operator',
        'Master data operator dari system ISAT.',
        'ACTIVE'
    ),
    (
        'PRODUCT',
        'Product',
        'Master data product dari system ISAT.',
        'ACTIVE'
    ),
    (
        'RESELLER',
        'Reseller',
        'Master data reseller dari system ISAT.',
        'ACTIVE'
    ),
    (
        'SUPPLIER',
        'Supplier',
        'Master data supplier dari system ISAT.',
        'ACTIVE'
    ),
    (
        'TERMINAL',
        'Terminal',
        'Master data terminal dari system ISAT.',
        'ACTIVE'
    );


INSERT INTO process_systems
    (
        process_id,
        system_id,
        role,
        sequence_no,
        is_required,
        status
    )
SELECT
    bp.process_id,
    s.system_id,
    ps.role,
    ps.sequence_no,
    ps.is_required,
    'ACTIVE'
FROM (
    VALUES
        ('OPERATOR_MANAGEMENT', 'ISAT',     'SOT',    1, true),
        ('OPERATOR_MANAGEMENT', 'POSTGRES', 'TARGET', 2, true),

        ('PRODUCT_MANAGEMENT', 'ISAT',     'SOT',    1, true),
        ('PRODUCT_MANAGEMENT', 'POSTGRES', 'TARGET', 2, true),

        ('RESELLER_MANAGEMENT', 'ISAT',     'SOT',    1, true),
        ('RESELLER_MANAGEMENT', 'POSTGRES', 'TARGET', 2, true),

        ('SUPPLIER_MANAGEMENT', 'ISAT',     'SOT',    1, true),
        ('SUPPLIER_MANAGEMENT', 'POSTGRES', 'TARGET', 2, true),

        ('TERMINAL_MANAGEMENT', 'ISAT',     'SOT',    1, true),
        ('TERMINAL_MANAGEMENT', 'POSTGRES', 'TARGET', 2, true)
) AS ps(process_code, system_code, role, sequence_no, is_required)
JOIN business_processes bp
    ON bp.process_code = ps.process_code
JOIN systems s
    ON s.system_code = ps.system_code;


INSERT INTO entity_tables
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
FROM (
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
) AS t(
    entity_code,
    system_code,
    schema_name,
    table_name,
    is_primary
)
JOIN data_entities e
    ON e.entity_code = t.entity_code
JOIN systems s
    ON s.system_code = t.system_code;


INSERT INTO source_of_truth
(
    entity_code,
    process_id,
    source_system_code,
    target_system_code,
    sync_direction,
    sync_mode,
    status,
    effective_from,
    notes
)
SELECT
    sot.entity_code,
    bp.process_id,
    'ISAT',
    'POSTGRES',
    'LEGACY_TO_NEW',
    'API',
    'MIGRATING',
    CURRENT_DATE,
    sot.notes
FROM (
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
) AS sot(
    entity_code,
    process_code,
    notes
)
JOIN business_processes bp
    ON bp.process_code = sot.process_code;