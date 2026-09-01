-- public.etl_cdc_bookmark definition

-- Drop table

-- DROP TABLE public.etl_cdc_bookmark;

CREATE TABLE public.etl_cdc_bookmark (
	source_system_id int8 NOT NULL,
	capture_name varchar(100) NOT NULL,
	last_lsn varchar(30) NOT NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT etl_cdc_bookmark_pkey PRIMARY KEY (source_system_id, capture_name)
);


-- public.etl_id_crosswalk definition

-- Drop table

-- DROP TABLE public.etl_id_crosswalk;

CREATE TABLE public.etl_id_crosswalk (
	crosswalk_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	entity_code varchar(100) NOT NULL,
	legacy_system_id int8 NOT NULL,
	legacy_id varchar(100) NOT NULL,
	new_system_id int8 NOT NULL,
	new_id int8 NOT NULL,
	is_canonical bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamptz NULL,
	CONSTRAINT etl_id_crosswalk_entity_code_legacy_system_id_legacy_id_key UNIQUE (entity_code, legacy_system_id, legacy_id),
	CONSTRAINT etl_id_crosswalk_pkey PRIMARY KEY (crosswalk_id)
);
CREATE INDEX idx_id_crosswalk_new ON public.etl_id_crosswalk USING btree (entity_code, new_system_id, new_id);


-- public.etl_job_run definition

-- Drop table

-- DROP TABLE public.etl_job_run;

CREATE TABLE public.etl_job_run (
	job_run_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	"trigger_type" public."trigger_type" NOT NULL,
	process_code varchar(100) NULL,
	entity_code varchar(100) NULL,
	status public."run_status" DEFAULT 'RUNNING'::run_status NOT NULL,
	rows_read int8 DEFAULT 0 NOT NULL,
	rows_written int8 DEFAULT 0 NOT NULL,
	error_text text NULL,
	requested_by varchar(50) NULL,
	started_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	finished_at timestamptz NULL,
	CONSTRAINT etl_job_run_pkey PRIMARY KEY (job_run_id)
);
CREATE INDEX idx_run_process ON public.etl_job_run USING btree (process_code);
CREATE INDEX idx_run_started_desc ON public.etl_job_run USING btree (started_at DESC, job_run_id DESC);
CREATE INDEX idx_run_status ON public.etl_job_run USING btree (status);


-- public.etl_row_queue definition

-- Drop table

-- DROP TABLE public.etl_row_queue;

CREATE TABLE public.etl_row_queue (
	row_queue_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	entity_code varchar(100) NOT NULL,
	row_id varchar(100) NOT NULL,
	operation public."queue_operation" NOT NULL,
	origin_system_id int8 NOT NULL,
	payload jsonb NULL,
	status public."queue_status" DEFAULT 'PENDING'::queue_status NOT NULL,
	attempt_count int4 DEFAULT 0 NOT NULL,
	job_run_id int8 NULL,
	source_updated_at timestamptz NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	processed_at timestamptz NULL,
	claimed_at timestamptz NULL,
	CONSTRAINT etl_row_queue_pkey PRIMARY KEY (row_queue_id)
);
CREATE INDEX idx_queue_entity_row ON public.etl_row_queue USING btree (entity_code, row_id);
CREATE INDEX idx_queue_run ON public.etl_row_queue USING btree (job_run_id);
CREATE INDEX idx_queue_status ON public.etl_row_queue USING btree (status);


-- public.sot_data_entities definition

-- Drop table

-- DROP TABLE public.sot_data_entities;

CREATE TABLE public.sot_data_entities (
	data_entity_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	entity_code varchar(100) NOT NULL,
	entity_name varchar(150) NOT NULL,
	description text NULL,
	status public."registry_status" DEFAULT 'ACTIVE'::registry_status NOT NULL,
	"delete_policy" public."delete_policy" DEFAULT 'SOFT'::delete_policy NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamptz NULL,
	CONSTRAINT sot_data_entities_entity_code_key UNIQUE (entity_code),
	CONSTRAINT sot_data_entities_pkey PRIMARY KEY (data_entity_id)
);


-- public.sot_modules definition

-- Drop table

-- DROP TABLE public.sot_modules;

CREATE TABLE public.sot_modules (
	module_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	module_code varchar(50) NOT NULL,
	module_name varchar(100) NOT NULL,
	description text NULL,
	status public."registry_status" DEFAULT 'ACTIVE'::registry_status NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamptz NULL,
	CONSTRAINT sot_modules_module_code_key UNIQUE (module_code),
	CONSTRAINT sot_modules_pkey PRIMARY KEY (module_id)
);


-- public.sot_systems definition

-- Drop table

-- DROP TABLE public.sot_systems;

