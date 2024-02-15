SELECT
  DATE_TRUNC(usage_date, MONTH) usage_month,
  project_id,
  service,
  sku,
  location,
  sum(usage) usage,
  sum(cost_gbp) cost_gbp
FROM {{ source('billing', 'pypi_vulns') }}
GROUP BY project_id, usage_month, service, sku, location
