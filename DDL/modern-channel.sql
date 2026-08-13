-- DDL generated from erd/modern-channel.dbml
-- Target dialect: PostgreSQL

CREATE TABLE operators (
  operator_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  operator_name VARCHAR(100) NOT NULL,
  is_partitioned BOOLEAN NOT NULL DEFAULT FALSE,
  partition_cluster INT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50)
);

CREATE TABLE suppliers (
  supplier_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  supplier_name VARCHAR(100) NOT NULL,
  address VARCHAR(255),
  phone VARCHAR(20),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50)
);

CREATE TABLE terminals (
  terminal_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  terminal_name VARCHAR(150) NOT NULL,
  terminal_type VARCHAR(10),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_log_at TIMESTAMP,
  supplier_id INT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  CONSTRAINT fk_terminals_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);

CREATE TABLE resellers (
  reseller_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  reseller_code VARCHAR(16) NOT NULL UNIQUE,
  upline_reseller_id BIGINT,
  reseller_name VARCHAR(100) NOT NULL,
  address VARCHAR(255),
  direct_commission_flag BOOLEAN NOT NULL DEFAULT FALSE,
  base_sell_price NUMERIC(19,4),
  personal_markup NUMERIC(19,4),
  upline_markup NUMERIC(19,4),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  allow_add_downline BOOLEAN NOT NULL DEFAULT FALSE,
  report_url VARCHAR(255),
  joined_at TIMESTAMP,
  last_activity_date DATE,
  domicile_area_id INT,
  commission_points INT,
  is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
  owner_name VARCHAR(100),
  national_id_number VARCHAR(30),
  birth_date DATE,
  mother_name VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(100),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  CONSTRAINT fk_resellers_upline
    FOREIGN KEY (upline_reseller_id) REFERENCES resellers (reseller_id)
);

CREATE TABLE products (
  product_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  operator_id INT NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  nominal_value INT,
  product_code VARCHAR(20) NOT NULL UNIQUE,
  product_type VARCHAR(20),
  is_out_of_stock BOOLEAN NOT NULL DEFAULT FALSE,
  is_disrupted BOOLEAN NOT NULL DEFAULT FALSE,
  available_start_time TIME,
  available_end_time TIME,
  notes VARCHAR(150),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  CONSTRAINT fk_products_operator
    FOREIGN KEY (operator_id) REFERENCES operators (operator_id)
);

CREATE TABLE transactions (
  transaction_id BIGINT PRIMARY KEY,
  reseller_id BIGINT NOT NULL,
  reseller_name VARCHAR(100) NOT NULL,
  product_id INT,
  transaction_date DATE NOT NULL,
  transaction_time TIME NOT NULL,
  destination_account VARCHAR(100),
  purchase_price NUMERIC(19,4),
  selling_price NUMERIC(19,4),
  transaction_type VARCHAR(20),
  transaction_status INT,
  terminal_id INT,
  reseller_selling_price NUMERIC(19,4),
  notes VARCHAR(512),
  serial_number VARCHAR(255),
  retry_count INT,
  benchmark_selling_price NUMERIC(19,4),
  received_date DATE,
  received_time TIME,
  client_transaction_id VARCHAR(40),
  opening_balance NUMERIC(19,4),
  closing_balance NUMERIC(19,4),
  stock_balance NUMERIC(19,4),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  CONSTRAINT fk_transactions_reseller
    FOREIGN KEY (reseller_id) REFERENCES resellers (reseller_id),
  CONSTRAINT fk_transactions_product
    FOREIGN KEY (product_id) REFERENCES products (product_id),
  CONSTRAINT fk_transactions_terminal
    FOREIGN KEY (terminal_id) REFERENCES terminals (terminal_id)
);

CREATE TABLE payments (
  payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  reseller_id BIGINT NOT NULL,
  payment_at TIMESTAMP NOT NULL,
  amount_due NUMERIC(19,4),
  amount_paid NUMERIC(19,4),
  notes VARCHAR(255),
  settlement_status VARCHAR(15),
  created_by_user_id VARCHAR(36),
  payment_type VARCHAR(20),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  CONSTRAINT fk_payments_reseller
    FOREIGN KEY (reseller_id) REFERENCES resellers (reseller_id)
);

