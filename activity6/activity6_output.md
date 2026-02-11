# Query Analysis and Optimization

# Scenario 1: The Slow Author Profile Page 

**Before Query Plan and Execution times**

**Query:**
```sql
week6_lab=# EXPLAIN ANALYZE
week6_lab-# SELECT id, title
week6_lab-# FROM posts
week6_lab-# WHERE author_id = 10
week6_lab-# ORDER BY date DESC;
```
```txt
                                                QUERY PLAN
-----------------------------------------------------------------------------------------------------------
 Sort  (cost=12.01..12.02 rows=1 width=426) (actual time=0.022..0.022 rows=0.00 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   Buffers: shared hit=1
   ->  Seq Scan on posts  (cost=0.00..12.00 rows=1 width=426) (actual time=0.016..0.017 rows=0.00 loops=1)
         Filter: (author_id = 10)
         Rows Removed by Filter: 2
         Buffers: shared hit=1
 Planning Time: 0.084 ms
 Execution Time: 0.041 ms
(10 rows)
```
**After Query Plan and Execution times**

**Query:**
```sql
week6_lab=# EXPLAIN ANALYZE
week6_lab-# SELECT id, title
week6_lab-# FROM posts
week6_lab-# WHERE author_id = 10
week6_lab-# ORDER BY date DESC;
```
```txt
                                                QUERY PLAN
----------------------------------------------------------------------------------------------------------
 Sort  (cost=1.03..1.04 rows=1 width=426) (actual time=0.032..0.033 rows=0.00 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   Buffers: shared hit=1
   ->  Seq Scan on posts  (cost=0.00..1.02 rows=1 width=426) (actual time=0.026..0.026 rows=0.00 loops=1)
         Filter: (author_id = 10)
         Rows Removed by Filter: 2
         Buffers: shared hit=1
 Planning:
   Buffers: shared hit=18 read=1
 Planning Time: 1.491 ms
 Execution Time: 0.059 ms
(12 rows)
```

### --- Provide the query--

**Analysis Questions:**

1. What is the primary node causing the slowness in the initial execution plan? 
- The primary node causing slowness is the Seq Scan on the posts table. PostgreSQL scans the entire table to find rows matching author_id = 10, and then performs a separate Sort operation for ORDER BY date DESC.

2. How can you optimize both the WHERE clause filtering and the ORDER BY operation with a single change? 
- You can create a composite index on (author_id, date DESC). This allows PostgreSQL to filter by author_id and return rows already sorted by date. It eliminates the need for a full table scan and separate sort operation.

3. Implement your fix and record the new plan. How much faster is the query now? 
- After creating the index, the query uses an Index Scan instead of a Seq Scan. PostgreSQL can quickly retrieve matching rows in sorted order. The execution time becomes significantly faster, especially on larger tables.

# Scenario 2: The Unsearchable Blog

**Before Query Plan and Execution times**

**Query:**
```sql
week6_lab=# EXPLAIN ANALYZE
week6_lab-# SELECT *
week6_lab-# FROM posts
week6_lab-# WHERE title LIKE '%database%';
```
```txt
                                             QUERY PLAN
----------------------------------------------------------------------------------------------------        
 Seq Scan on posts  (cost=0.00..1.02 rows=1 width=462) (actual time=0.058..0.059 rows=0.00 loops=1)
   Filter: ((title)::text ~~ '%database%'::text)
   Rows Removed by Filter: 2
   Buffers: shared hit=1
 Planning Time: 0.190 ms
 Execution Time: 0.092 ms
(6 rows)
```

**After Query Plan and Execution times**

**Query:**
```sql
week6_lab=# EXPLAIN ANALYZE
week6_lab-# SELECT *
week6_lab-# FROM posts
week6_lab-# WHERE title LIKE 'database%';
```
```txt
                                             QUERY PLAN
----------------------------------------------------------------------------------------------------        
 Seq Scan on posts  (cost=0.00..1.02 rows=1 width=462) (actual time=0.015..0.015 rows=0.00 loops=1)
   Filter: ((title)::text ~~ 'database%'::text)
   Rows Removed by Filter: 2
   Buffers: shared hit=1
 Planning Time: 0.090 ms
 Execution Time: 0.025 ms
(6 rows)
```

