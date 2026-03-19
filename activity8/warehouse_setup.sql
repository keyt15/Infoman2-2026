CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE dw.dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INT,
    month INT,
    month_name TEXT,
    quarter INT,
    year INT
);

CREATE TABLE dw.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    source_id INT UNIQUE,  
    full_name TEXT,
    region_code TEXT
);

CREATE TABLE dw.dim_product (
    product_key SERIAL PRIMARY KEY,
    source_id INT UNIQUE, 
    product_name TEXT,
    category TEXT,
    unit_price NUMERIC(10,2)
);

CREATE TABLE dw.dim_branch (
    branch_key SERIAL PRIMARY KEY,
    source_id INT UNIQUE,
    branch_name TEXT,
    city TEXT,
    region TEXT
);

CREATE TABLE dw.fact_sales (

    sales_key SERIAL PRIMARY KEY,

    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    branch_key INT NOT NULL,

    qty INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,

    source_txn_id INT UNIQUE, 

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES dw.dim_date(date_key),

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_key)
        REFERENCES dw.dim_customer(customer_key),

    CONSTRAINT fk_product
        FOREIGN KEY (product_key)
        REFERENCES dw.dim_product(product_key),

    CONSTRAINT fk_branch
        FOREIGN KEY (branch_key)
        REFERENCES dw.dim_branch(branch_key)
);

CREATE TABLE dw.etl_log (

    log_id SERIAL PRIMARY KEY,
    run_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT,
    rows_loaded INT,
    error_message TEXT

);

CREATE INDEX idx_fact_sales_date
ON dw.fact_sales(date_key);

CREATE INDEX idx_fact_sales_branch
ON dw.fact_sales(branch_key);

CREATE INDEX idx_customer_source
ON dw.dim_customer(source_id);

CREATE INDEX idx_product_source
ON dw.dim_product(source_id);

CREATE INDEX idx_branch_source
ON dw.dim_branch(source_id);