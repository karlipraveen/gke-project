# 1.3.1 Creating Cloud SQL (MySQL) Database

Google Cloud equivalent of **Amazon RDS MySQL** is **Cloud SQL for MySQL**.

Cloud SQL is a fully managed relational database service that provides automatic backups, high availability, monitoring, security, and automatic maintenance.

## Steps

1. Login to Google Cloud Console

2. Navigate to

```
SQL → Create Instance
```

3. Select

```
MySQL
```

4. Configure

- Instance Name
- Database Version
- Region
- Zone
- Machine Type
- Storage Type (SSD)
- Storage Capacity

Example

```
Instance Name : fashion-mysql-prod

Database Version : MySQL 8.0

Region : us-central1

Zone : us-central1-a

Machine Type : db-custom-2-4096

Storage : SSD

Capacity : 100 GB
```

5. Create Database

```
fashiondb
```

6. Create Database User

```
fashionadmin
```

---

# Terraform Example

```hcl
resource "google_sql_database_instance" "mysql" {

  name             = "fashion-mysql-prod"

  region           = var.region

  database_version = "MYSQL_8_0"

  settings {

    tier = "db-custom-2-4096"

    disk_size = 100

    disk_type = "PD_SSD"

  }

}

resource "google_sql_database" "fashiondb" {

  name     = "fashiondb"

  instance = google_sql_database_instance.mysql.name

}

resource "google_sql_user" "mysql_user" {

  name     = "fashionadmin"

  instance = google_sql_database_instance.mysql.name

  password = "ReplaceWithSecret"

}
```

---

# 1.3.2 Implementing Secret Manager

Instead of

```
AWS Secrets Manager
```

Google Cloud uses

```
Secret Manager
```

It securely stores

- Database Username
- Database Password
- API Keys
- Certificates
- OAuth Tokens

without exposing them inside source code.

---

## Create Secret

```
Google Cloud Console

↓

Security

↓

Secret Manager

↓

Create Secret
```

Example

```
Secret Name

mysql-password
```

Value

```
StrongPassword123
```

---

## Terraform

```hcl
resource "google_secret_manager_secret" "mysql_secret" {

  secret_id = "mysql-password"

  replication {

    auto {}

  }

}

resource "google_secret_manager_secret_version" "mysql_secret_version" {

  secret = google_secret_manager_secret.mysql_secret.id

  secret_data = "StrongPassword123"

}
```

---

# IAM Permission

Grant GKE Service Account

```
roles/secretmanager.secretAccessor
```

Example

```hcl
resource "google_project_iam_member" "secret_accessor" {

  project = var.project_id

  role = "roles/secretmanager.secretAccessor"

  member = "serviceAccount:${google_service_account.gke_sa.email}"

}
```

---

# 1.3.3 Using Secret Manager in Cloud SQL

Instead of storing passwords inside YAML,

Kubernetes fetches the secret securely.

Example

```
Application

↓

Workload Identity

↓

Secret Manager

↓

Cloud SQL
```

---

## Kubernetes Secret

```yaml
apiVersion: v1

kind: Secret

metadata:

  name: mysql-secret

type: Opaque

stringData:

  username: fashionadmin

  password: StrongPassword123
```

---

## Deployment

```yaml
env:

- name: MYSQL_USER

  valueFrom:

    secretKeyRef:

      name: mysql-secret

      key: username

- name: MYSQL_PASSWORD

  valueFrom:

    secretKeyRef:

      name: mysql-secret

      key: password
```

---

# Workload Identity

Recommended production approach

```
GKE Pod

↓

Workload Identity

↓

Secret Manager

↓

Cloud SQL
```

No passwords are stored inside containers.

---

# 1.3.4 Configure Cloud SQL for High Availability

Google Cloud equivalent of

```
RDS Multi-AZ
```

is

```
Cloud SQL High Availability
```

During instance creation

Enable

```
High Availability

↓

Regional
```

Cloud SQL creates

Primary Instance

↓

Standby Instance

↓

Automatic Failover

---

## Machine Configuration

```
Machine Type

db-custom-2-4096
```

---

## Storage

```
SSD Persistent Disk
```

Enable

```
Automatic Storage Increase
```

Equivalent to

```
AWS Storage Auto Scaling
```

---

## Automated Backups

Enable

```
Automatic Daily Backups
```

Configure

```
Retention Period

Backup Window
```

Point-in-time recovery

Enable