CREATE TABLE public.sot_systems (
	system_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	system_code varchar(50) NOT NULL,
	system_name varchar(100) NOT NULL,
	system_type varchar(30) NOT NULL,
	description text NULL,
	status public."registry_status" DEFAULT 'ACTIVE'::registry_status NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamptz NULL,
	CONSTRAINT sot_systems_pkey PRIMARY KEY (system_id),
	CONSTRAINT sot_systems_system_code_key UNIQUE (system_code)
);


-- public.sot_business_processes definition

-- Drop table

-- DROP TABLE public.sot_business_processes;

CREATE TABLE public.sot_business_processes (
	business_process_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	module_id int8 NOT NULL,
	process_code varchar(100) NOT NULL,
	process_name varchar(150) NOT NULL,
	description text NULL,
	status public."registry_status" DEFAULT 'ACTIVE'::registry_status NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamptz NULL,
	CONSTRAINT sot_business_processes_pkey PRIMARY KEY (business_process_id),
	CONSTRAINT sot_business_processes_process_code_key UNIQUE (process_code),
	CONSTRAINT sot_business_processes_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.sot_modules(module_id) ON DELETE CASCADE
);
CREATE INDEX idx_sot_business_processes_module ON public.sot_business_processes USING btree (module_id);


-- public.sot_config definition

-- Drop table

-- DROP TABLE public.sot_config;

CREATE TABLE public.sot_config (
	sot_config_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	data_entity_id int8 NOT NULL,
	business_process_id int8 NOT NULL,
	source_system_id int8 NOT NULL,
	target_system_id int8 NOT NULL,
	status public."sot_status" DEFAULT 'PLANNED'::sot_status NOT NULL,
	sequence_no int4 DEFAULT 1 NOT NULL,
	effective_from date NOT NULL,
	cutover_at timestamptz NULL,
	notes text NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamptz NULL,
	updated_by varchar(50) NULL,
	CONSTRAINT sot_config_data_entity_id_effective_from_key UNIQUE (data_entity_id, effective_from),
	CONSTRAINT sot_config_pkey PRIMARY KEY (sot_config_id),
	CONSTRAINT sot_config_business_process_id_fkey FOREIGN KEY (business_process_id) REFERENCES public.sot_business_processes(business_process_id) ON DELETE RESTRICT,
	CONSTRAINT sot_config_data_entity_id_fkey FOREIGN KEY (data_entity_id) REFERENCES public.sot_data_entities(data_entity_id) ON DELETE RESTRICT,
	CONSTRAINT sot_config_source_system_id_fkey FOREIGN KEY (source_system_id) REFERENCES public.sot_systems(system_id) ON DELETE RESTRICT,
	CONSTRAINT sot_config_target_system_id_fkey FOREIGN KEY (target_system_id) REFERENCES public.sot_systems(system_id) ON DELETE RESTRICT
);
CREATE INDEX idx_sot_config_process ON public.sot_config USING btree (business_process_id);
CREATE INDEX idx_sot_config_source_system ON public.sot_config USING btree (source_system_id);
CREATE INDEX idx_sot_config_status ON public.sot_config USING btree (status);
CREATE INDEX idx_sot_config_target_system ON public.sot_config USING btree (target_system_id);
CREATE UNIQUE INDEX uq_sot_config_one_in_force_per_entity ON public.sot_config USING btree (data_entity_id) WHERE (status = 'MIGRATING'::sot_status);


-- public.sot_entity_tables definition

-- Drop table

-- DROP TABLE public.sot_entity_tables;

CREATE TABLE public.sot_entity_tables (
	entity_table_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	data_entity_id int8 NOT NULL,
	system_id int8 NOT NULL,
	schema_name varchar(100) NOT NULL,
	table_name varchar(150) NOT NULL,
	is_primary bool DEFAULT false NOT NULL,
	status public."registry_status" DEFAULT 'ACTIVE'::registry_status NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamptz NULL,
	CONSTRAINT sot_entity_tables_pkey PRIMARY KEY (entity_table_id),
	CONSTRAINT sot_entity_tables_system_id_schema_name_table_name_key UNIQUE (system_id, schema_name, table_name),
	CONSTRAINT sot_entity_tables_data_entity_id_fkey FOREIGN KEY (data_entity_id) REFERENCES public.sot_data_entities(data_entity_id) ON DELETE CASCADE,
	CONSTRAINT sot_entity_tables_system_id_fkey FOREIGN KEY (system_id) REFERENCES public.sot_systems(system_id) ON DELETE CASCADE
);
CREATE INDEX idx_sot_entity_tables_entity ON public.sot_entity_tables USING btree (data_entity_id);
CREATE INDEX idx_sot_entity_tables_system ON public.sot_entity_tables USING btree (system_id);
CREATE UNIQUE INDEX uq_sot_entity_tables_one_primary ON public.sot_entity_tables USING btree (data_entity_id, system_id) WHERE is_primary;