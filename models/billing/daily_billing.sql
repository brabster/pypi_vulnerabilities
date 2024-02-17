SELECT
  usage_date,
  project_id,
  service,
  sku,
  location,
  sum(usage) usage,
  sum(cost_gbp) cost_gbp
FROM {{ source('billing', 'pypi_vulns') }}
GROUP BY project_id, usage_date, service, sku, location