CREATE TABLE reseller_balance_histories (
  balance_history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  reseller_id BIGINT NOT NULL,
  transaction_id BIGINT,
  partner_reference VARCHAR(40),
  event_at TIMESTAMP NOT NULL,
  description VARCHAR(255),
  amount NUMERIC(19,4),
  remaining_balance NUMERIC(19,4),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  updated_by VARCHAR(50),
  CONSTRAINT fk_reseller_balance_histories_reseller
    FOREIGN KEY (reseller_id) REFERENCES resellers (reseller_id),
  CONSTRAINT fk_reseller_balance_histories_transaction
    FOREIGN KEY (transaction_id) REFERENCES transactions (transaction_id)
);

CREATE TABLE sold_physical_vouchers (
  transaction_id BIGINT PRIMARY KEY,
  serial_number VARCHAR(32),
  scratch_number VARCHAR(32),
  production_at TIMESTAMP,
  expiration_date DATE,
  released_at TIMESTAMP,
  reseller_id BIGINT,
  product_id INT,
  created_at TIMESTAMP,
  created_by_user_id VARCHAR(36),
  CONSTRAINT fk_sold_physical_vouchers_transaction
    FOREIGN KEY (transaction_id) REFERENCES transactions (transaction_id),
  CONSTRAINT fk_sold_physical_vouchers_reseller
    FOREIGN KEY (reseller_id) REFERENCES resellers (reseller_id),
  CONSTRAINT fk_sold_physical_vouchers_product
    FOREIGN KEY (product_id) REFERENCES products (product_id)
);

CREATE TABLE user_access_logs (
  access_log_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  logged_at TIMESTAMP NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  description VARCHAR(512),
  created_at TIMESTAMP NOT NULL
);

CREATE TABLE data_migration_monitor_daily (
  monitor_date DATE PRIMARY KEY,
  hist_partner_row_count_legacy BIGINT NOT NULL DEFAULT 0,
  hist_partner_amount_legacy NUMERIC(19,4) NOT NULL DEFAULT 0,
  hist_balance_row_count_legacy BIGINT NOT NULL DEFAULT 0,
  hist_balance_amount_legacy NUMERIC(19,4) NOT NULL DEFAULT 0,
  hist_partner_row_count_new BIGINT NOT NULL DEFAULT 0,
  hist_partner_amount_new NUMERIC(19,4) NOT NULL DEFAULT 0,
  success_count_legacy INT NOT NULL DEFAULT 0,
  failed_count_legacy INT NOT NULL DEFAULT 0,
  pending_count_legacy INT NOT NULL DEFAULT 0,
  total_trx_legacy INT NOT NULL DEFAULT 0,
  success_count_new INT NOT NULL DEFAULT 0,
  failed_count_new INT NOT NULL DEFAULT 0,
  pending_count_new INT NOT NULL DEFAULT 0,
  total_trx_new INT NOT NULL DEFAULT 0,
  total_ppob_trx_legacy INT NOT NULL DEFAULT 0,
  total_ppob_trx_new INT NOT NULL DEFAULT 0
);

CREATE TABLE daily_transaction_mutations (
  mutation_date DATE,
  supplier_name VARCHAR(50),
  sub_supplier_name VARCHAR(50),
  reseller_code VARCHAR(20),
  reseller_name VARCHAR(100),
  operator_name VARCHAR(100),
  product_code VARCHAR(20),
  product_name VARCHAR(100),
  denomination INT,
  purchase_price NUMERIC(19,4),
  selling_price NUMERIC(19,4),
  discount NUMERIC(19,4),
  dat_amount NUMERIC(19,4),
  ar_ap_amount NUMERIC(19,4),
  net_amount NUMERIC(19,4),
  switching_fee NUMERIC(19,4),
  net_switching_amount NUMERIC(19,4),
  quantity INT,
  margin NUMERIC(19,4),
  sakala_selling_price NUMERIC(19,4),
  fee NUMERIC(19,4),
  fee_dpp NUMERIC(19,4),
  transaction_status VARCHAR(20),
  terminal_code VARCHAR(20),
  terminal_name VARCHAR(50),
  sales_amount NUMERIC(19,4),
  cogs_amount NUMERIC(19,4),
  sales_margin NUMERIC(19,4),
  supplier_fee NUMERIC(19,4)
);
