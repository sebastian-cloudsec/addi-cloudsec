# Addi CloudSec — Secure Cloud Foundations

> Cloud Security Engineer Business Case | Sebastián | 2025

## Overview

This repository contains the full business case submission for the Cloud Security Engineer role at Addi. The goal: move from a permissive single-namespace EKS architecture to a Verified Cloud Ecosystem where security is embedded in IaC and runtime.

---

## Deliverables

| # | Deliverable | Location |
|---|---|---|
| I | Strategic Memo (Threat Model, Policy-as-Code, Zero Trust) | [`memo/`](./memo/) |
| II | Architectural Diagrams (Hub & Spoke, Identity Flow, Inbound Defense, Security Data Lake) | [`diagrams/`](./diagrams/) |
| III | Strategic README (Identity Rationale, Audit-Ready Path, Cost of Security) | This document |
| IV | Terraform Module — IRSA Workload Identity | [`terraform/`](./terraform/) |

---

## Part III — Strategic README

### 1. Identity Strategy — Why OIDC + IRSA

IRSA (IAM Roles for Service Accounts) was chosen over Pod Identity and IAM Roles Anywhere for four reasons specific to Addi's context:

- **SFC audit requirement**: workload-level CloudTrail attribution is mandatory for Compañía de Financiamiento compliance. IRSA provides this cryptographically — every AWS API call is tagged with the specific service account identity that made it.
- **Multi-tenant isolation**: the trust policy pins each IAM role to a specific `namespace` + `service_account_name` combination. A compromised pod in `payments` cannot assume the `origination` role even if running on the same node.
- **IaC maturity**: the Terraform module (Part IV) makes workload identity self-service. Teams declare their required AWS resources — the module generates the scoped role automatically.
- **Proven compliance track record**: IRSA has been the standard in regulated financial services environments globally since 2019.

> **IAM Roles Anywhere** is not applicable to EKS-native workloads. It uses X.509 certificates for on-premises servers and hybrid workloads accessing AWS — not for native EKS workloads.

---

### 2. Audit-Ready Path — Compañía de Financiamiento (SFC)

The architecture generates audit evidence automatically as a by-product of normal operations. When SFC auditors arrive, the answer to most questions is a query — not a manually assembled spreadsheet.

| Audit Requirement | Automated Evidence |
|---|---|
| Who accessed production and what did they do? | CloudTrail + ZTNA session logs + EKS audit logs |
| Minimum permissions per system? | IAM Access Analyzer reports based on actual CloudTrail usage |
| Logs not modified? | S3 Object Lock (Compliance mode) + CloudTrail SHA-256 hash chain |
| Dev/prod separation? (PCI-DSS Req. 6.4) | AWS Organizations account structure |
| Change management? | PR scan reports with check IDs, approver, timestamp, deployment record |
| Incident response tested? | Break-glass runbook + quarterly staging drill records |

---

### 3. Cost of Security — Optimization Strategy

| Service | Main Cost Driver | Optimization |
|---|---|---|
| CloudTrail | Data events at scale | Write-only events + ARN filtering + exclude high-volume service roles |
| GuardDuty | Optional protection plans | Active regions only. EKS + S3 plans mandatory for PCI. |
| KMS | API calls at scale | Envelope encryption + DEK caching (80-90% reduction) |
| Security Lake | Ingestion + retention | S3 Intelligent-Tiering + tiered retention (90d / 1yr / 7yr) |

> **ROI**: GuardDuty EKS Protection ~$2,000-5,000/month. Average financial data breach cost in Latin America (IBM 2024): $3.5M.

---

## Terraform Module — Quick Start

```hcl
module "payments_irsa" {
  source               = "./terraform/modules/irsa"
  cluster_name         = "addi-prod"
  service_account_name = "payments-svc"
  namespace            = "payments"
  resource_arns        = ["arn:aws:dynamodb:us-east-1:123456789012:table/addi-payments-prod"]
  allowed_actions      = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"]
}
```

4 inputs → complete least-privilege IAM workload identity. Scales to 5,000 services without operational overhead.

---

## Repository Structure
