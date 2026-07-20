
-- Return the complete student roster from the students table.
SELECT * FROM students;

-- Return students who are majoring in Computer Science.
SELECT first_name, last_name, graduation_year
FROM students
WHERE major ='Computer Science';

-- Return all courses ordered by credit hours from highest to lowest.
SELECT course_name, credits
FROM courses
ORDER BY credits DESC;

-- Return students who are expected to graduate in 2026.
SELECT first_name, last_name, major
FROM students
WHERE graduation_year = 2026;

-- Count the total number of courses available.
SELECT COUNT(course_id) AS total_courses
FROM courses
;
-- Calculate the average number of credits per course.
SELECT AVG(credits) AS average_credits
FROM courses;

-- Return students who enrolled after December 31, 2022.
SELECT first_name, last_name, enrollment_date
FROM students
WHERE enrollment_date > '2022-12-31';

-- Return professors who work in the Computer Science department.
SELECT first_name, last_name, hire_date
FROM professors
WHERE department = 'Computer Science';

-- Return students whose email addresses contain the university.edu domain.
SELECT first_name, last_name, email, major
FROM students
WHERE email LIKE('%university.edu%')
ORDER BY last_name;

-- A  department administrator wants to see which professors are teaching which courses. Show each professor's name, department, and the courses they are responsible for. Order by professor last name, then course name.
SELECT p.first_name, p.last_name, p.department, c.course_name, c.credits
FROM professors p
JOIN courses c
ON p.professor_id = c.professor_id
ORDER BY p.last_name, c.course_name;

-- The curriculum office wants to know how many different academic majors are represented in the student body. Write a query that lists each unique major offered — no duplicates. Exclude students who have not yet declared a major. Order alphabetically.
SELECT distinct major
FROM students
WHERE major IS NOT NULL
ORDER BY major ASC;

-- The admissions department needs to identify students who enrolled during the 2022–2023 academic period for a program evaluation. Find all students whose enrollment_date falls within that range (inclusive). Show first name, last name, enrollment_date, and major. Order by enrollment_date, then last name.
SELECT first_name, last_name, enrollment_date, major
FROM students
WHERE enrollment_date <= '2023-12-31' AND enrollment_date >= '2022-01-01'
ORDER BY enrollment_date, last_name;

-- Academic advisors need to contact students who have not yet chosen a major so they can schedule advising sessions. Find all students whose major has not been declared (stored as NULL). Show first name, last name, and email.
SELECT first_name, last_name, email
FROM students
WHERE major IS NULL;

-- Return student names together with their enrolled courses and grades.
SELECT  s.first_name
      , s.last_name
      , c.course_name
      , e.grade
FROM students s
  JOIN enrollments e
    ON s.student_id = e.student_id
 JOIN courses c
   ON c.course_id = e.course_id
ORDER BY s.student_id, e.enrollment_id;

-- Count the number of students enrolled in each course.
SELECT course_name, COUNT(student_id) AS enrollment_count
FROM  enrollments e
LEFT JOIN  courses c
ON c.course_id = e.course_id
GROUP BY Course_name
ORDER BY c.course_name;

-- Return courses with more than one student enrolled.
SELECT course_name, COUNT(student_id) AS enrollment_count
FROM enrollments e
LEFT JOIN courses c
ON e.course_id = c.course_id
GROUP BY c.Course_name
HAVING enrollment_count > 1
ORDER BY c.course_name;

-- Return pairs of students who share the same graduation year.
SELECT  s.first_name AS student1_first
      , s.last_name AS student1_last
      , s2.first_name AS student2_first
      , s2.last_name AS student2_last
      , s.graduation_year
      , s.major AS major1
      , s2.major AS major2
FROM students s
JOIN students s2
ON s.student_id < s2.student_id
WHERE s.graduation_year = s2.graduation_year
ORDER BY s.graduation_year, s.student_id;

-- Return course count, total credits, and average credits per department.
SELECT  department
      , COUNT(course_id) AS course_count
      , SUM(credits) AS total_credits
      , AVG(credits) AS AVG_credits
FROM courses
GROUP BY department
ORDER BY course_count DESC, department;

-- The student services team needs to identify students who have not yet registered for any courses — they may need outreach or academic advising. Find these students and show their first name, last name, and major.
SELECT first_name, last_name, major
FROM students
WHERE student_id NOT IN (SELECT student_ID FROM enrollments);


-- The admissions office wants to track enrollment trends over the years. Count how many students enrolled each year, extracted from their enrollment_date. Show enrollment_year and student_count ordered by year.
SELECT strftime('%Y', enrollment_date) AS enrollment_year, COUNT(student_id) AS student_count
FROM students
GROUP BY enrollment_year;