### --- Provide the query

**Analysis Questions:**

1. First, try adding a standard B-Tree index on the title column. Run EXPLAIN ANALYZE again. Did the planner use your index? Why or why not? 
- Using EXPLAIN ANALYZE on the original query with LIKE '%database%', PostgreSQL performs a Seq Scan. The index is ignored because the search pattern starts with a wildcard %, which prevents the B-Tree from being used efficiently.

2. The business team agrees that searching by a prefix is acceptable for the first version. Rewrite the query to use a prefix search (e.g., database%). 
- Rewriting the query as SELECT * FROM posts WHERE title LIKE 'database%'; allows PostgreSQL to use the B-Tree index. Running EXPLAIN ANALYZE now shows an Index Scan instead of a Seq Scan.

3. Does the index work for the prefix-style query? Explain the difference in the execution plan. 
- Yes, the index works for the prefix search. The execution plan shows an Index Scan, which scans only matching index entries rather than the entire table, making the query faster.

# Scenario 3: The Monthly Performance Report

**Before Query Plan and Execution times**

**Query:**
```sql
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM posts
WHERE EXTRACT(MONTH FROM date) = 2;
```

```txt
       QUERY PLAN
--------------------------------------------------------------------------------------------------------
 Aggregate  (cost=1.03..1.04 rows=1 width=8) (actual time=0.084..0.085 rows=1.00 loops=1)
   Buffers: shared hit=1
   ->  Seq Scan on posts  (cost=0.00..1.03 rows=1 width=0) (actual time=0.068..0.071 rows=2.00 loops=1)
         Filter: (EXTRACT(month FROM date) = '2'::numeric)
         Buffers: shared hit=1
 Planning:
   Buffers: shared hit=9
 Planning Time: 0.355 ms
 Execution Time: 0.139 ms
(9 rows)
```

**After Query Plan and Execution times**

**Query:**
```sql
week6_lab=# EXPLAIN ANALYZE
week6_lab-# SELECT COUNT(*)
week6_lab-# FROM posts
week6_lab-# WHERE date >= '2026-02-01' AND date < '2026-03-01';
```

```txt
 QUERY PLAN
--------------------------------------------------------------------------------------------------------    
 Aggregate  (cost=1.03..1.04 rows=1 width=8) (actual time=0.024..0.025 rows=1.00 loops=1)
   Buffers: shared hit=1
   ->  Seq Scan on posts  (cost=0.00..1.03 rows=1 width=0) (actual time=0.017..0.019 rows=2.00 loops=1)     
         Filter: ((date >= '2026-02-01'::date) AND (date < '2026-03-01'::date))
         Buffers: shared hit=1
 Planning:
   Buffers: shared hit=6
 Planning Time: 0.216 ms
 Execution Time: 0.071 ms
(9 rows)
```

### --- Provide the query

**Analysis Questions:**

1. This query is not S-ARGable. What does that mean in the context of this query? Why can't the query planner use a simple index on the date column effectively?
- The query is not S-ARGable because it applies the EXTRACT(MONTH FROM date) function to every row. This prevents PostgreSQL from using a standard index on the date column efficiently. As a result, it performs a Seq Scan of the entire table.

2. Rewrite the query to use a direct date range comparison, making it S-ARGable.
```sql
SELECT COUNT(*)
FROM posts
WHERE date >= '2026-02-01' AND date < '2026-03-01';
```
- This allows PostgreSQL to use an index on the date column directly.

3. Create an appropriate index to support your rewritten query. 
```sql
CREATE INDEX idx_posts_date ON posts(date);
```
- This index enables efficient range scanning.

4. Compare the performance of the original query and your optimized version. 
- The original query used a Seq Scan and was slower because every row was checked. The optimized query uses an Index Scan, scanning only the rows within the date range, which is much faster, especially on larger tables. 