# Automated Snowflake View Deployment

## CI/CD with GitHub Actions

This project uses GitHub Actions to automate the deployment of SQL scripts to different environments in Snowflake:

- **DEV:** Runs scripts in the `DEV` schema on every push to any branch (except `main`).
- **QA:** Runs scripts in the `QA` schema only after a successful deploy to DEV.
- **PRD:** Runs scripts in the production schema (defined by the `SCHEMA_PRD` variable) after merging into the `main` branch.

### Pipeline Workflow

1. **Create a development branch.**
2. **Add or modify `.sql` files and commit/push your changes.**
3. **The pipeline will automatically execute:**
   - First in DEV.
   - If DEV succeeds, then in QA.
4. **After review, merge into `main` to trigger deployment to PRD.**

### Required Secrets

The following secrets must be configured in your repository settings:
- `SNOWSQL_ACCOUNT`
- `SNOWSQL_USER`
- `SNOWSQL_PWD`

### Running the Pipeline Manually

You can manually trigger the pipeline from the "Actions" tab in GitHub.

### Adding New SQL Scripts

- Add or modify `.sql` files in your repository.
- On commit and push, the pipeline will detect and execute only the changed `.sql` files.

### Example: Triggering the Pipeline

```sh
git checkout -b feature/my-new-view
# Edit or add your .sql files
git add sql/views/my_new_view.sql
git commit -m "feat: add my new view script"
git push origin feature/my-new-view
```

Open a Pull Request to `main` when ready for production deployment.

---

**Note:**
- The pipeline ensures QA only runs after a successful DEV deploy.
- Production deploys only occur after merging into `main`.
- All jobs require the Snowflake secrets to be set in the repository.
