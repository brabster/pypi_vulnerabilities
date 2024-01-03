SELECT
  download_date,
  package,
  package_version,
  installer,
  COUNT(1) AS download_count
FROM {{ ref('file_downloads') }}
GROUP BY
  download_date,
  package,
  package_version,
  installer


