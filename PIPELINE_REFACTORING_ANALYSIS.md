# Pipeline Refactoring Analysis: daily_package_downloads_optimised

## Current State

### Architecture
- **Single monolithic pipeline**: All models run in one `dbt build` command
- **Schedule**: Weekly (Saturdays at 4 AM UTC)
- **Trigger**: Also runs on push to main branch
- **Runtime**: All 31+ models run together

### Data Flow
```
PyPI Public Dataset (bigquery-public-data.pypi.file_downloads)
    ↓
file_downloads.sql (wrapper)
    ↓
daily_package_downloads_optimised.sql (aggregation + partitioning)
    ↓
downloads_and_vulnerabilities.sql (joins with safety_db)
    ↓
Other downstream models
```

### Current Issues
1. **Large incremental table**: 18 months of data, growing continuously
2. **Expensive source scans**: PyPI public dataset is very large
3. **Weekly update cycle**: May not match user needs
4. **All-or-nothing builds**: One model failure affects everything

---

## Option 1: Separate Pipeline - Same Repo ✅ RECOMMENDED

### Structure
```
.github/workflows/
├── deploy.yml                    # Main weekly pipeline (unchanged)
├── deploy_downloads_daily.yml    # NEW: Daily downloads pipeline
└── ...

models/
├── internal/
│   ├── pypi/
│   │   ├── daily_package_downloads_optimised.sql
│   │   └── file_downloads.sql
│   └── downloads_and_vulnerabilities.sql (depends on downloads)
└── ...
```

### Implementation
```yaml
# .github/workflows/deploy_downloads_daily.yml
name: update-downloads-daily
on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM UTC
  workflow_dispatch: {}
jobs:
  update-downloads:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: setup dbt
        uses: ./.github/actions/setup_dbt
      # ... auth steps ...
      - name: Update downloads only
        run: |
          dbt run --select daily_package_downloads_optimised file_downloads
      - name: Test downloads only
        run: |
          dbt test --select daily_package_downloads_optimised
```

### Benefits
✅ **Independent scheduling**: Run downloads daily, vulnerabilities weekly  
✅ **Faster feedback**: Daily updates without full pipeline run  
✅ **Isolated failures**: Downloads issues don't block vulnerability analysis  
✅ **Cost optimization**: Only run expensive PyPI scans when needed  
✅ **Simple maintenance**: All code in one repo, shared infra  
✅ **Easy debugging**: Can trigger downloads pipeline independently  
✅ **Gradual rollout**: Test daily schedule without affecting main pipeline  

### Costs
⚠️ **More GH Actions runs**: Daily instead of weekly (but likely smaller)  
⚠️ **Coordination needed**: Main pipeline depends on downloads being up-to-date  
⚠️ **Slightly more complex**: Two workflows instead of one  

### Recommendation
**YES - Do this if:**
- Users need fresher download data (daily vs weekly)
- The PyPI scan is a bottleneck in the main pipeline
- You want independent monitoring of download vs vulnerability pipelines
- Download failures shouldn't block vulnerability updates

---

## Option 2: Separate Pipeline - New Repo ❌ NOT RECOMMENDED

### Structure
```
pypi_downloads/              # NEW REPO
├── models/
│   └── daily_package_downloads.sql
└── .github/workflows/
    └── deploy.yml

pypi_vulnerabilities/        # EXISTING REPO
├── models/
│   ├── sources/
│   │   └── downloads_table.yml  # NEW: source from other project
│   └── downloads_and_vulnerabilities.sql
└── .github/workflows/
    └── deploy.yml
```

### Implementation
The downloads repo would publish to a shared dataset, and the vulnerabilities repo would reference it as an external source.

### Benefits
✅ **Complete isolation**: Different teams, permissions, schedules  
✅ **Separate concerns**: Downloads and vulnerabilities are independent products  
✅ **Independent scaling**: Different infra/budget for each  

### Costs
❌ **Much more complex**: Two repos, two deployments, coordination overhead  
❌ **Cross-repo dependencies**: Breaking changes in downloads break vulnerabilities  
❌ **Duplicated infrastructure**: Two sets of secrets, environments, configs  
❌ **Harder debugging**: Need to trace across repos  
❌ **No shared code**: Can't reuse macros, tests, utilities  
❌ **More expensive**: Two separate CI/CD pipelines, monitoring, etc.  

### Recommendation
**NO - Don't do this unless:**
- You have separate teams managing downloads vs vulnerabilities
- You need different security/access controls for each dataset
- The repos are fundamentally different products

---

## Option 3: Keep Current Structure (Status Quo)

### Benefits
✅ **Simplest**: No changes needed  
✅ **Proven**: Currently working  
✅ **Single pipeline**: Easy to understand  

### Costs
❌ **Slow feedback**: Weekly updates only  
❌ **Tightly coupled**: All models succeed or fail together  
❌ **Potentially expensive**: Running everything weekly even if only downloads changed  

### Recommendation
**MAYBE - Keep this if:**
- Weekly updates are sufficient for all use cases
- The current runtime and costs are acceptable
- You want to minimize complexity

---

## Final Recommendation

### Implement Option 1: Separate Daily Pipeline in Same Repo

**Why:**
1. **Cost-effective daily updates**: The incremental model with partitioning means daily updates will be cheap (only scan recent data)
2. **Better user experience**: Fresher data without waiting for weekly run
3. **Risk mitigation**: Downloads failures don't block vulnerability pipeline
4. **Low complexity**: Add one workflow file, leverage existing infrastructure
5. **Easy rollback**: Can disable daily workflow if issues arise

**Implementation Steps:**
1. Create `.github/workflows/deploy_downloads_daily.yml`
2. Configure to run `dbt run --select daily_package_downloads_optimised+` daily
3. Keep main weekly workflow unchanged for full build
4. Monitor costs for first month to validate savings hypothesis

**Estimated Effort:** 4-8 hours
**Risk Level:** Low (non-breaking change, can run in parallel with existing)

**Don't Do:** Option 2 (separate repo) - adds significant complexity without clear benefits for this use case.

---

## Cost Analysis

### Current: Weekly Full Build
- Scans: ~18 months of PyPI data + vulnerabilities data
- Frequency: Once per week
- Estimated: High cost, infrequent

### Proposed: Daily Downloads + Weekly Full
- **Daily (new)**: Only recent PyPI partitions (1-2 days)
- **Weekly (existing)**: Full build as backup/validation
- **Estimated savings**: Daily runs ~95% cheaper than weekly full scan
- **Net result**: Better data freshness at similar or lower cost

