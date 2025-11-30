--SET search_path = dsp, public;

--query 1
-- getting all 2025 course instances with their details such as code, name, HP, period, students
SELECT 
  ci."Course_Code"           AS "Course Code",
  ci."Instance_ID"           AS "Course Instance ID",
  c."Credits"                AS "HP",
  ci."Period"                AS "Period",
  ci."Num_Students"          AS "# Students",

	-- summing up the hours for each activity or 0 if that activity doesn't exist
	COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%lecture%' THEN wa."Hours" * wa."Factor" END), 0) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%tutorial%' THEN wa."Hours" * wa."Factor" END), 0) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%lab%' THEN wa."Hours" * wa."Factor" END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%seminar%' THEN wa."Hours" * wa."Factor" END), 0) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%overhead%' THEN wa."Hours" * wa."Factor" END), 0) AS "Other Overhead Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%admin%' THEN wa."Hours" * wa."Factor" END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%exam%' THEN wa."Hours" * wa."Factor" END), 0) AS "Exam",

  	
	-- Total, the sum of all activities
	COALESCE(SUM(wa."Hours" * wa."Factor"), 0) AS "Total Hours"

FROM "Course_Instance" ci --this view has all course instance details
JOIN "Course" c ON ci."Course_Code" = c."Course_Code" --join to get hours per activity
LEFT JOIN "Work_Allocation" wa ON wa."Instance_ID" = ci."Instance_ID"

WHERE ci."Year" = CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INT)

--group by instance
GROUP BY ci."Course_Code", ci."Instance_ID", c."Credits", ci."Period", ci."Num_Students"
--sort by course code and period
ORDER BY ci."Course_Code", ci."Period";


-- Query 2
--for a specific course, show each teacher and their allocated hours by activity
--Picking one course instance
SELECT
  ci."Course_Code"            AS "Course Code",
  ci."Instance_ID"            AS "Course Instance ID",
  c."Credits"                 AS "HP",
  (t."Name")                  AS "Teacher's Name", 
  t."Designation"             AS "Designation",

    --hours by activity
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%lecture%' THEN wa."Hours" * wa."Factor" END), 0) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%tutorial%' THEN wa."Hours" * wa."Factor" END), 0) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%lab%' THEN wa."Hours" * wa."Factor" END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%seminar%' THEN wa."Hours" * wa."Factor" END), 0) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%overhead%' THEN wa."Hours" * wa."Factor" END), 0) AS "Other Overhead Hours",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%admin%' THEN wa."Hours" * wa."Factor" END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN LOWER(wa."Activity") LIKE '%exam%' THEN wa."Hours" * wa."Factor" END), 0) AS "Exam",

    --Total hours for the teacher in this course
    COALESCE(SUM(wa."Hours" * wa."Factor"), 0) AS "Total"

FROM "Work_Allocation" wa
JOIN "Course_Instance" ci ON ci."Instance_ID" = wa."Instance_ID" --getting course info
JOIN "Course" c ON c."Course_Code" = ci."Course_Code" --more course details
JOIN "Teacher" t ON t."Employee_ID" = wa."Employee_ID" --employee info
WHERE ci."Instance_ID" = '2025-50273'
GROUP BY ci."Course_Code", ci."Instance_ID", c."Credits", t."Name", t."Designation"
ORDER BY t."Name";


-- query 3
-- "Calculate the total allocated hours (with multiplication factors) 
--for a teacher, only for the current years' course instance"
SELECT
	C."Course_Code" AS "Course Code",
	CI."Instance_ID" AS "Course Instance ID",
	C."Credits" AS "HP",
	CI."Period",
	T."Name" AS "Teacher's Name",


	-- hours by activity type (hours * factor)
	COALESCE(SUM(CASE WHEN WA."Activity" = 'Lecture' THEN WA."Hours" * WA."Factor" END), 0 ) AS "Lecture Hours",
	COALESCE(SUM(CASE WHEN WA."Activity" = 'Tutorial' THEN WA."Hours" * WA."Factor" END), 0 ) AS "Tutorial Hours",
	COALESCE(SUM(CASE WHEN WA."Activity" = 'Lab' THEN WA."Hours" * WA."Factor" END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN WA."Activity" = 'Seminar' THEN WA."Hours" * WA."Factor" END), 0) AS "Seminar Hours",
    COALESCE(SUM(CASE WHEN WA."Activity" = 'Other Overhead' THEN WA."Hours" * WA."Factor" END), 0) AS "Other Overhead Hours",
    COALESCE(SUM(CASE WHEN WA."Activity" = 'Admin' THEN WA."Hours" * WA."Factor" END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN WA."Activity" = 'Exam' THEN WA."Hours" * WA."Factor" END), 0) AS "Exam",
   
	SUM(WA."Hours" * WA."Factor") AS "Total" -- total of all activites for this teacher in htis course

FROM "Teacher" T 
JOIN "Work_Allocation" WA ON T."Employee_ID" = WA."Employee_ID"

JOIN "Course_Instance" CI ON WA."Instance_ID" = CI."Instance_ID"

--get course details
JOIN "Course" C ON CI."Course_Code" = C."Course_Code"

WHERE 
	CI."Year" = 2025
	AND T."Name" = 'Niharika Gauraha'

--group by course isntance
GROUP BY C."Course_Code", CI."Instance_ID", C."Credits", CI."Period", T."Name"
--order by period to see chronological workload 
ORDER BY CI."Period", C."Course_Code";


--query 4:
--"List employee ids and names of all teachers who are allocated in more than a 
--specific number of course instances during the current period"

SELECT 
	T."Employee_ID" AS "Employment ID",
	T."Name" AS "Teacher's Name",
	CI."Period",
	COUNT(DISTINCT CI."Instance_ID") AS "No of courses"

FROM "Teacher" T
JOIN  "Work_Allocation" WA ON T."Employee_ID" = WA."Employee_ID"
JOIN "Course_Instance" CI ON WA."Instance_ID" = CI."Instance_ID"

WHERE 
	CI."Period" = 2

-- group by teacher and period
GROUP BY T."Employee_ID", T."Name", CI."Period"

--filter to show teachers with only more than X courses
-- X = 1
HAVING COUNT(DISTINCT CI."Instance_ID") > 1
ORDER BY CI."Period", COUNT(DISTINCT CI."Instance_ID") DESC;

