from jinja2 import Environment, BaseLoader
import os

# Set up environment variables
os.environ['DBT_PYPI_EARLIEST_DOWNLOAD_DATE'] = '2024-01-01'

# Read the SQL template
with open('models/internal/pypi/daily_package_downloads_optimised.sql', 'r') as f:
    template_content = f.read()

# Simple test rendering (won't work with dbt_utils but shows structure)
print("=== Template Structure ===")
print(template_content)
print("\n=== Key Logic Points ===")
if "is_incremental()" in template_content:
    print("✓ Has incremental logic")
if "daily_package_downloads" in template_content:
    print("✓ References old table for bootstrap")
if "UNION ALL" in template_content:
    print("✓ Uses UNION ALL to combine bootstrap + new data")
if "partition_by" in template_content:
    print("✓ Has partitioning configuration")
if "cluster_by" in template_content:
    print("✓ Has clustering configuration")
