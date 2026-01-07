SET search_path = dsp, public;

--query 1
-- getting all 2025 course instances with their details such as code, name, HP, period, students
SELECT 
    ci.instance_id AS "Course Instance ID",
    ci.course_code AS "Course Code",
    clv.hp AS "HP",
    ci.study_period AS "Period",
    ci.num_students AS "# Students",
    
    -- Sum hours by activity type using the views from Task 1
    COALESCE(SUM(CASE WHEN v.activity_name = 'Lecture' THEN v.effective_hours END), 0) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN v.activity_name = 'Tutorial' THEN v.effective_hours END), 0) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN v.activity_name = 'Lab' THEN v.effective_hours END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN v.activity_name = 'Seminar' THEN v.effective_hours END), 0) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN v.activity_name = 'Other' THEN v.effective_hours END), 0) AS "Other Overhead Hours",
    COALESCE(SUM(CASE WHEN v.activity_name = 'Administration' THEN v.effective_hours END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN v.activity_name = 'Examination' THEN v.effective_hours END), 0) AS "Exam",
    
    SUM(v.effective_hours) AS "Total Hours"

FROM course_instance ci
JOIN course_layout_version clv ON (clv.course_code = ci.course_code AND clv.version_no = ci.layout_version_no)
JOIN v_activity_hours v ON v.course_instance_id = ci.instance_id  -- Use the view!

WHERE ci.study_year = 2025

GROUP BY ci.instance_id, ci.course_code, clv.hp, ci.study_period, ci.num_students
ORDER BY ci.course_code, ci.study_period;

-- Query 2
--for a specific course, show each teacher and their allocated hours by activity
--Picking one course instance
SELECT 
    ci.course_code AS "Course Code",
    ci.instance_id AS "Course Instance ID",
    clv.hp AS "HP",
    (p.first_name || ' ' || p.last_name) AS "Teacher's Name",
    e.job_title AS "Designation",
    
    -- Sum allocated hours by activity type
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN a.allocated_hours END), 0) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN a.allocated_hours END), 0) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN a.allocated_hours END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN a.allocated_hours END), 0) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Other' THEN a.allocated_hours END), 0) AS "Other Overhead Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Administration' THEN a.allocated_hours END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Examination' THEN a.allocated_hours END), 0) AS "Exam",
    
    SUM(a.allocated_hours) AS "Total"

FROM allocation a
JOIN course_instance ci ON ci.instance_id = a.course_instance_id
JOIN course_layout_version clv ON (clv.course_code = ci.course_code AND clv.version_no = ci.layout_version_no)
JOIN employee e ON e.employee_id = a.employee_id
JOIN person p ON p.personal_number = e.personal_number
JOIN teaching_activity ta ON ta.activity_id = a.activity_id

WHERE ci.instance_id = '2025-50273'

GROUP BY ci.course_code, ci.instance_id, clv.hp, p.first_name, p.last_name, e.job_title, e.employee_id
ORDER BY p.last_name, p.first_name;

-- query 3
-- "Calculate the total allocated hours (with multiplication factors) 
--for a teacher, only for the current years' course instance"
SELECT
    ci.course_code AS "Course Code",
    ci.instance_id AS "Course Instance ID",
    clv.hp AS "HP",
    ci.study_period AS "Period",
    (p.first_name || ' ' || p.last_name) AS "Teacher's Name",
    
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN a.allocated_hours END), 0) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN a.allocated_hours END), 0) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN a.allocated_hours END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN a.allocated_hours END), 0) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Other' THEN a.allocated_hours END), 0) AS "Other Overhead Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Administration' THEN a.allocated_hours END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Examination' THEN a.allocated_hours END), 0) AS "Exam",
    
    SUM(a.allocated_hours) AS "Total"

FROM employee e
JOIN person p ON p.personal_number = e.personal_number
JOIN allocation a ON a.employee_id = e.employee_id
JOIN course_instance ci ON ci.instance_id = a.course_instance_id
JOIN course_layout_version clv ON (clv.course_code = ci.course_code AND clv.version_no = ci.layout_version_no)
JOIN teaching_activity ta ON ta.activity_id = a.activity_id

WHERE 
    ci.study_year = 2025
    AND (p.first_name || ' ' || p.last_name) = 'Clara Nyström'  -- Or use employee_id

GROUP BY ci.course_code, ci.instance_id, clv.hp, ci.study_period, p.first_name, p.last_name
ORDER BY ci.study_period, ci.course_code;

-- Query 4: Teachers allocated to more than a specific number of course instances
-- (Using integer threshold between 1-3 as per requirement)
SELECT 
    e.employee_id AS "Employment ID",
    (p.first_name || ' ' || p.last_name) AS "Teacher's Name",
    ci.study_period AS "Period",
    COUNT(DISTINCT ci.instance_id) AS "No of courses"
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
JOIN allocation a ON a.employee_id = e.employee_id
JOIN course_instance ci ON ci.instance_id = a.course_instance_id
WHERE ci.study_year = 2025
GROUP BY e.employee_id, p.first_name, p.last_name, ci.study_period

HAVING COUNT(DISTINCT ci.instance_id) > 1  -- Specific number between 1-3
ORDER BY ci.study_period, COUNT(DISTINCT ci.instance_id) DESC;
