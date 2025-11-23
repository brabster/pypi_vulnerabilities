# daily_package_downloads_optimised Migration Strategy

## Overview
This model replaces `daily_package_downloads` with an optimized version that uses:
- **Partitioning** by `download_date` for efficient time-based queries
- **Clustering** by `package` and `package_version` for efficient package-specific queries

## Bootstrap Strategy

To avoid reprocessing 18 months of historical data from the source PyPI dataset, this model uses a two-phase approach:

### Phase 1: Initial Run (Bootstrap)
When the model runs for the first time (`is_incremental()` returns False):

1. **Copy existing data** from `daily_package_downloads` table
   - This preserves all historical data without reprocessing
   - Data is automatically partitioned and clustered during the copy

2. **Add any new data** that appeared in the source since the old table was last updated
   - Queries `file_downloads` for dates > MAX(download_date) from old table
   - Ensures no data is missed during the transition

### Phase 2: Incremental Updates
On subsequent runs (`is_incremental()` returns True):

- Processes only new data from `file_downloads` where `download_date >= latest_partition_date`
- Standard incremental behavior, same as the original model

## Cost Savings

Without bootstrap:
- Would reprocess ~18 months of data from source
- Estimated cost: Very high due to scanning full PyPI dataset

With bootstrap:
- Copies existing aggregated data (much smaller than source)
- Only processes net-new data from source
- Estimated savings: Significant reduction in BigQuery processing costs

## Deployment

On first deployment:
1. Run `dbt run --models daily_package_downloads_optimised --full-refresh`
2. Verify the table is created with correct partitioning/clustering
3. Verify row counts match the original table (plus any new data)
4. Models referencing this table will automatically use the optimized version

## Rollback Strategy

If issues occur:
1. Models can be reverted to use `ref('daily_package_downloads')` 
2. The original `daily_package_downloads` table remains unchanged and continues to update
3. The optimised table can be dropped and recreated if needed
