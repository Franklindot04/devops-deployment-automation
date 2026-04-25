# DevOps Deployment Automation — Production‑Grade CI/CD with Slack Control

A fully automated, stateless CI/CD pipeline for deploying a Dockerized application to AWS EC2 using:

- **GitHub Actions**
- **AWS ECR + EC2**
- **Shell scripting (Bash)**
- **Slack interactive buttons**
- **AWS Lambda + API Gateway**
- **Version History + Rollback**
- **Staging → Production Promotion**

This project demonstrates real‑world DevOps engineering with production‑grade patterns, auditability and Slack‑driven deployment control.

---

## 🚀 Architecture Overview

```
Developer → GitHub → GitHub Actions → AWS ECR → EC2 Deployment Script
                                     ↓
                                   Slack
                                     ↓
                               Lambda (index.js)
                                     ↓
                          GitHub repository_dispatch
```

### Key Components:
- **Staging Deploy** → triggered on push to `main`
- **Promote to Production** → triggered via Slack button
- **Production Deploy** → manual or automated
- **Rollback Preview** → Slack interactive confirmation
- **Rollback Confirm/Cancel** → Slack → Lambda → GitHub → EC2
- **Version History** → stored in version files

---

## 🧩 Slack Integration (Phase‑2)

Slack is the control plane for production operations.

### Buttons available:
- **Promote to Production**
- **Rollback Production**
- **Confirm Rollback**
- **Cancel**

### Flow:
1. User clicks **Rollback Production**
2. Slack → Lambda → GitHub → Slack preview
3. User clicks **Confirm** or **Cancel**
4. Lambda → GitHub → EC2 (if confirmed)

This ensures **no accidental rollbacks** and full auditability.

---

## 🗂️ Version History

Two files track production versions:

```
last_version_production.txt
previous_version_production.txt
```

These are updated automatically during deploys and promotions.

Rollback always targets the previous version.

---

## ⚙️ Workflows

### 1. deploy_staging.yml
Triggered on push to `main`:
- Builds Docker image
- Pushes to ECR
- Deploys to staging EC2
- Sends Slack success/failure message
- Shows “Promote to Production” button

---

### 2. promote_to_production.yml
Triggered by Slack:
- Reads staging version
- Retags staging image as production
- Deploys to production EC2
- Updates version files
- Sends Slack success/failure message

---

### 3. deploy_production.yml
Manual workflow:
- Builds production image
- Pushes to ECR
- Updates version history
- Deploys to EC2
- Sends Slack message with **Rollback Production** button

---

### 4. rollback_preview.yml
Triggered by Slack:
- Reads version files
- Sends Slack preview with:
  - Current version
  - Target version
  - Confirm / Cancel buttons

---

### 5. rollback_confirm.yml
Triggered by Slack:
- Sends Slack “Rollback Confirmed”
- Triggers internal rollback workflow
- Sends Slack “Rollback Completed”

---

### 6. rollback_cancel.yml
Triggered by Slack:
- Sends Slack “Rollback Cancelled”

---

### 7. rollback_production.yml (internal only)
Triggered by:
```
rollback_production_internal
```
Executes the actual rollback on EC2.

---

## 🧠 Lambda (index.js)

Handles Slack interactive actions:

- `promote_to_production`
- `rollback_production` → preview
- `rollback_confirm`
- `rollback_cancel`

Sends GitHub repository_dispatch events.

---

## 🖥️ EC2 Deployment Scripts

Located in:

```
scripts/
```

Includes:

- `deploy_staging.sh`
- `deploy_production.sh`
- `rollback_production.sh`
- `healthcheck.sh`
- `logs.sh`

These scripts run directly on EC2.

---

## 🔐 Secrets Required

Stored in GitHub Actions:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`
- `EC2_STAGING_HOST`
- `EC2_PRODUCTION_HOST`
- `SSH_PRIVATE_KEY`
- `SLACK_WEBHOOK_URL`
- `GITHUB_TOKEN`

Stored in Lambda:

- `GITHUB_TOKEN`

---

## 🧪 Testing Phase‑2 (Confirm/Cancel)

We test in this exact order:

### 1. Push all updated workflows + README to GitHub
Commit message:
```
feat: add Phase-2 Slack Confirm/Cancel rollback system + version history
```

### 2. Trigger a staging deploy
Push to `main`.

### 3. Promote to production
Click the Slack button.

### 4. Trigger rollback preview
Click **Rollback Production** in Slack.

### 5. Confirm rollback
Click **Confirm Rollback**.

### 6. Validate rollback
Check EC2 logs + Slack messages.

### 7. Test Cancel
Trigger preview again → click **Cancel**.

Everything should work end‑to‑end.

---

## 🧹 AWS Shutdown Steps (to stop billing)

Once testing is complete:

### 1. Terminate EC2 instances
- Staging EC2
- Production EC2

### 2. Delete ECR repositories
- `myapp-staging`
- `myapp-production`

### 3. Remove IAM user/role used for CI/CD

### 4. Remove Lambda + API Gateway

### 5. Remove unused security groups

This stops all AWS charges

---

## 🏁 Project Status
Phase‑2 (Confirm/Cancel Rollback) — **COMPLETE**  
Slack → Lambda → GitHub → EC2 — **Fully operational**  
Version History — **Enabled**  
Rollback Safety — **Enabled**  
Promotion Flow — **Enabled**

