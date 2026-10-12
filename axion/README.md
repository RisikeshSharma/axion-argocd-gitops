# 📦 Axion Helm Chart

Production-ready Helm chart for deploying the **Axion IoT Telemetry, Analytics & Digital Twin Platform** on Kubernetes (AWS EKS, Minikube, Kind, etc.).

---

## 🏗️ Architecture & Included Microservices

| Service | Kubernetes Resource | Container Image | Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **PostgreSQL** | Deployment & Service | `postgres:16` | `5432` | Relational database with automatic schema/extensions init via ConfigMap |
| **Ingestion Service** | Deployment & Service | `rishi7211/ingestion:v1` | `8000` | FastAPI service ingesting real-time sensor readings |
| **Telemetry Query Service** | Deployment & Service | `rishi7211/telemetry:v1` | `8000` | FastAPI service serving analytics, trends, anomalies & digital twin APIs |
| **Data Simulator** | Deployment | `rishi7211/simulator:v1` | — | Background worker simulating 27+ industrial refinery sensors |
| **Axion UI** | Deployment & Service | `rishi7211/axion-ui:v1` | `80` | React/Vite Frontend dashboard served by Nginx |
| **AWS ALB Ingress** | Ingress | — | `80/443` | Routes traffic to UI (`axionaws.*`) & Backend (`backendaws.*`) |
| **pgAdmin** *(Optional)* | Deployment & Service | `dpage/pgadmin4:latest` | `80` | Web UI for PostgreSQL administration (toggle via `pgadmin.enabled`) |

---

## 📁 Directory Structure

```
helm/axion/
├── .helmignore
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration values
├── values-dev.yaml         # Lightweight development overrides
├── values-prod.yaml        # Production overrides (EKS, EBS gp3 PVC, HA)
├── README.md               # Documentation & usage guide
└── templates/
    ├── _helpers.tpl                         # Template naming and label helpers
    ├── namespace.yaml                       # Namespace creation
    ├── postgres-secret.yaml                 # Database credentials secret
    ├── postgres-configmap-initdb.yaml       # Auto-init schema (pgcrypto, telemetry, alerts)
    ├── postgres-pvc.yaml                    # Persistent volume claim (optional)
    ├── postgres-deployment.yaml             # PostgreSQL deployment
    ├── postgres-service.yaml                # PostgreSQL service
    ├── ingestion-deployment.yaml            # Ingestion service deployment
    ├── ingestion-service.yaml               # Ingestion cluster service
    ├── telemetry-query-deployment.yaml      # Telemetry Query service deployment
    ├── telemetry-query-service.yaml         # Telemetry Query cluster service
    ├── simulator-deployment.yaml            # IoT sensor simulator deployment
    ├── axion-ui-deployment.yaml             # React UI deployment
    ├── axion-ui-service.yaml                # React UI cluster service
    ├── pgadmin-deployment.yaml              # pgAdmin deployment (conditional)
    ├── pgadmin-service.yaml                 # pgAdmin service (conditional)
    ├── ingress.yaml                         # AWS ALB Ingress
    └── NOTES.txt                            # Post-installation instructions
```

---

## 🚀 Quick Start Guide

### 1. Chart Validate / Lint Karein
Chart syntax aur templates check karne ke liye:
```bash
helm lint ./helm/axion
```

### 2. Manifests Render Karke Dry-Run Karein
Deploy karne se pehle generated YAML dekhne ke liye:
```bash
helm template axion ./helm/axion
```

### 3. Deploy on Kubernetes / AWS EKS

#### Default Configuration ke sath:
```bash
helm install axion ./helm/axion --namespace axion --create-namespace
```

#### Development Environment me (Minikube / Kind / Local):
```bash
helm install axion ./helm/axion -f ./helm/axion/values-dev.yaml --namespace axion --create-namespace
```

#### Production EKS me:
```bash
helm install axion ./helm/axion -f ./helm/axion/values-prod.yaml --namespace axion --create-namespace
```

---

## 🔄 Upgrade & Rollback

### Helm Upgrade (Changes apply karne ke liye):
```bash
helm upgrade axion ./helm/axion -f ./helm/axion/values-prod.yaml --namespace axion
```

### Rollback (Kisi previous revision par wapas jane ke liye):
```bash
helm history axion --namespace axion
helm rollback axion 1 --namespace axion
```

### Uninstall / Clean Up:
```bash
helm uninstall axion --namespace axion
```

---

## ⚙️ Configuration Reference (`values.yaml`)

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `namespace.create` | Create namespace if not exists | `true` |
| `namespace.name` | Target namespace name | `axion` |
| `postgres.enabled` | Deploy PostgreSQL database | `true` |
| `postgres.replicaCount` | Replicas for PostgreSQL | `2` (set to `1` in prod with PVC) |
| `postgres.auth.username` | Database username | `axion_user` |
| `postgres.auth.password` | Database password | `Admin@1234` |
| `postgres.auth.database` | Database name | `axion_db` |
| `postgres.initdb.enabled` | Auto-create extensions & tables | `true` |
| `postgres.persistence.enabled` | Enable PersistentVolumeClaim | `false` (default) / `true` (prod) |
| `postgres.persistence.storageClass` | StorageClass for PVC | `gp3` |
| `ingestion.replicaCount` | Ingestion service replicas | `2` |
| `telemetryQuery.replicaCount` | Telemetry query replicas | `5` |
| `simulator.replicaCount` | Simulator replicas | `2` |
| `simulator.intervalSeconds` | Seconds between telemetry emissions | `5` |
| `ui.replicaCount` | Frontend UI replicas | `2` |
| `pgadmin.enabled` | Deploy pgAdmin 4 management UI | `false` |
| `ingress.enabled` | Enable AWS ALB Ingress | `true` |
| `ingress.className` | Ingress class | `alb` |
| `ingress.rules[0].host` | Frontend UI hostname | `axionaws.rishikesharma.online` |
| `ingress.rules[1].host` | Backend API hostname | `backendaws.rishikesharma.online` |

---

## 🔍 Local Verification (Port-Forwarding)

Cluster banne ke baad local testing ke liye:

```bash
# Frontend UI (http://localhost:3000)
kubectl port-forward svc/axion-ui-service 3000:80 -n axion

# Backend API Swagger Docs (http://localhost:8000/docs)
kubectl port-forward svc/telemetry-query-service 8000:8000 -n axion

# PostgreSQL DB (localhost:5432)
kubectl port-forward svc/postgres-service 5432:5432 -n axion
```
