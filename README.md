# 🏔️ data_snowflake

> Automated CI/CD pipeline for deploying SQL scripts and Python-based data ingestion to Snowflake across multiple environments (DEV → QA → PRD).

---

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [CI/CD Pipeline](#cicd-pipeline)
- [API — Crypto Data Ingestion](#api--crypto-data-ingestion)
- [SQL Scripts](#sql-scripts)
- [Getting Started](#getting-started)
- [Required Secrets](#required-secrets)
- [Running the Pipeline Manually](#running-the-pipeline-manually)
- [Adding New SQL Scripts](#adding-new-sql-scripts)
- [Contributing](#contributing)

---

## Overview

**data_snowflake** is a DataOps project that automates the deployment of SQL views and Python-based data pipelines into Snowflake using **GitHub Actions**. It enforces a structured promotion flow through three environments:

| Environment | Schema      | Trigger                              |
|-------------|-------------|--------------------------------------|
| DEV         | `DEV`       | Push to any branch (except `main`)   |
| QA          | `QA`        | Automatically after DEV succeeds     |
| PRD         | `SCHEMA_PRD`| Merge into `main`                    |

This guarantees that no code reaches production without first passing through the development and quality assurance stages.

---

## Project Structure

```
data_snowflake/
│
├── .github/
│   └── workflows/          # GitHub Actions CI/CD pipeline definitions
│
├── API/
│   └── crypto/             # Python scripts for Crypto market data ingestion
│
├── sql/                    # SQL scripts (views, tables, procedures) for Snowflake
│
├── .gitignore
└── README.md
```

**Languages used:**

- `PLpgSQL / SQL` — 94% (Snowflake views and transformations)
- `Python` — 6% (API data ingestion)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        GitHub Repository                    │
│                                                             │
│  feature/branch  ──push──►  GitHub Actions  ──►  DEV schema│
│                                    │                        │
│                                    ▼ (on DEV success)       │
│                             GitHub Actions  ──►  QA  schema │
│                                                             │
│  main branch     ──merge─► GitHub Actions  ──►  PRD schema │
└─────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                           ┌─────────────────┐
                           │    Snowflake     │
                           │  (SnowSQL CLI)   │
                           │                  │
                           │  DEV  │  QA  │ PRD │
                           └─────────────────┘
```

---

## CI/CD Pipeline

### Pipeline Workflow

```
1. Create a feature branch
       │
       ▼
2. Add or modify .sql files → git commit & push
       │
       ▼
3. GitHub Actions triggers:
       ├─► Deploy to DEV
       │       │
       │       ▼ (success)
       └─► Deploy to QA
               │
               ▼
4. Open Pull Request to `main`
       │
       ▼
5. After merge → Deploy to PRD
```

### Key Behaviors

- **DEV** is triggered on every push to any branch except `main`.
- **QA** only runs after a successful DEV deployment — no skips allowed.
- **PRD** is exclusively triggered by a merge into the `main` branch.
- Only **changed `.sql` files** are detected and executed per pipeline run, reducing execution time and unintended side effects.

---

## API — Crypto Data Ingestion

The `API/crypto/` module contains **Python scripts** responsible for fetching cryptocurrency market data from an external API and loading it into Snowflake.

### Typical Workflow

```
External Crypto API  ──fetch──►  Python Script  ──load──►  Snowflake Table/Stage
```

### How to Run Locally

```bash
cd API/crypto

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export SNOWSQL_ACCOUNT=<your_account>
export SNOWSQL_USER=<your_user>
export SNOWSQL_PWD=<your_password>

# Run the ingestion script
python main.py
```

> **Note:** Make sure your Snowflake user has the necessary permissions to write to the target database and schema.

---

## SQL Scripts

All SQL files live under the `sql/` directory. These are executed by the CI/CD pipeline using **SnowSQL** against the appropriate Snowflake schema based on the deployment environment.

### Naming Convention (recommended)

```
sql/
├── views/
│   ├── vw_crypto_prices.sql
│   └── vw_market_summary.sql
├── tables/
│   └── crypto_raw.sql
└── procedures/
    └── sp_load_data.sql
```

### Example SQL View

```sql
CREATE OR REPLACE VIEW DEV.VW_CRYPTO_PRICES AS
SELECT
    symbol,
    price_usd,
    volume_24h,
    market_cap,
    last_updated
FROM RAW.CRYPTO_MARKET_DATA
WHERE last_updated >= CURRENT_DATE - 7;
```

---

## Getting Started

### Prerequisites

- A **Snowflake account** with at least one database and three schemas: `DEV`, `QA`, and the production schema defined in `SCHEMA_PRD`.
- **SnowSQL CLI** installed (used by the GitHub Actions runners).
- **Python 3.9+** for the crypto ingestion scripts.
- A **GitHub repository** with Secrets configured (see below).

### Clone the Repository

```bash
git clone https://github.com/dbandre76/data_snowflake.git
cd data_snowflake
```

---

## Required Secrets

Configure the following secrets in your GitHub repository under **Settings → Secrets and Variables → Actions**:

| Secret Name       | Description                              |
|-------------------|------------------------------------------|
| `SNOWSQL_ACCOUNT` | Your Snowflake account identifier        |
| `SNOWSQL_USER`    | Snowflake username used for deployments  |
| `SNOWSQL_PWD`     | Password for the Snowflake user          |

> ⚠️ **Never commit credentials to the repository.** Always use GitHub Secrets or a secrets manager.

---

## Running the Pipeline Manually

You can trigger the pipeline manually from the **Actions** tab in GitHub:

1. Go to the **Actions** tab in your repository.
2. Select the desired workflow.
3. Click **Run workflow** and choose the target branch.

---

## Adding New SQL Scripts

To add a new view or SQL object to the automated deployment:

```bash
# 1. Create a new feature branch
git checkout -b feature/my-new-view

# 2. Add or modify your .sql file
vim sql/views/my_new_view.sql

# 3. Stage and commit
git add sql/views/my_new_view.sql
git commit -m "feat: add my_new_view for crypto price aggregation"

# 4. Push to remote — this triggers DEV and QA automatically
git push origin feature/my-new-view

# 5. Open a Pull Request to `main` when ready for PRD
```

The pipeline will detect and execute **only the changed `.sql` files**, not the entire directory.

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Make your changes and commit: `git commit -m "feat: description"`.
4. Push and open a Pull Request.

Please follow the naming conventions for SQL files and keep each script focused on a single object.

---

## Tech Stack

| Tool              | Purpose                                  |
|-------------------|------------------------------------------|
| Snowflake         | Cloud data warehouse                     |
| SnowSQL           | CLI tool for executing SQL on Snowflake  |
| GitHub Actions    | CI/CD automation                         |
| Python            | Crypto API data ingestion                |
| PLpgSQL / SQL     | Views, tables, and stored procedures     |

---

*Made with ❄️ by [dbandre76](https://github.com/dbandre76)*
