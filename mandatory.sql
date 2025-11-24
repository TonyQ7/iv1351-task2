SET search_path = dsp, public;

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

SELECT 
    C."Course_Code",
    CI."Instance_ID",
    C."Credits" AS HP,
    T."Name" AS "Teacher Name",
    T."Designation",
    SUM(CASE WHEN WA."Activity" = 'Lecture' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Lecture Hours",
    SUM(CASE WHEN WA."Activity" = 'Lab' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Lab Hours",
    SUM(CASE WHEN WA."Activity" = 'Seminar' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Seminar Hours",
    SUM(CASE WHEN WA."Activity" = 'Other Overhead' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Overhead Hours",
    SUM(CASE WHEN WA."Activity" = 'Admin' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Admin",
    SUM(CASE WHEN WA."Activity" = 'Exam' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Exam",
    SUM(WA."Hours" * WA."Factor") AS "Total"
FROM "Work_Allocation" WA
JOIN "Course_Instance" CI ON WA."Instance_ID" = CI."Instance_ID"
JOIN "Course" C ON CI."Course_Code" = C."Course_Code"
JOIN "Teacher" T ON WA."Employee_ID" = T."Employee_ID"
WHERE CI."Year" = 2025
GROUP BY C."Course_Code", CI."Instance_ID", C."Credits", T."Name", T."Designation"
ORDER BY C."Course_Code", T."Name";


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