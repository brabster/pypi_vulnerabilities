SELECT
    *,
    DATE(timestamp) AS download_date,
    file.project AS package,
    file.version AS package_version,
    SPLIT(file.version, '.') package_version_semver_parts,
    details.python AS python_version,
    details.installer.name AS installer
FROM {{ source('pypi', 'file_downloads') }}