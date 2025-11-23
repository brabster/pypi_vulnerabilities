-- check a specifc date download count matches original implementation and mnual verification
WITH total AS (
    SELECT
        SUM(download_count) downloads
    FROM {{ ref('daily_package_downloads_optimised') }}
    WHERE download_date = '2023-11-05'
)

SELECT
    1
FROM total
WHERE downloads != 629058710