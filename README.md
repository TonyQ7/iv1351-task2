# IV1351 Project Task 2: OLAP Queries & Optimization

This repository contains the SQL scripts required to complete Task 2 (Logical Database Design & Querying). It covers both the **Mandatory** and **Higher Grade** requirements.

## Prerequisites
* PostgreSQL
* pgAdmin 4 (or any standard SQL client)

## File Descriptions

* **`setup.sql`**: 
    * **Action:** Creates the full schema including `person`, `employee`, `department`, `course_instance`, `allocation`, `planned_activity`, and versioned tables for salaries and course layouts. Inserts consistent mock data.
    * **Purpose:** Sets up a clean, working environment for testing.

* **`mandatory.sql`**:
    * **Action:** Executes the required OLAP queries:
        1. Planned hours per course instance.
        2. Allocated hours per course instance (breakdown by teacher/activity).
        3. Total load per teacher.
        4. Teachers with excessive course loads.
    * **Purpose:** Generates the specific reports required for the mandatory part of the assignment.

* **`higher_grade.sql`**:
    * **Action:** * Implements the complex "Variance > 15%" query (Planned vs Allocated).
        * Creates Indexes for high-frequency queries.
        * Creates a Materialized View for resource-intensive aggregations (Teacher Load).
        * Uses `EXPLAIN ANALYZE` to demonstrate performance costs.
    * **Purpose:** Demonstrates performance optimizations and cost analysis for the higher grade.

## How to Run

Execute the scripts in the following specific order:

1.  **Initialize Database:**
    * Run `setup.sql`.
    * *Verify: Output should indicate successful creation of tables and views.*

2.  **Generate Mandatory Reports:**
    * Run `mandatory.sql`.
    * *Note: The output tables correspond to the requirements in the assignment text.*

3.  **Run Optimizations & Analysis:**
    * Run `higher_grade.sql`.
    * *Note: Check the "Messages" or "Explain" tab to see the query plans (Scan vs Index Scan).*

## Notes on Data
The dataset provided in `setup.sql` is a small mock set for verification. 
* **Teacher Load Check:** In `mandatory.sql`, the query checks for teachers with `> 1` course to demonstrate functionality with the small dataset. In a real scenario, this threshold would be `> 4`.
