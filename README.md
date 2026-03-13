# Hevo Customer Success Engineer – Technical Assessment

## Overview

This project demonstrates an **end-to-end ELT data pipeline** built using PostgreSQL, Hevo Data, Snowflake, and dbt.

The objective of the assessment was to:

1. Deploy a PostgreSQL database using Docker.
2. Load transactional CSV data into PostgreSQL.
3. Build a data pipeline using **Hevo Data** with **Logical Replication** ingestion.
4. Load the data into **Snowflake**.
5. Use **dbt** to build an analytics model named `customers`.
6. Implement **dbt tests** to ensure data quality.

The final output is an analytics table that aggregates customer order activity and lifetime value.

---

# Architecture

```
PostgreSQL (Docker on AWS EC2)
        │
        │ Logical Replication (CDC)
        ▼
Hevo Data Pipeline
        │
        ▼
Snowflake Data Warehouse
(HEVO_DB.SNOWFLAKE2_PUBLIC)
        │
        ▼
dbt Transformations
        │
        ▼
HEVO_DEMO.ANALYTICS.CUSTOMERS
```

---

# Technologies Used

| Technology | Purpose                                |
| ---------- | -------------------------------------- |
| PostgreSQL | Source transactional database          |
| Docker     | Containerized PostgreSQL deployment    |
| AWS EC2    | Cloud VM hosting PostgreSQL            |
| Hevo Data  | Data pipeline and ingestion platform   |
| Snowflake  | Cloud data warehouse                   |
| dbt        | Data transformation and modeling       |
| GitHub     | Version control and project repository |

---

# Step 1 – PostgreSQL Setup

PostgreSQL was deployed using a **Docker container on an AWS EC2 instance**.

Docker command used:

```
docker run -d \
--name hevo-postgres \
-e POSTGRES_USER=hevo_user \
-e POSTGRES_PASSWORD=hevo_pass \
-e POSTGRES_DB=hevo_db \
-p 5432:5432 \
postgres:14
```

---

# Step 2 – Source Tables

Three source tables were created in PostgreSQL:

```
raw_customers
raw_orders
raw_payments
```

CSV files provided in the assessment were loaded into the tables using the PostgreSQL `COPY` command.

Example:

```
COPY raw_customers
FROM '/raw_customers.csv'
DELIMITER ','
CSV HEADER;
```

---

# Step 3 – Logical Replication Configuration

Hevo requires **Logical Replication** for CDC ingestion.

The following objects were created in PostgreSQL.

### Publication

```
CREATE PUBLICATION hevo_publication
FOR TABLE raw_customers, raw_orders, raw_payments;
```

### Replication Slot

```
SELECT *
FROM pg_create_logical_replication_slot('hevo_slot', 'pgoutput');
```

This allows Hevo to capture ongoing data changes from PostgreSQL.

---

# Step 4 – Hevo Pipeline

A pipeline was created in **Hevo Data**.

### Source

PostgreSQL database hosted on AWS EC2.

### Destination

Snowflake warehouse.

### Ingestion Mode

Logical Replication.

The pipeline loads data from PostgreSQL into Snowflake tables:

```
HEVO_DB.SNOWFLAKE2_PUBLIC.RAW_CUSTOMERS
HEVO_DB.SNOWFLAKE2_PUBLIC.RAW_ORDERS
HEVO_DB.SNOWFLAKE2_PUBLIC.RAW_PAYMENTS
```

---

# Step 5 – dbt Transformation

A dbt project was created to transform the raw data into an analytics model.

Command used:

```
dbt init hevo_demo
```

The transformation model:

```
models/customers.sql
```

Creates the final analytics table:

```
HEVO_DEMO.ANALYTICS.CUSTOMERS
```

---

# Customers Model

The `customers` model aggregates order and payment data to produce customer-level metrics.

### Columns Generated

| Column                  | Description                    |
| ----------------------- | ------------------------------ |
| customer_id             | Unique identifier for customer |
| first_name              | Customer first name            |
| last_name               | Customer last name             |
| first_order             | Date of the first order        |
| most_recent_order       | Date of the latest order       |
| number_of_orders        | Total number of orders         |
| customer_lifetime_value | Sum of all payments made       |

Key calculations:

```
MIN(order_date) → first_order
MAX(order_date) → most_recent_order
COUNT(order_id) → number_of_orders
SUM(amount) → customer_lifetime_value
```

---

# Step 6 – dbt Tests

Data quality tests were implemented using dbt.

Defined in:

```
models/schema.yml
```

Tests included:

```
not_null(customer_id)
unique(customer_id)
not_null(first_name)
not_null(last_name)
```

Run tests using:

```
dbt test
```

---

# Running the Project

### Install dbt Snowflake Adapter

```
pip install dbt-snowflake
```

### Run dbt Models

```
dbt run
```

### Run Tests

```
dbt test
```

---

# Security Considerations

Sensitive credentials are **not included in this repository**.

Snowflake credentials are stored locally in:

```
~/.dbt/profiles.yml
```

Hevo connection credentials are configured securely within the **Hevo platform UI**.

The repository includes a `.gitignore` file to prevent sensitive or generated files from being committed.

---

# Repository Structure

```
HevoData_Demo
│
├ models
│   ├ customers.sql
│   └ schema.yml
│
├ analyses
├ macros
├ seeds
├ snapshots
├ tests
│
├ dbt_project.yml
├ README.md
└ .gitignore
```

---

# Deliverables

This repository includes:

* dbt transformation models
* dbt tests
* Project documentation

Additional submission components:

* Loom video explaining the pipeline
* Hevo Team ID
* Pipeline ID

---

# Author

**Vaishnavi Khandelwal**

GitHub:
https://github.com/vaishnavikhandelwal70-ui
