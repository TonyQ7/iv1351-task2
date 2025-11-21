# IV1351 Project Task 2: OLAP Queries & Optimization

This repository contains the SQL scripts required to complete Task 2 (Logical Database Design & Querying) for the IV1351 Data Storage Paradigms course. It covers both the **Mandatory** and **Higher Grade** requirements.

## Prerequisites
* PostgreSQL
* pgAdmin 4 (or any SQL client)

## File Descriptions

* **`setup.sql`**: 
    * **Action:** Drops existing tables, creates the full schema (`Teacher`, `Course`, `Course_Instance`, `Work_Allocation`), and inserts consistent mock data.
    * **Purpose:** Sets up a clean, working environment for testing.

* **`mandatory.sql`**:
    * **Action:** Executes the 4 required OLAP queries (Planned Hours, Actual Allocation, Teacher Load, Overworked Teachers).
    * **Purpose:** Generates the specific reports required for the mandatory part of the assignment.

* **`higher_grade.sql`**:
    * **Action:** Creates Indexes for high-frequency queries and a Materialized View for resource-intensive aggregations. Includes `EXPLAIN ANALYZE` statements.
    * **Purpose:** Demonstrates performance optimizations and cost analysis for the higher grade part.

## How to Run

Execute the scripts in the following specific order using the **Query Tool** in pgAdmin 4:

1.  **Initialize Database:**
    * Open `setup.sql`.
    * Press **F5 (Execute)**. 
    * *Verify: Output should say "Database Setup Complete".*

2.  **Generate Mandatory Reports:**
    * Open `mandatory.sql`.
    * Press **F5 (Execute)**.
    * *Note: Capture screenshots of the output tables and the Query Plan for the final query (Overworked Teachers).*

3.  **Apply Optimizations:**
    * Open `higher_grade.sql`.
    * Press **F5 (Execute)**.
    * *Note: Check the "Explain" tab to see the performance improvement (Index Scan vs. Seq Scan) compared to Step 2.*
