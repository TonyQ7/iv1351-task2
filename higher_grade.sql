/* ==============================================================
   HIGHER GRADE - OPTIMIZATIONS & ANALYSIS
   ============================================================== */

EXPLAIN ANALYZE
WITH allocated_sum AS (
    SELECT 
        course_instance_id, 
        SUM(allocated_hours) AS total_allocated
    FROM allocation
    GROUP BY course_instance_id
)
SELECT 
    ci.course_code, 
    ci.instance_id, 
    p.total_effective_hours AS planned_hours,
    COALESCE(a.total_allocated, 0) AS allocated_hours,
    CASE 
        WHEN p.total_effective_hours > 0 THEN 
            ABS(p.total_effective_hours - COALESCE(a.total_allocated, 0)) / p.total_effective_hours 
        ELSE 0 
    END AS variance_ratio
FROM v_course_instance_total_hours p
JOIN course_instance ci ON ci.instance_id = p.instance_id
LEFT JOIN allocated_sum a ON a.course_instance_id = p.instance_id
WHERE 
    CASE 
        WHEN p.total_effective_hours > 0 THEN 
            ABS(p.total_effective_hours - COALESCE(a.total_allocated, 0)) / p.total_effective_hours 
        ELSE 0 
    END > 0.15;


-- 1. INDEX OPTIMIZATION (For High Frequency Queries)
-- The "Teachers with > N courses" query runs 20x/day.
-- We join allocation, employee, and course_instance often.

CREATE INDEX IF NOT EXISTS idx_allocation_instance ON allocation(course_instance_id);
CREATE INDEX IF NOT EXISTS idx_allocation_employee ON allocation(employee_id);
CREATE INDEX IF NOT EXISTS idx_instance_period ON course_instance(study_period);

-- Rerun the High Frequency Query (Query 5 in list) with EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT 
    e.employee_id, 
    p.first_name, 
    p.last_name, 
    ci.study_period, 
    COUNT(DISTINCT ci.instance_id) AS num_courses
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
JOIN allocation a ON e.employee_id = a.employee_id
JOIN course_instance ci ON a.course_instance_id = ci.instance_id
WHERE ci.study_period = 'P1' 
GROUP BY e.employee_id, p.first_name, p.last_name, ci.study_period
HAVING COUNT(DISTINCT ci.instance_id) > 1; -- Using 1 for testing (mock data), normally 4


-- 2. MATERIALIZED VIEW (For Expensive Aggregations)
-- Justification: "Teacher Load per Period" (Query 3 in list) involves summing 
-- allocated hours across all activities and joining multiple tables.
-- Since this is read 5x/day but data changes less frequently, caching helps.

DROP MATERIALIZED VIEW IF EXISTS mat_teacher_load;

CREATE MATERIALIZED VIEW mat_teacher_load AS
SELECT 
    p.first_name,
    p.last_name,
    ci.study_period,
    ci.study_year,
    SUM(a.allocated_hours) AS total_load_hours
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
JOIN allocation a ON e.employee_id = a.employee_id
JOIN course_instance ci ON a.course_instance_id = ci.instance_id
GROUP BY p.first_name, p.last_name, ci.study_period, ci.study_year;

-- Create an index on the view itself for faster lookup by name
CREATE INDEX idx_mat_teacher_name ON mat_teacher_load(last_name, first_name);

-- Demonstrate Querying the View
EXPLAIN ANALYZE
SELECT * FROM mat_teacher_load 
WHERE last_name = 'Nyström' AND study_period = 'P1';
