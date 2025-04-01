# ELT Pipeline with dbt, Snowflake, and Airflow

This repository contains an **ELT (Extract, Load, Transform)** pipeline built using **dbt**, **Snowflake**, and **Apache Airflow**. The pipeline processes sample transactional data from Snowflake's TPCH dataset, transforms it into a structured data mart, and automates the workflow with Airflow(Astronomer).

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Pipeline Structure](#pipeline-structure)
- [Running the Pipeline](#running-the-pipeline)
- [Testing](#testing)
- [Deployment on Airflow](#deployment-on-airflow)
- [Contributing](#contributing)
- [License](#license)

## Overview
This pipeline:
- **Extracts** raw data from Snowflake's TPCH sample dataset (`orders` and `lineitem` tables).
- **Loads** it into staging models for cleaning and structuring.
- **Transforms** it into a final fact table (`fct_orders`) with order details and financial metrics.
- **Orchestrates** the process using Airflow for daily execution.

The pipeline leverages:
- **Snowflake**: Cloud data warehouse for storage and querying.
- **dbt**: Transformation layer with models, macros, and tests.
- **Airflow**: Workflow orchestration for scheduling and monitoring.

## Prerequisites
- **Snowflake Account**: Access to a Snowflake instance with the `snowflake_sample_data.tpch_sf1` dataset.
- **dbt**: Installed locally or via Docker (version compatible with `dbt-snowflake`).
- **Airflow**: Installed locally or in a containerized environment (e.g., Docker).
- **Python**: Version 3.8+ for Airflow and dbt dependencies.
- **Git**: For cloning and managing this repository.

## Setup Instructions
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Set Up Snowflake**:
   - Run the SQL script in `snowflake_setup.sql` to create the warehouse, database, role, and schema:
     ```sql
     use role accountadmin;
     create warehouse dbt_wh with warehouse_size='x-small';
     create database if not exists dbt_db;
     create role if not exists dbt_role;
     grant role dbt_role to user <your-username>;
     grant usage on warehouse dbt_wh to role dbt_role;
     grant all on database dbt_db to role dbt_role;
     use role dbt_role;
     create schema if not exists dbt_db.dbt_schema;
     ```
   - Replace `<your-username>` with your Snowflake user.

3. **Configure dbt**:
   - Update `dbt_profile.yaml` in the `models/` directory with your Snowflake credentials if needed.
   - Ensure the warehouse (`dbt_wh`) matches your setup.

4. **Install Dependencies**:
   - For dbt: Use the `Dockerfile` or install `dbt-snowflake` manually:
     ```bash
     pip install dbt-snowflake
     ```
   - For Airflow: Update `requirements.txt` and install:
     ```bash
     pip install -r requirements.txt
     ```

5. **Set Up Airflow**:
   - Configure the Snowflake connection in the Airflow UI (see [Deployment on Airflow](#deployment-on-airflow)).

## Pipeline Structure
The project follows a modular dbt structure:

- **`models/staging/`**: Staging models (`stg_tpch_orders.sql`, `stg_tpch_line_items.sql`) and source definitions (`tpch_sources.yml`).
- **`models/marts/`**: Intermediate (`int_order_items.sql`, `int_order_items_summary.sql`) and final fact table (`fct_orders.sql`).
- **`macros/`**: Reusable logic (`pricing.sql` for discount calculations).
- **`tests/`**: Singular tests (`fct_orders_discount.sql`, `fct_orders_date_valid.sql`) and generic tests (`generic_tests.yml`).
- **`snowflake_setup.sql`**: Snowflake environment setup script.
- **`dbt_dag.py`**: Airflow DAG for orchestration.
- **`Dockerfile` & `requirements.txt`**: Dependencies for deployment.

### Data Flow
1. **Source**: `snowflake_sample_data.tpch_sf1` (tables: `orders`, `lineitem`).
2. **Staging**: Cleaned views (`stg_tpch_orders`, `stg_tpch_line_items`).
3. **Intermediate**: Joined and enriched data (`int_order_items`, `int_order_items_summary`).
4. **Final**: Fact table (`fct_orders`) with order and financial metrics.

## Running the Pipeline
1. **Test dbt Locally**:
   ```bash
   dbt run --profiles-dir .
   dbt test --profiles-dir .
   ```
   - Ensure your `profiles.yml` is configured with Snowflake credentials.

2. **Verify Output**:
   - Check the `dbt_db.dbt_schema` schema in Snowflake for materialized tables and views.

## Testing
- **Generic Tests**: Enforce uniqueness, non-null constraints, and valid values (e.g., `status_code` in `P`, `O`, `F`).
- **Singular Tests**: Validate business logic (e.g., discounts are negative, dates are within a valid range).
- Run tests with:
  ```bash
  dbt test
  ```

## Deployment on Airflow
1. **Update Dockerfile**:
   - Builds a virtual environment with `dbt-snowflake`.

2. **Configure Airflow**:
   - Add the Snowflake connection in the Airflow UI:
     ```json
     {
       "account": "<account_locator>-<account_name>",
       "warehouse": "dbt_wh",
       "database": "dbt_db",
       "role": "dbt_role",
       "insecure_mode": false
     }
     ```
   - Place `dbt_dag.py` in the Airflow `dags/` folder.

3. **Run the DAG**:
   - The DAG (`dbt_dag`) runs daily, starting from September 10, 2023.
   - Trigger it manually or let the scheduler handle it.

## Contributing
- Fork the repository and submit pull requests for enhancements.
- Report issues or suggest improvements via the GitHub Issues tab.
