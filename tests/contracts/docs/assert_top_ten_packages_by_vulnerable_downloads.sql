WITH test AS (
SELECT
  package,
  was_vulnerable,
  downloads,
  proportion_vulnerable_downloads
FROM `pypi-vulns.published_us.vulnerable_downloads_by_package`
WHERE was_vulnerable
ORDER BY downloads DESC
LIMIT 10
)

SELECT
    COUNT(1) row_count
FROM test
HAVING row_count != 10
