SELECT
    *,
    DATE(timestamp) AS download_date,
    file.project AS package,
    file.version AS package_version,
    details.python AS python_version,
    details.installer.name AS installer
FROM {{ source('pypi', 'file_downloads') }}