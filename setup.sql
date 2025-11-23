/* ==============================================================
   IV1351 PROJECT TASK 2 - SETUP SCRIPT (FIXED)
   Description: Creates Schema and Inserts Mock Data for OLAP Analysis
   ============================================================== */

-- 1. Clean up old tables if they exist
DROP TABLE IF EXISTS "Work_Allocation" CASCADE;
DROP TABLE IF EXISTS "Course_Instance" CASCADE;
DROP TABLE IF EXISTS "Course" CASCADE;
DROP TABLE IF EXISTS "Teacher" CASCADE;

-- 2. Create Tables
CREATE TABLE "Teacher" (
    "Employee_ID" INT PRIMARY KEY,
    "Name" VARCHAR(100),
    "Designation" VARCHAR(50) -- e.g., Professor, Lecturer, TA
);

CREATE TABLE "Course" (
    "Course_Code" VARCHAR(10) PRIMARY KEY,
    "Name" VARCHAR(100),
    "Credits" DECIMAL(3,1) -- e.g., 7.5
);

CREATE TABLE "Course_Instance" (
    "Instance_ID" VARCHAR(20) PRIMARY KEY, -- e.g., 2025-50273
    "Course_Code" VARCHAR(10) REFERENCES "Course"("Course_Code"),
    "Period" INT, -- 1, 2, 3, 4
    "Year" INT,
    "Num_Students" INT
);

CREATE TABLE "Work_Allocation" (
    "Allocation_ID" SERIAL PRIMARY KEY,
    "Instance_ID" VARCHAR(20) REFERENCES "Course_Instance"("Instance_ID"),
    "Employee_ID" INT REFERENCES "Teacher"("Employee_ID"),
    "Activity" VARCHAR(50), -- Lecture, Lab, Admin, etc.
    "Hours" INT, -- Base hours
    "Factor" DECIMAL(3,2) DEFAULT 1.0 -- Multiplication factor (e.g. 4.0 for lectures)
);

-- 3. Insert Mock Data
-- Teachers
INSERT INTO "Teacher" VALUES 
(500001, 'Paris Carbone', 'Ass. Professor'),
(500004, 'Leif Lindbäck', 'Lecturer'),
(500009, 'Niharika Gauraha', 'Lecturer'),
(500020, 'Adam', 'TA'),
(500021, 'Brian', 'PhD Student');

-- Courses
INSERT INTO "Course" VALUES 
('IV1351', 'Data Storage Paradigms', 7.5),
('IX1500', 'Discrete Math', 7.5),
('ID2214', 'Artificial Intelligence', 7.5),
('IV1350', 'Object Oriented Prog', 7.5);

-- Instances (Current Year 2025)
INSERT INTO "Course_Instance" VALUES 
('2025-50273', 'IV1351', 2, 2025, 200),
('2025-50413', 'IX1500', 1, 2025, 150),
('2025-50341', 'ID2214', 2, 2025, 100),
('2025-60104', 'IV1350', 3, 2025, 180);

-- Work Allocations
-- IV1351 Allocations
INSERT INTO "Work_Allocation" ("Instance_ID", "Employee_ID", "Activity", "Hours", "Factor") VALUES
('2025-50273', 500001, 'Lecture', 18, 4.0), -- 18*4 = 72 allocated
('2025-50273', 500001, 'Other Overhead', 100, 1.0),
('2025-50273', 500001, 'Admin', 43, 1.0),
('2025-50273', 500001, 'Exam', 61, 1.0),
('2025-50273', 500009, 'Seminar', 64, 1.0),
('2025-50273', 500009, 'Other Overhead', 100, 1.0),
('2025-50273', 500020, 'Lab', 50, 1.0),
('2025-50273', 500020, 'Seminar', 50, 1.0);

-- IX1500 Allocations
INSERT INTO "Work_Allocation" ("Instance_ID", "Employee_ID", "Activity", "Hours", "Factor") VALUES
('2025-50413', 500009, 'Lecture', 40, 4.0), -- 160 allocated
('2025-50413', 500009, 'Admin', 141, 1.0),
('2025-50413', 500009, 'Exam', 73, 1.0);

-- ID2214 Allocations
INSERT INTO "Work_Allocation" ("Instance_ID", "Employee_ID", "Activity", "Hours", "Factor") VALUES
('2025-50341', 500009, 'Lecture', 11, 4.0), 
('2025-50341', 500009, 'Tutorial', 36, 1.0);

-- Confirmation Message
SELECT 'Database Setup Complete' AS status;