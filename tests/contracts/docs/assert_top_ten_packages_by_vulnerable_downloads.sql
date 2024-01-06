WITH test AS (
    SELECT
        package,
        downloads_with_known_vulnerabilities,
        downloads_without_known_vulnerabilities,
        proportion_vulnerable_downloads
    FROM `pypi-vulnerabilities.pypi_vulnerabilities_us.vulnerable_downloads_by_package`
    ORDER BY downloads_with_known_vulnerabilities DESC
    LIMIT 10
)

SELECT
    COUNT(1) row_count
FROM test
HAVING row_count != 10
