SELECT 
    C."Course_Code",
    CI."Instance_ID",
    C."Credits" AS HP,
    CI."Period",
    CI."Num_Students" AS "# Students",
    -- Pivot Logic: Sum hours where activity matches, multiply by factor
    SUM(CASE WHEN WA."Activity" = 'Lecture' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Lecture Hours",
    SUM(CASE WHEN WA."Activity" = 'Tutorial' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Tutorial Hours",
    SUM(CASE WHEN WA."Activity" = 'Lab' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Lab Hours",
    SUM(CASE WHEN WA."Activity" = 'Seminar' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Seminar Hours",
    SUM(CASE WHEN WA."Activity" = 'Other Overhead' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Overhead Hours",
    SUM(CASE WHEN WA."Activity" = 'Admin' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Admin",
    SUM(CASE WHEN WA."Activity" = 'Exam' THEN WA."Hours" * WA."Factor" ELSE 0 END) AS "Exam",
    SUM(WA."Hours" * WA."Factor") AS "Total Hours"
FROM "Course_Instance" CI
JOIN "Course" C ON CI."Course_Code" = C."Course_Code"
JOIN "Work_Allocation" WA ON CI."Instance_ID" = WA."Instance_ID"
WHERE CI."Year" = 2025
GROUP BY C."Course_Code", CI."Instance_ID", C."Credits", CI."Period", CI."Num_Students"
ORDER BY CI."Period", C."Course_Code";

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