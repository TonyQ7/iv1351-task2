SET search_path = dsp, public;

--query 1
-- getting all 2025 course instances with their details such as code, name, HP, period, students
SELECT 
	h.course_code AS "Course Code",
	h.instance_id AS "Course Instance ID",
	h.hp AS "HP",
	h.study_period AS "Period",
	h.num_students AS "# Students",

	-- summing up the hours for each activity or 0 if that activity doesn't exist
	--effective hours = planned hours × multiplication factor
	COALESCE(SUM(CASE WHEN v.activity_name = 'Lecture' THEN v.effective_hours END), 0) AS "Lecture Hours",
	COALESCE(SUM(CASE WHEN v.activity_name = 'Tutorial' THEN v.effective_hours END), 0) AS "Tutorial Hours",
	COALESCE(SUM(CASE WHEN v.activity_name = 'Lab' THEN v.effective_hours END), 0) AS "Lab Hours",
	COALESCE(SUM(CASE WHEN v.activity_name = 'Seminar' THEN v.effective_hours END), 0) AS "Seminar Hours",
	COALESCE(SUM(CASE WHEN v.activity_name = 'Other' THEN v.effective_hours END), 0) AS "Other Overhead Hours",
	COALESCE(SUM(CASE WHEN v.activity_name = 'Administration' THEN v.effective_hours END), 0) AS "Admin",
	COALESCE(SUM(CASE WHEN v.activity_name = 'Examination' THEN v.effective_hours END), 0) AS "Exam",

	-- Total, the sum of all activities
	SUM(v.effective_hours) AS "Total Hours"

FROM v_course_instance_header h --this view has all course instance details
JOIN v_activity_hours v ON v.course_instance_id = h.instance_id --join to get hours per activity

WHERE h.study_year = 2025 --only 2025 courses

--group by instance
GROUP BY h.course_code, h.instance_id, h.hp, h.study_period, h.num_students
--sort by course code and period
ORDER BY h.course_code, h.study_period;

--query 2

--for a specific course, show each teacher and their allocated hours by activity
--Picking one course instance
SELECT 
	h.course_code AS "Course Code",
	h.instance_id AS "Course Instance ID", 
	h.hp AS "HP", 

    --getting teacher's full name by joining person table
	(p.first_name || ' ' || p.last_name) AS "Teacher's Name",
    --getting their job title
	e.job_title AS "Designation",

	--hours by activity
	COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN a.allocated_hours END), 0) AS "Lecture Hours",
	COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN a.allocated_hours END), 0) AS "Tutorial Hours",
	COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab' THEN a.allocated_hours END), 0) AS "Lab Hours",
	COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN a.allocated_hours END), 0) AS "Seminar Hours",
	COALESCE(SUM(CASE WHEN ta.activity_name = 'Other' THEN a.allocated_hours END), 0) AS "Other Overhead Hours",
	COALESCE(SUM(CASE WHEN ta.activity_name = 'Administration' THEN a.allocated_hours END), 0) AS "Admin",
	COALESCE(SUM(CASE WHEN ta.activity_name = 'Examination' THEN a.allocated_hours END), 0) AS "Exam",

	--Total hours for the teacher in this course
	SUM(a.allocated_hours) AS "Total"

FROM allocation a --starting with allocations
JOIN course_instance ci ON ci.instance_id = a.course_instance_id --getting course info
JOIN v_course_instance_header h ON h.instance_id = ci.instance_id --more course details
JOIN employee e ON e.employee_id = a.employee_id --employee info
JOIN person p ON p.personal_number = e.personal_number --person's name
JOIN teaching_activity ta ON ta.activity_id = a.activity_id --activity names
  
WHERE a.course_instance_id = '2025-50273'

GROUP BY h.course_code, h.instance_id, h.hp, p.first_name, p.last_name, e.job_title, e.employee_id
ORDER BY p.last_name, p.first_name;


SELECT 
    C."Course_Code",
    CI."Instance_ID",
    C."Credits" AS HP,
    CI."Period",
    T."Name" AS "Teacher Name",
    SUM(CASE WHEN WA."Activity" = 'Lecture' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Lecture Hours",
    SUM(CASE WHEN WA."Activity" = 'Tutorial' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Tutorial Hours",
    SUM(CASE WHEN WA."Activity" = 'Lab' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Lab Hours",
    SUM(CASE WHEN WA."Activity" = 'Seminar' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Seminar Hours",
    SUM(WA."Hours" * WA."Factor") AS "Total"
FROM "Teacher" T
JOIN "Work_Allocation" WA ON T."Employee_ID" = WA."Employee_ID"
JOIN "Course_Instance" CI ON WA."Instance_ID" = CI."Instance_ID"
JOIN "Course" C ON CI."Course_Code" = C."Course_Code"
WHERE CI."Year" = 2025
GROUP BY C."Course_Code", CI."Instance_ID", C."Credits", CI."Period", T."Name"
ORDER BY T."Name", CI."Period";


-- For the explain graph press shift f7
SELECT 
    T."Employee_ID",
    T."Name",
    CI."Period",
    COUNT(DISTINCT CI."Instance_ID") AS "No of Courses"
FROM "Teacher" T
JOIN "Work_Allocation" WA ON T."Employee_ID" = WA."Employee_ID"
JOIN "Course_Instance" CI ON WA."Instance_ID" = CI."Instance_ID"
WHERE CI."Year" = 2025
GROUP BY T."Employee_ID", T."Name", CI."Period"
HAVING COUNT(DISTINCT CI."Instance_ID") > 1; -- Using N=1 for this example