```
Binary Logging
```

---

## Maintenance Window

Configure

```
Sunday

02:00 AM
```

Automatic maintenance during non-business hours.

---

# Cloud Monitoring and Logs

Instead of

```
Amazon CloudWatch
```

Google Cloud uses

```
Cloud Monitoring

Cloud Logging
```

Monitor

- CPU
- Memory
- Connections
- Slow Queries
- Disk Usage
- Replication
- Availability

Navigate

```
Operations

↓

Cloud Monitoring

↓

Dashboards
```

Database Logs

```
Cloud SQL

↓

Logs Explorer
```

Example query

```
resource.type="cloudsql_database"
```

---

# Read Performance

Instead of

```
Amazon ElastiCache
```

Google Cloud provides two common options:

## Option 1 (Recommended)

### Memorystore for Redis

Application

↓

Redis Cache

↓

Cloud SQL

Frequently accessed data is served from Redis.

Terraform

```hcl
resource "google_redis_instance" "redis" {

  name = "fashion-cache"

  tier = "STANDARD_HA"

  memory_size_gb = 4

  region = var.region

}
```

Benefits

- Faster reads
- Lower database load
- High Availability
- Automatic failover

---

## Option 2

Cloud SQL Read Replica

Primary

↓

Read Replica

↓

Application Read Queries

Ideal for reporting and analytics workloads.

Terraform

```hcl
resource "google_sql_database_instance" "read_replica" {

  name = "fashion-mysql-replica"

  master_instance_name = google_sql_database_instance.mysql.name

  region = var.region

  database_version = "MYSQL_8_0"

}
```

---

# 1.3.5 Connecting Cloud SQL to GKE Microservices

Instead of modifying

```
mysql-server-service.yaml
```

modify your application's

```
deployment.yaml

or

values.yaml
```

Example

```yaml
env:

- name: DB_HOST

  value: "10.10.1.5"

- name: DB_NAME

  value: "fashiondb"

- name: DB_USER

  valueFrom:

    secretKeyRef:

      name: mysql-secret

      key: username

- name: DB_PASSWORD

  valueFrom:

    secretKeyRef:

      name: mysql-secret

      key: password
```

For production, use the **Cloud SQL Auth Proxy** sidecar or connector to establish secure connections without exposing database IPs or credentials.

---

# Testing Database Connectivity

## From GKE Pod

```bash
kubectl exec -it <pod-name> -- sh
```

Install MySQL client if required

```bash
apk add mysql-client
```

Connect

```bash
mysql -h <Cloud_SQL_Private_IP> \
-u fashionadmin \
-p
```

---

## Verify Database

```sql
SHOW DATABASES;
```

```sql
USE fashiondb;
```

```sql
SHOW TABLES;
```

---

# Verify Cloud SQL Connectivity

```bash
kubectl logs <pod-name>
```

Look for

```
Database Connected Successfully
```

---

# Verify Secret Access

```bash
kubectl describe pod <pod-name>
```

Check environment variables

```
DB_USER

DB_PASSWORD
```

---

# End-to-End Flow

```text
Developer
      │
      ▼
Terraform
      │
      ▼
Cloud SQL (MySQL)
      │
      ▼
Secret Manager
      │
      ▼
IAM + Workload Identity
      │
      ▼
GKE Deployment
      │
      ▼
Microservices
      │
      ▼
Cloud SQL Auth Proxy
      │
      ▼
Cloud SQL (Primary / HA)
      │
      ├──────────────► Read Replica (optional)
      │
      └──────────────► Memorystore (Redis Cache)
      │
      ▼
Cloud Monitoring & Cloud Logging
```

# AWS to GCP Service Mapping

| AWS | Google Cloud |
|------|--------------|
| Amazon RDS MySQL | Cloud SQL for MySQL |
| AWS Secrets Manager | Secret Manager |
| IAM Role | IAM Service Account + Workload Identity |
| Multi-AZ RDS | Cloud SQL High Availability (Regional) |
| Storage Auto Scaling | Automatic Storage Increase |
| Automated Backups | Automated Backups + Point-in-Time Recovery |
| CloudWatch Logs | Cloud Logging |
| CloudWatch Metrics | Cloud Monitoring |
| ElastiCache (Redis) | Memorystore for Redis |
| RDS Read Replica | Cloud SQL Read Replica |
| RDS Endpoint | Cloud SQL Private IP / Auth Proxy |
