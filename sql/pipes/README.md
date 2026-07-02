# ❄️ Snowpipe — Automatic Ingestion Pipeline
### Exchange Rates · Real-Time Data · S3 → Snowflake

---

## 📐 Architecture Topology

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DATA INGESTION TOPOLOGY                            │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌──────────────┐     REST      ┌──────────────────┐
  │  Python API  │ ────────────► │  Exchange Rate    │
  │  (main.py)   │               │  External API     │
  └──────┬───────┘               └──────────────────┘
         │ JSON payload
         ▼
  ┌──────────────────────────────────────┐
  │           AWS S3 Bucket              │
  │   arrudaconsulting-datalake          │
  │                                      │
  │   📁 multicloud/                     │
  │       └── 📁 exchange_rates/         │
  │               └── 📄 *.json  ◄───── │ ── PUT object
  └──────────────┬───────────────────────┘
                 │ S3 Event Notification
                 │ (Prefix: exchange_rates/ | Suffix: .json)
                 ▼
  ┌──────────────────────────────────────┐
  │           AWS SNS Topic              │
  │  snowpipe-exchange-rates-            │
  │  notifications                       │
  │  (Standard Topic)                    │
  └──────────────┬───────────────────────┘
                 │ SNS → SQS Subscription
                 │ (auto-created by Snowflake)
                 ▼
  ┌──────────────────────────────────────┐
  │           AWS SQS Queue              │
  │   (Managed by Snowflake internally)  │
  └──────────────┬───────────────────────┘
                 │ Snowpipe polls SQS
                 │ (~30–60 seconds latency)
                 ▼
  ┌──────────────────────────────────────────────────────────┐
  │                      SNOWFLAKE                           │
  │                                                          │
  │   Stage: @POC.PUBLIC.NORTH/exchange_rates/               │
  │        │                                                 │
  │        │  COPY INTO (via PIPE_EXCHANGE_RATES)            │
  │        ▼                                                 │
  │   Table: POC.DEV.BRONZE_EXCHANGE_RATES                   │
  │        │                                                 │
  │        │  (raw JSON preserved — Bronze Layer)            │
  │        ▼                                                 │
  │   Ready for Silver / Gold transformations                │
  └──────────────────────────────────────────────────────────┘
```

---

## 🔄 Event Flow — Step by Step

```
 STEP 1         STEP 2              STEP 3           STEP 4          STEP 5
┌────────┐    ┌─────────┐        ┌──────────┐     ┌─────────┐    ┌──────────┐
│ Python │    │   S3    │        │   SNS    │     │   SQS   │    │Snowflake │
│  API   │───►│ Bucket  │──────► │  Topic   │────►│  Queue  │───►│Snowpipe  │
│        │PUT │*.json   │ Event  │          │ Sub │(managed)│COPY│  Table   │
└────────┘    └─────────┘Notif. └──────────┘     └─────────┘    └──────────┘
                                                                  ~30-60 sec
```

---

## ✅ Prerequisites Checklist

Before running any SQL, confirm all infrastructure is in place:

| # | Component | Detail | Status |
|---|-----------|--------|--------|
| 1 | **SNS Topic** | `snowpipe-exchange-rates-notifications` (Standard) | ✅ |
| 2 | **S3 Event Notification** | Prefix: `multicloud/exchange_rates/` · Suffix: `.json` | ✅ |
| 3 | **Snowflake External Stage** | `@POC.PUBLIC.NORTH/exchange_rates/` | ✅ |
| 4 | **Snowflake File Format** | `JSON_FORMAT` exists in the schema | ✅ |

---

## 🚀 Setup Guide

### Step 1 — Get the SNS Topic ARN

In the **AWS SNS Console**:

1. Open the topic `snowpipe-exchange-rates-notifications`
2. Copy the full ARN:

```
arn:aws:sns:us-east-1:123456789012:snowpipe-exchange-rates-notifications
```

---

### Step 2 — Edit the Pipe Script

Open `pipe_exchange_rates.sql` and replace the placeholder ARN with your real one:

```sql
CREATE OR REPLACE PIPE POC.DEV.PIPE_EXCHANGE_RATES
  AUTO_INGEST = TRUE
  AWS_SNS_TOPIC = 'arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:snowpipe-exchange-rates-notifications'
