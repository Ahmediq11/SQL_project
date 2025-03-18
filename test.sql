-- CREATE TABLE job_applyed(
--   job_id INT,
--   application_sent_date DATE,
--   custom_resume BOOLEAN,
--   resume_file_name VARCHAR(255),
--   cover_letter_sert BOOLEAN,
--   cover_letter_file_name VARCHAR(255),
--   status VARCHAR(50)
-- );



-- INSERT into job_applyed(
--   job_id,
--   application_sent_date,
--   custom_resume,
--   resume_file_name,
--   cover_letter_sert,
--   cover_letter_file_name,
--   status
-- )
-- values (
--   1,
--   '2025-1-1',
--   true,
--   'resume.pdf',
--   true,
--   'core.pdf',
--   'sbmited'
-- ), 
-- (
--   1,
--   '2024-12-11',
--   true,
--   'resume32.pdf',
--   true,
--   'core_latter.pdf',
--   'sbmited'
-- ) ;



ALTER TABLE job_applyed
add contact VARCHAR(50);



UPDATE job_applyed
SET contact = 'ahmed'
where job_id = 1;

UPDATE job_applyed
SET contact = 'ali'
where job_id = 2;



ALTER TABLE job_applyed
RENAME COLUMN contact to contact_name;



ALTER TABLE job_applyed
ALTER COLUMN contact_name TYPE TEXT;




ALTER TABLE table_name
DROP COLUMN column_name;



DROP TABLE job_applyed1;

SELECT *
FROM
  job_postings_fact
  LIMIT 100;



SELECT
job_title_short AS title,
job_location AS location,
job_posted_date:: DATE AS dat
FROM
job_postings_fact;



SELECT
job_title_short AS title,
job_location AS location,
job_posted_date:: DATE AS dat,
EXTRACT (day FROM job_posted_date) AS column_month
FROM
job_postings_fact
LIMIT 5;



SELECT
count(job_id),
EXTRACT(MONTH FROM job_posted_date) AS month
from job_postings_fact
GROUP BY month;



CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;


select *
FROM january_jobs;



SELECT
job_title_short,
job_location,
CASE
 WHEN job_location ='Anywhere' THEN 'Remote'
 WHEN job_location ='New York, NY' THEN 'Local'
 ELSE 'Onsite'
END AS location_category
FROM job_postings_fact;






SELECT
COUNT (job_id) AS number_of_jobs,
CASE
WHEN job_location = 'Anywhere' THEN 'Remote'
WHEN job_location = 'New York, NY' THEN 'Local'
ELSE 'Onsite'
END AS location_category
FROM job_postings_fact
GROUP BY
location_category;





SELECT
COUNT (job_id) AS number_of_jobs,
CASE
WHEN job_location = 'Anywhere' THEN 'Remote'
WHEN job_location = 'New York, NY' THEN 'Local'
ELSE 'Onsite'
END AS location_category
FROM job_postings_fact
where job_title_short = 'Data Analyst'
GROUP BY
location_category;



SELECT job_location , job_posted_date
FROM ( 
SELECT *
FROM job_postings_fact
WHERE EXTRACT (MONTH FROM job_posted_date) = 1
) AS january_jobs;




SELECT *
FROM ( SubQuery starts here
SELECT *
FROM job_postings_fact
WHERE EXTRACT (MONTH FROM job_posted_date) = 1
) AS january_jobs;






SELECT
company_id,
name AS company_name
FROM
company_dim
WHERE company_id IN (
SELECT
company_id
FROM
job_postings_fact
WHERE
job_no_degree_mention = true
ORDER BY
company_id
)





WITH company_job_count AS (
SELECT
company_id,
COUNT(*) AS total_jobs
FROM
job_postings_fact
GROUP BY
company_id)
SELECT
company_dim.name AS company_name,
company_job_count.total_jobs
FROM
company_dim
LEFT JOIN company_job_count
ON company_job_count.company_id = company_dim.company_id
ORDER BY
total_jobs DESC


WITH remote_jobs AS (
    -- Filter remote jobs
    SELECT job_id
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
),
skill_counts AS (
    -- Count occurrences of each skill in remote jobs
    SELECT sj.skill_id, COUNT(sj.job_id) AS count
    FROM skills_job_dim sj
    JOIN remote_jobs rj ON sj.job_id = rj.job_id
    GROUP BY sj.skill_id
),
top_skills AS (
    -- Get skill names and sort by demand
    SELECT sc.skill_id, sd.skills, sc.count, sd.type
    FROM skill_counts sc
    JOIN skills_dim sd ON sc.skill_id = sd.skill_id
    ORDER BY sc.count DESC
    LIMIT 5
)
-- Final selection
SELECT * FROM top_skills;





WITH remote_jobs AS (
    SELECT job_id 
    FROM job_postings_fact
    WHERE job_work_from_home = 'True'
)

SELECT 
    s.skill_id,
    s.skills AS skill_name,
    COUNT(*) AS remote_job_count
FROM skills_dim s
JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
JOIN remote_jobs rj ON sj.job_id = rj.job_id
GROUP BY s.skill_id, s.skills
ORDER BY remote_job_count DESC
LIMIT 5;
