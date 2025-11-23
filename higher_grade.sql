/* ==============================================================
   HIGHER GRADE - OPTIMIZATIONS
   ============================================================== */

-- 1. INDEX OPTIMIZATION (For the High Frequency Query 5)
-- We join Work_Allocation and Course_Instance often.
-- Indexing the foreign keys helps the JOIN performance.

CREATE INDEX idx_allocation_instance ON "Work_Allocation"("Instance_ID");
CREATE INDEX idx_instance_period ON "Course_Instance"("Period");

-- RUN EXPLAIN ANALYZE AGAIN on Query 4/5 to see improvement
EXPLAIN ANALYZE
SELECT 
    T."Employee_ID", 
    T."Name", 
    CI."Period", 
    COUNT(DISTINCT CI."Instance_ID") 
FROM "Teacher" T
JOIN "Work_Allocation" WA ON T."Employee_ID" = WA."Employee_ID"
JOIN "Course_Instance" CI ON WA."Instance_ID" = CI."Instance_ID"
WHERE CI."Period" = 2 
GROUP BY T."Employee_ID", T."Name", CI."Period"
HAVING COUNT(DISTINCT CI."Instance_ID") > 0;


-- 2. MATERIALIZED VIEW (For Expensive Aggregations like Query 3)
-- Justification: Calculating total load involves summing thousands of rows. 
-- Since this is checked only 5x/day, we can cache the result.

DROP MATERIALIZED VIEW IF EXISTS "MatView_TeacherLoad";

CREATE MATERIALIZED VIEW "MatView_TeacherLoad" AS
SELECT 
    T."Name",
    CI."Period",
    SUM(WA."Hours" * WA."Factor") AS "Total_Load"
FROM "Teacher" T
JOIN "Work_Allocation" WA ON T."Employee_ID" = WA."Employee_ID"
JOIN "Course_Instance" CI ON WA."Instance_ID" = CI."Instance_ID"
GROUP BY T."Name", CI."Period";

-- Create an index on the view itself for faster lookup
CREATE INDEX idx_mat_view_teacher ON "MatView_TeacherLoad"("Name");

-- Demonstrate Querying the View
SELECT * FROM "MatView_TeacherLoad" WHERE "Name" = 'Niharika Gauraha';

-- Demonstrate Refreshing the View (Simulating data update)
REFRESH MATERIALIZED VIEW "MatView_TeacherLoad";