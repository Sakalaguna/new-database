-- mochan.daily_transaction_mutations definition

-- Drop table

-- DROP TABLE mochan.daily_transaction_mutations;

CREATE TABLE mochan.daily_transaction_mutations (
	mutation_date date NULL,
	supplier_name varchar(50) NULL,
	sub_supplier_name varchar(50) NULL,
	reseller_code varchar(20) NULL,
	reseller_name varchar(100) NULL,
	operator_name varchar(100) NULL,
	product_code varchar(20) NULL,
	product_name varchar(100) NULL,
	denomination int4 NULL,
	purchase_price numeric(19, 4) NULL,
	selling_price numeric(19, 4) NULL,
	discount numeric(19, 4) NULL,
	dat_amount numeric(19, 4) NULL,
	ar_ap_amount numeric(19, 4) NULL,
	net_amount numeric(19, 4) NULL,
	switching_fee numeric(19, 4) NULL,
	net_switching_amount numeric(19, 4) NULL,
	quantity int4 NULL,
	margin numeric(19, 4) NULL,
	sakala_selling_price numeric(19, 4) NULL,
	fee numeric(19, 4) NULL,
	fee_dpp numeric(19, 4) NULL,
	transaction_status varchar(20) NULL,
	terminal_code varchar(20) NULL,
	terminal_name varchar(50) NULL,
	sales_amount numeric(19, 4) NULL,
	cogs_amount numeric(19, 4) NULL,
	sales_margin numeric(19, 4) NULL,
	supplier_fee numeric(19, 4) NULL
);


-- mochan.data_migration_monitor_daily definition

-- Drop table

-- DROP TABLE mochan.data_migration_monitor_daily;

CREATE TABLE mochan.data_migration_monitor_daily (
	monitor_date date NOT NULL,
	hist_partner_row_count_legacy int8 DEFAULT 0 NOT NULL,
	hist_partner_amount_legacy numeric(19, 4) DEFAULT 0 NOT NULL,
	hist_balance_row_count_legacy int8 DEFAULT 0 NOT NULL,
	hist_balance_amount_legacy numeric(19, 4) DEFAULT 0 NOT NULL,
	hist_partner_row_count_new int8 DEFAULT 0 NOT NULL,
	hist_partner_amount_new numeric(19, 4) DEFAULT 0 NOT NULL,
	success_count_legacy int4 DEFAULT 0 NOT NULL,
	failed_count_legacy int4 DEFAULT 0 NOT NULL,
	pending_count_legacy int4 DEFAULT 0 NOT NULL,
	total_trx_legacy int4 DEFAULT 0 NOT NULL,
	success_count_new int4 DEFAULT 0 NOT NULL,
	failed_count_new int4 DEFAULT 0 NOT NULL,
	pending_count_new int4 DEFAULT 0 NOT NULL,
	total_trx_new int4 DEFAULT 0 NOT NULL,
	total_ppob_trx_legacy int4 DEFAULT 0 NOT NULL,
	total_ppob_trx_new int4 DEFAULT 0 NOT NULL,
	CONSTRAINT data_migration_monitor_daily_pkey PRIMARY KEY (monitor_date)
);


-- mochan.etl_watermark definition

-- Drop table

-- DROP TABLE mochan.etl_watermark;

CREATE TABLE mochan.etl_watermark (
	job_name varchar(100) NOT NULL,
	last_lsn varchar(128) NULL,
	last_processed_at timestamp NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT etl_watermark_pkey PRIMARY KEY (job_name)
);


-- mochan.master_operator definition

-- Drop table

-- DROP TABLE mochan.master_operator;

CREATE TABLE mochan.master_operator (
	operator_id int4 NOT NULL,
	operator_name varchar(100) NOT NULL,
	is_partitioned bool DEFAULT false NOT NULL,
	partition_cluster int4 NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT master_operator_pkey PRIMARY KEY (operator_id)
);

-- Table Triggers

create trigger trg_etl_notify after
insert
    or
delete
    or
update
    on
    mochan.master_operator for each row execute function etl.notify_outbox('operator_id');


-- mochan.master_supplier definition

-- Drop table

-- DROP TABLE mochan.master_supplier;

CREATE TABLE mochan.master_supplier (
	supplier_id int4 NOT NULL,
	supplier_name varchar(100) NOT NULL,
	address varchar(255) NULL,
	phone varchar(20) NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT master_supplier_pkey PRIMARY KEY (supplier_id)
);


