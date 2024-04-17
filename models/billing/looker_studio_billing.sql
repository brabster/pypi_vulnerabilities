WITH aggregates AS (
  SELECT 
    DATE(start_time) usage_date,
    COUNT(1) total_queries,
    COUNTIF(cache_hit) cache_hits,
    SUM(total_bytes_billed) total_bytes_billed,
    AVG(total_bytes_billed) mean_bytes_billed,
    approx_quantiles(total_bytes_billed, 4)[2] median_bytes_billed,
    1024 * 1024 * 1024 gb_factor,
    1024 * 1024 * 1024 * 1024 tb_factor
  FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
  WHERE project_id = 'pypi-vulns'
    AND 'looker_studio' IN UNNEST(labels.value)
  GROUP BY usage_date
)

SELECT
  usage_date,
  total_queries,
  cache_hits,
  COALESCE(SAFE_DIVIDE(cache_hits, total_queries), 0) cache_hit_proportion,
  total_bytes_billed,
  mean_bytes_billed / gb_factor mean_gb_billed,
  median_bytes_billed / gb_factor median_gb_billed,
  total_bytes_billed / gb_factor total_gb_billed,
  (total_bytes_billed / tb_factor) * 6.25 approx_query_cost_usd
FROM aggregates