-- The honors committee wants to highlight each student's best academic achievement. For each student who has at least one enrollment, show their name, best grade letter, and the corresponding grade points. Order by grade points descending, then last name. Grade scale: A=4.0, A-=3.7, B+=3.3, B=3.0.

WITH honors
AS(
SELECT  s.first_name
      , s.last_name
      , ROW_NUMBER() OVER (PARTITION BY s.student_id ORDER BY 
                            CASE  WHEN e.grade = 'A' THEN '4.0'
                                  WHEN e.grade = 'A-' THEN '3.7'
                                  WHEN e.grade = 'B+' THEN '3.3'
                                  WHEN e.grade = 'B' THEN '3.0'
                            END DESC) rn
      , e.grade as best_grade
      , CASE  WHEN e.grade = 'A' THEN '4.0'
              WHEN e.grade = 'A-' THEN '3.7'
              WHEN e.grade = 'B+' THEN '3.3'
              WHEN e.grade = 'B' THEN '3.0'
        END as best_grade_points
      , s.student_id
FROM students s
    JOIN enrollments e
      ON s.student_id = e.student_id
)
SELECT  first_name
      , last_name
      , best_grade
      , best_grade_points
FROM honors
WHERE rn = 1
--GROUP BY student_ID
ORDER BY best_grade_points DESC;

-- Academic advisors want to see which students are carrying the heaviest course loads. Show each student's total enrolled credits along with their name and major. Order by total credits from highest to lowest.
SELECT  s.first_name
      , s.last_name
      , s.major
      , SUM(c.credits) total_credits
FROM courses c
    JOIN enrollments e
      ON c.course_id = e.course_id
    JOIN students s
      ON s.student_id = e.student_id
GROUP BY s.student_id
ORDER BY total_credits DESC;

-- The academic records office needs a combined enrollment list covering the 2022 and 2023 academic years for a period review report. Show student first name, last name, course name, and year for all enrollments in year 2022 and year 2023 combined. Order by year, then last name.
SELECT
    s.first_name,
    s.last_name,
    c.course_name,
    e.year AS year
FROM students s
JOIN enrollments e
    ON s.student_id = e.student_id
JOIN courses c
    ON c.course_id = e.course_id
WHERE e.year IN (2022, 2023)
ORDER BY
    year ASC,
    s.last_name ASC;

-- Student services needs a complete enrollment status report for all students. For every student in the system, show their name and whether they are 'Enrolled' (has at least one course) or 'Not Enrolled' (no courses registered yet). Order by last name.
SELECT  s.first_name
      , s.last_name
      , CASE  WHEN E.student_id IS NOT NULL THEN 'Enrolled'
              ELSE 'NOT Enrolled'
        END AS Status
FROM students s
  LEFT JOIN enrollments e
    ON s.student_id = e.student_id
GROUP BY  s.first_name
        , s.last_name
        , CASE  WHEN E.student_id IS NOT NULL THEN 'Enrolled'
              ELSE 'NOT Enrolled'
        END
ORDER BY s.last_name 

-- UI INSISTED THIS IS THE CORRECT QUERY:
SELECT
    s.first_name,
    s.last_name,
    CASE
        WHEN COUNT(e.enrollment_id) > 0 THEN 'Enrolled'
        ELSE 'Not Enrolled'
    END AS status
FROM students s
LEFT JOIN enrollments e
    ON s.student_id = e.student_id
GROUP BY
    s.first_name,
    s.last_name
ORDER BY
    s.last_name;

-- Calculate each student's GPA by converting letter grades to numeric points and averaging them, along with the number of courses taken.
SELECT  s.first_name
      , s.last_name
      , s.major
      , AVG(
            CASE 
              WHEN e.grade = 'A' THEN 4.0
              WHEN e.grade = 'A-' THEN 3.7
              WHEN e.grade = 'B+' THEN 3.3
              WHEN e.grade = 'B' THEN 3.0
              ELSE 0.0
            END
                    ) AS gpa
      , COUNT(e.enrollment_id) AS courses_taken
FROM students s
  LEFT JOIN enrollments e
    ON s.student_id = e.student_id
GROUP BY
        s.student_id
      , s.first_name
      , s.last_name
      , s.major
ORDER BY
  gpa DESC

-- The honors office wants to rank all students by their GPA to identify top performers. Calculate each student's GPA and rank them from highest to lowest. Show first name, last name, rounded GPA (2 decimals), and their rank. Grade scale: A=4.0, A-=3.7, B+=3.3, B=3.0.