AS
COPY INTO POC.DEV.BRONZE_EXCHANGE_RATES
FROM @POC.PUBLIC.NORTH/exchange_rates/
FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT');
```

> ⚠️ Replace `YOUR_ACCOUNT_ID` with your real AWS Account ID.

---

### Step 3 — Execute in Snowflake

When you run the pipe creation script, Snowflake automatically handles:

- ✅ Creates an internal **SQS Queue**
- ✅ Subscribes the SQS Queue to your **SNS Topic**
- ✅ Configures all necessary **AWS permissions**

```sql
-- Run pipe_exchange_rates.sql in Snowflake
-- Snowflake will auto-create the SQS and SNS subscription
```

---

### Step 4 — Configure SNS Permissions (if needed)

Snowflake needs permission to subscribe to your SNS Topic.

**Via AWS Console:**

1. Open the SNS topic in the AWS Console
2. Go to **"Access policy"**
3. Add a policy granting Snowflake access with actions:
   - `sns:Subscribe`
   - `sns:GetTopicAttributes`

**Via AWS CLI:**

```bash
aws sns add-permission \
  --topic-arn arn:aws:sns:us-east-1:123456789012:snowpipe-exchange-rates-notifications \
  --label snowflake-access \
  --aws-account-id <SNOWFLAKE_AWS_ACCOUNT_ID> \
  --action-name Subscribe GetTopicAttributes
```

> 💡 The Snowflake AWS Account ID is found in the Snowflake documentation or via `DESC INTEGRATION`.

---

### Step 5 — Verify the Pipe Status

```sql
-- Check if the pipe is running
SELECT SYSTEM$PIPE_STATUS('POC.DEV.PIPE_EXCHANGE_RATES');

-- Check load history (last 24 hours)
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME  => 'BRONZE_EXCHANGE_RATES',
  START_TIME  => DATEADD('hours', -24, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME = 'PIPE_EXCHANGE_RATES'
ORDER BY LAST_LOAD_TIME DESC;
```

---

## 🧪 Testing the Pipeline

### Option A — Run the Python Script

```bash
python API/main.py
```

### Option B — Upload Manually via AWS CLI

```bash
aws s3 cp my_exchange_rates.json \
  s3://arrudaconsulting-datalake/multicloud/exchange_rates/
```

### Validate Data Landed in Snowflake

Wait **30–60 seconds**, then:

```sql
SELECT *
FROM POC.DEV.BRONZE_EXCHANGE_RATES
ORDER BY created_at DESC
LIMIT 10;
```

---

## 📊 Monitoring

### Pipe Status

```sql
SELECT SYSTEM$PIPE_STATUS('POC.PUBLIC.PIPE_EXCHANGE_RATES');
```

### Pending Files in Queue

```sql
SELECT *
FROM TABLE(INFORMATION_SCHEMA.PIPE_USAGE_HISTORY(
  DATE_RANGE_START => DATEADD('hours', -24, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME   = 'PIPE_EXCHANGE_RATES'
  AND TABLE_SCHEMA = 'DEV';
```

### Load Errors

```sql
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'BRONZE_EXCHANGE_RATES',
  START_TIME => DATEADD('hours', -24, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME   = 'PIPE_EXCHANGE_RATES'
  AND TABLE_SCHEMA = 'DEV'
  AND STATUS       = 'LOAD_FAILED'
ORDER BY LAST_LOAD_TIME DESC;
```

---

## 🔧 Useful Commands

```sql
-- Pause the pipe
ALTER PIPE POC.DEV.PIPE_EXCHANGE_RATES
  SET PIPE_EXECUTION_PAUSED = TRUE;

-- Resume the pipe
ALTER PIPE POC.DEV.PIPE_EXCHANGE_RATES
  SET PIPE_EXECUTION_PAUSED = FALSE;

-- Inspect the pipe definition
SHOW PIPES LIKE 'PIPE_EXCHANGE_RATES';
```

---

## 🐛 Troubleshooting

### Pipe not loading files?

Work through this checklist in order:

```
1. ✅ Is the S3 Event Notification configured? (Prefix + Suffix correct?)
2. ✅ Is the SNS ARN in the pipe definition correct?
3. ✅ Does Snowflake have permission on the SNS Topic?
4. ✅ Is the Stage name correct and accessible?
5. ✅ Are there LOAD_FAILED records in COPY_HISTORY?
```

### Permission errors?

| Check | Query / Action |
|-------|---------------|
| Snowflake can read S3 | Verify Storage Integration credentials |
| Snowflake can access SNS | Check SNS Access Policy for Snowflake AWS Account |
| Stage credentials | `DESC STAGE POC.PUBLIC.NORTH;` |

---

## 📦 Stack

| Layer | Technology |
|-------|-----------|
| Ingestion script | Python (`API/main.py`) |
| Object storage | AWS S3 |
| Event notifications | AWS SNS → SQS |
| Auto-ingest engine | Snowflake Snowpipe |
| Raw storage | Snowflake Bronze Table |
| File format | JSON |

---

*❄️ Powered by Snowpipe · arrudaconsulting-datalake*
