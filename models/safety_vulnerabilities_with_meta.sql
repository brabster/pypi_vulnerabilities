WITH safety_vulnerabilities AS (
  SELECT
    package,
    vulnerability
  FROM {{ source('safety_db', 'safety_db_2022_07_01') }} safety
    CROSS JOIN UNNEST(vulnerabilities) vulnerability
)

SELECT
  safety.package,
  safety.vulnerability.cve,
  safety.vulnerability.specs,
  nvd.publishedDate nvd_published_at,
  COALESCE(
    nvd.publishedDate,
    TIMESTAMP('2022-07-01')) nvd_estimated_published_at,
  COALESCE(
    nvd.Impact.baseMetricV3.cvssV3.baseScore,
    nvd.Impact.baseMetricV2.cvssV2.baseScore) nvd_cvss_base_score
FROM safety_vulnerabilities safety
  LEFT JOIN {{ source('nvd', 'nvd') }} nvd
    ON safety.vulnerability.cve = nvd.cve.CVE_data_meta.ID
WHERE nvd.publishedDate <= TIMESTAMP('2022-08-01')