WITH gpa_per AS
(
SELECT  s.first_name
      , s.last_name
      , AVG ( CASE
                  WHEN e.grade = 'A' THEN 4.0
                  WHEN e.grade = 'A-' THEN 3.7
                  WHEN e.grade = 'B+' THEN 3.3
                  WHEN e.grade = 'B' THEN 3.0
                  ELSE 0.0
              END
             ) AS gpa
FROM students s
 LEFT JOIN enrollments e
    ON s.student_id = e.student_id
GROUP BY 
  s.student_id
  , s.first_name
  , s.last_name
)
SELECT  first_name
      , last_name
      , ROUND(gpa, 2) AS gpa
      , RANK() OVER (ORDER BY gpa DESC) gpa_rank
FROM gpa_per
WHERE gpa > 0
ORDER BY
  gpa DESC,
  last_name;

-- The academic support team wants to identify students who are underperforming relative to their classmates in the same course. Find all enrollments where the student's grade points are strictly below the average grade points for that course. Show student name, course name, and grade.
SELECT
    s.first_name,
    s.last_name,
    c.course_name,
    e.grade
FROM students s
JOIN enrollments e
    ON s.student_id = e.student_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE
    CASE
        WHEN e.grade = 'A'  THEN 4.0
        WHEN e.grade = 'A-' THEN 3.7
        WHEN e.grade = 'B+' THEN 3.3
        WHEN e.grade = 'B'  THEN 3.0
        ELSE 0.0
    END < (
        SELECT AVG(
            CASE
                WHEN e2.grade = 'A'  THEN 4.0
                WHEN e2.grade = 'A-' THEN 3.7
                WHEN e2.grade = 'B+' THEN 3.3
                WHEN e2.grade = 'B'  THEN 3.0
                ELSE 0.0
            END
        )
        FROM enrollments e2
        WHERE e2.course_id = e.course_id
    )
ORDER BY
    s.last_name,
    c.course_name;

-- The university wants to recognize the professor with the broadest student reach. Find the professor who has taught the most distinct students across all their courses. Show first name, last name, department, and student_count.
SELECT TOP 1
    p.first_name,
    p.last_name,
    p.department,
    COUNT(DISTINCT e.student_id) AS student_count
FROM professors p
JOIN courses c
    ON p.professor_id = c.professor_id
JOIN enrollments e
    ON c.course_id = e.course_id
GROUP BY
    p.first_name,
    p.last_name,
    p.department
ORDER BY
    student_count DESC;

--The academic board needs a high-level summary of student performance across the cohort. Classify each enrolled student's GPA into bands — Distinction (GPA ≥ 3.7), Merit (GPA ≥ 3.0), Pass (below 3.0) — then show how many students are in each band and their average GPA. Grade scale: A=4.0, A-=3.7, B+=3.3, B=3.0.
WITH gpa_per_student AS (
    SELECT
        s.student_id,
        AVG(
            CASE
                WHEN e.grade = 'A'  THEN 4.0
                WHEN e.grade = 'A-' THEN 3.7
                WHEN e.grade = 'B+' THEN 3.3
                WHEN e.grade = 'B'  THEN 3.0
                ELSE 0.0
            END
        ) AS gpa
    FROM students s
    JOIN enrollments e
        ON s.student_id = e.student_id
    GROUP BY
        s.student_id
),
banded AS (
    SELECT
        student_id,
        gpa,
        CASE
            WHEN gpa >= 3.7 THEN 'Distinction'
            WHEN gpa >= 3.0 THEN 'Merit'
            ELSE 'Pass'
        END AS grade_band
    FROM gpa_per_student
)
SELECT
    grade_band,
    COUNT(*) AS student_count,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM banded
GROUP BY grade_band
ORDER BY grade_band;

--The academic support team wants to identify students carrying above-average credit loads who may need extra support. Find all enrolled students whose total credits exceed the average total credits among all enrolled students. Show first name, last name, major, and total_credits. Order by total_credits descending.

WITH credits_per_student AS (
    SELECT
        s.student_id,
        s.first_name,
        s.last_name,
        s.major,
        SUM(c.credits) AS total_credits
    FROM students s
    JOIN enrollments e
        ON s.student_id = e.student_id
    JOIN courses c
        ON e.course_id = c.course_id
    GROUP BY
        s.student_id,
        s.first_name,
        s.last_name,
        s.major
)
SELECT
    first_name,
    last_name,
    major,
    total_credits
FROM credits_per_student
WHERE total_credits >
    (SELECT AVG(total_credits) FROM credits_per_student)
ORDER BY total_credits DESC;