-- mochan.master_terminal definition

-- Drop table

-- DROP TABLE mochan.master_terminal;

CREATE TABLE mochan.master_terminal (
	terminal_id int4 NOT NULL,
	terminal_name varchar(150) NOT NULL,
	terminal_type varchar(10) NULL,
	is_active bool DEFAULT true NOT NULL,
	last_log_at timestamp NULL,
	supplier_id int4 NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT master_terminal_pkey PRIMARY KEY (terminal_id)
);


-- mochan.payments definition

-- Drop table

-- DROP TABLE mochan.payments;

CREATE TABLE mochan.payments (
	payment_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	reseller_id int8 NOT NULL,
	payment_at timestamp NOT NULL,
	amount_due numeric(19, 4) NULL,
	amount_paid numeric(19, 4) NULL,
	notes varchar(255) NULL,
	settlement_status varchar(15) NULL,
	created_by_user_id varchar(36) NULL,
	payment_type varchar(20) NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT payments_pkey PRIMARY KEY (payment_id)
);


-- mochan.sync_definition definition

-- Drop table

-- DROP TABLE mochan.sync_definition;

CREATE TABLE mochan.sync_definition (
	job_name varchar(100) NOT NULL,
	source_name varchar(100) NOT NULL,
	source_sql text NOT NULL,
	watermark_column varchar(100) NULL,
	chunk_size int4 NOT NULL,
	enabled bool DEFAULT true NOT NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT sync_definition_pkey PRIMARY KEY (job_name)
);


-- mochan.transactions definition

-- Drop table

-- DROP TABLE mochan.transactions;

CREATE TABLE mochan.transactions (
	transaction_id int8 NOT NULL,
	reseller_id int8 NOT NULL,
	reseller_name varchar(100) NOT NULL,
	product_id int4 NULL,
	transaction_date date NOT NULL,
	transaction_time time NOT NULL,
	destination_account varchar(100) NULL,
	purchase_price numeric(19, 4) NULL,
	selling_price numeric(19, 4) NULL,
	transaction_type varchar(20) NULL,
	transaction_status int4 NULL,
	terminal_id int4 NULL,
	reseller_selling_price numeric(19, 4) NULL,
	notes varchar(512) NULL,
	serial_number varchar(255) NULL,
	retry_count int4 NULL,
	benchmark_selling_price numeric(19, 4) NULL,
	received_date date NULL,
	received_time time NULL,
	client_transaction_id varchar(40) NULL,
	opening_balance numeric(19, 4) NULL,
	closing_balance numeric(19, 4) NULL,
	stock_balance numeric(19, 4) NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id)
);


-- mochan.user_access_logs definition

-- Drop table

-- DROP TABLE mochan.user_access_logs;

CREATE TABLE mochan.user_access_logs (
	access_log_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	logged_at timestamp NOT NULL,
	user_id varchar(36) NOT NULL,
	description varchar(512) NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT user_access_logs_pkey PRIMARY KEY (access_log_id)
);


-- mochan.master_product definition

-- Drop table

-- DROP TABLE mochan.master_product;

CREATE TABLE mochan.master_product (
	product_id int4 NOT NULL,
	operator_id int4 NOT NULL,
	product_name varchar(255) NOT NULL,
	nominal_value int4 NULL,
	product_code varchar(20) NOT NULL,
	product_type varchar(20) NULL,
	is_out_of_stock bool DEFAULT false NOT NULL,
	is_disrupted bool DEFAULT false NOT NULL,
	available_start_time time NULL,
	available_end_time time NULL,
	notes varchar(150) NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT master_product_pkey PRIMARY KEY (product_id),
	CONSTRAINT master_product_product_code_key UNIQUE (product_code),
	CONSTRAINT fk_products_operator FOREIGN KEY (operator_id) REFERENCES mochan.master_operator(operator_id)
);


-- mochan.master_reseller definition

-- Drop table

-- DROP TABLE mochan.master_reseller;

