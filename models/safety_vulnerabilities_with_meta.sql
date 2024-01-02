WITH safety_vulnerabilities AS (
  SELECT
    package,
    vulnerability
  FROM {{ source('safety_db', 'safety_db') }} safety
    CROSS JOIN UNNEST(vulnerabilities) vulnerability
)

SELECT
  safety.package,
  safety.vulnerability.cve,
  safety.vulnerability.specs,
  nvd.publishedDate
FROM safety_vulnerabilities safety
  LEFT JOIN {{ source('nvd', 'nvd') }} nvd
    ON safety.vulnerability.cve = nvd.cve.CVE_data_meta.ID
WHERE publishedDate IS NOT NULL