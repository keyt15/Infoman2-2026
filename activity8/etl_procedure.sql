CREATE OR REPLACE PROCEDURE dw.run_sales_etl()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_loaded INT := 0;
BEGIN

    INSERT INTO dw.dim_customer (source_id, full_name, region_code)
    SELECT
        id,
        full_name,
        region_code
    FROM public.customers
    ON CONFLICT (source_id)
    DO UPDATE SET
        full_name = EXCLUDED.full_name,
        region_code = EXCLUDED.region_code;

    INSERT INTO dw.dim_product (source_id, product_name, category, unit_price)
    SELECT
        id,
        product_name,
        category,
        unit_price
    FROM public.products
    ON CONFLICT (source_id)
    DO UPDATE SET
        product_name = EXCLUDED.product_name,
        category = EXCLUDED.category,
        unit_price = EXCLUDED.unit_price;

    INSERT INTO dw.dim_branch (source_id, branch_name, city, region)
    SELECT
        id,
        branch_name,
        city,
        region
    FROM public.branches
    ON CONFLICT (source_id)
    DO UPDATE SET
        branch_name = EXCLUDED.branch_name,
        city = EXCLUDED.city,
        region = EXCLUDED.region;

    INSERT INTO dw.dim_date (full_date, day, month, month_name, quarter, year)
    SELECT DISTINCT
        txn_date,
        EXTRACT(DAY FROM txn_date),
        EXTRACT(MONTH FROM txn_date),
        TO_CHAR(txn_date, 'Month'),
        EXTRACT(QUARTER FROM txn_date),
        EXTRACT(YEAR FROM txn_date)
    FROM public.sales_txn
    ON CONFLICT (full_date) DO NOTHING;


    INSERT INTO dw.fact_sales (
        date_key,
        customer_key,
        product_key,
        branch_key,
        qty,
        unit_price,
        total_amount,
        source_txn_id
    )
    SELECT
        d.date_key,
        c.customer_key,
        p.product_key,
        b.branch_key,
        s.qty,
        s.unit_price,
        s.qty * s.unit_price,
        s.id
    FROM public.sales_txn s

    JOIN dw.dim_date d
        ON d.full_date = s.txn_date

    JOIN dw.dim_customer c
        ON c.source_id = s.customer_id

    JOIN dw.dim_product p
        ON p.source_id = s.product_id

    JOIN dw.dim_branch b
        ON b.source_id = s.branch_id

    WHERE
        s.qty > 0                
        AND s.unit_price > 0      
        AND NOT EXISTS (          
            SELECT 1
            FROM dw.fact_sales f
            WHERE f.source_txn_id = s.id
        );

    GET DIAGNOSTICS v_rows_loaded = ROW_COUNT;

    INSERT INTO dw.etl_log(run_ts, status, rows_loaded, error_message)
    VALUES (CURRENT_TIMESTAMP, 'SUCCESS', v_rows_loaded, NULL);

EXCEPTION
WHEN OTHERS THEN

    INSERT INTO dw.etl_log(run_ts, status, rows_loaded, error_message)
    VALUES (CURRENT_TIMESTAMP, 'FAIL', 0, SQLERRM);

END;
$$;