CREATE TABLE mochan.master_reseller (
	reseller_id int8 NOT NULL,
	reseller_code varchar(16) NOT NULL,
	upline_reseller_id int8 NULL,
	reseller_name varchar(100) NOT NULL,
	address varchar(255) NULL,
	direct_commission_flag bool DEFAULT false NOT NULL,
	base_sell_price numeric(19, 4) NULL,
	personal_markup numeric(19, 4) NULL,
	upline_markup numeric(19, 4) NULL,
	is_active bool DEFAULT true NOT NULL,
	allow_add_downline bool DEFAULT false NOT NULL,
	report_url varchar(255) NULL,
	joined_at timestamp NULL,
	last_activity_date date NULL,
	domicile_area_id int4 NULL,
	commission_points int4 NULL,
	is_blocked bool DEFAULT false NOT NULL,
	owner_name varchar(100) NULL,
	national_id_number varchar(30) NULL,
	birth_date date NULL,
	mother_name varchar(100) NULL,
	phone varchar(20) NULL,
	email varchar(100) NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT master_reseller_pkey PRIMARY KEY (reseller_id),
	CONSTRAINT master_reseller_reseller_code_key UNIQUE (reseller_code),
	CONSTRAINT fk_resellers_upline FOREIGN KEY (upline_reseller_id) REFERENCES mochan.master_reseller(reseller_id)
);


-- mochan.reseller_balance_histories definition

-- Drop table

-- DROP TABLE mochan.reseller_balance_histories;

CREATE TABLE mochan.reseller_balance_histories (
	balance_history_id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	reseller_id int8 NOT NULL,
	transaction_id int8 NULL,
	partner_reference varchar(40) NULL,
	event_at timestamp NOT NULL,
	description varchar(255) NULL,
	amount numeric(19, 4) NULL,
	remaining_balance numeric(19, 4) NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT reseller_balance_histories_pkey PRIMARY KEY (balance_history_id),
	CONSTRAINT fk_reseller_balance_histories_transaction FOREIGN KEY (transaction_id) REFERENCES mochan.transactions(transaction_id)
);


-- mochan.sold_physical_vouchers definition

-- Drop table

-- DROP TABLE mochan.sold_physical_vouchers;

CREATE TABLE mochan.sold_physical_vouchers (
	transaction_id int8 NOT NULL,
	serial_number varchar(32) NULL,
	scratch_number varchar(32) NULL,
	production_at timestamp NULL,
	expiration_date date NULL,
	released_at timestamp NULL,
	reseller_id int8 NULL,
	product_id int4 NULL,
	created_at timestamp NULL,
	created_by_user_id varchar(36) NULL,
	updated_at timestamp NULL,
	updated_by varchar(50) NULL,
	deleted_at timestamp NULL,
	CONSTRAINT sold_physical_vouchers_pkey PRIMARY KEY (transaction_id),
	CONSTRAINT fk_sold_physical_vouchers_transaction FOREIGN KEY (transaction_id) REFERENCES mochan.transactions(transaction_id)
);

-- mochan.master_supplier_sub definition
-- Drop table
-- DROP TABLE mochan.master_supplier_sub;

CREATE TABLE mochan.master_supplier_sub (
  supplier_sub_id BIGINT PRIMARY KEY,
  supplier_sub_name VARCHAR(100) NOT NULL,
  supplier_id BIGINT NOT NULL,
  format_no_alokasi VARCHAR(30) NOT NULL DEFAULT '',
  is_ppob BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  deleted_at TIMESTAMP
);
CREATE INDEX idx_master_supplier_sub_supplier_id
  ON mochan.master_supplier_sub (supplier_id);

CREATE UNIQUE INDEX uq_master_supplier_sub_supplier_id_supplier_sub_name
  ON mochan.master_supplier_sub (supplier_id, supplier_sub_name);

-- mochan.master_supplier_sub_ledger definition
-- Drop table
-- DROP TABLE mochan.master_supplier_sub_ledger;

CREATE TABLE mochan.master_supplier_sub_ledger (
  supplier_sub_ledger_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  supplier_sub_id BIGINT NOT NULL,
  ledger_type VARCHAR(50) NOT NULL,
  ledger_id VARCHAR(30) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  deleted_at TIMESTAMP,
  CONSTRAINT fk_master_supplier_sub_ledger_sub_supplier
    FOREIGN KEY (supplier_sub_id)
    REFERENCES mochan.master_supplier_sub (supplier_sub_id)
);

CREATE UNIQUE INDEX uq_master_supplier_sub_ledger_supplier_sub_id_ledger_type
  ON mochan.master_supplier_sub_ledger (supplier_sub_id, ledger_type);

CREATE INDEX idx_master_supplier_sub_ledger_ledger_id
  ON mochan.master_supplier_sub_ledger (ledger_id);