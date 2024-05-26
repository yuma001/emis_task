/* 
Part 1: Patient count for each genders per postcode area
Postcode area is
*/

-- Double checking duplicates
SELECT patient_id, COUNT(*)
FROM patient
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- Checking gender categories
SELECT DISTINCT(gender) FROM patient;  -- Indeterminate, Unknown, Male, Female



-- Calculate number of patients that are alive by gender in each postcode area

-- First clean patient table by filtering to alive patients, calculate age, merging patient name
DROP TABLE IF EXISTS #patient_temp;  -- Temporary table to use for the rest of the task.
SELECT 
	  CONCAT(patient_givenname, ' ', patient_surname) AS patient_name
	, patient_id
	, registration_guid
	, gender
	, CONVERT(date, date_of_birth, 103) AS date_of_birth
	, (DATEDIFF(MONTH, date_of_birth, GETDATE())) / 12 AS age
	, postcode
    , LEFT(postcode, PATINDEX('%[0-9]%', postcode)-1) AS postcode_area
INTO #patient_temp
FROM patient
WHERE date_of_death IS NULL ;

--	AND postcode in ('B1 2DD', 'HX7 4NH')  -- To check postcode area is calculated properly
-- SELECT TOP 10 * FROM #patient_temp  -- Double checking data


-- Caculating distribution of genders in each postcode area and finding the postcode areas with largest patient count 
WITH gender_segmented AS (
SELECT patient_id
	, postcode_area
	, CASE WHEN gender = 'Indeterminate' THEN 1 END AS indeterminate_gender
	, CASE WHEN gender = 'Unknown' THEN 1 END AS unknown_gender
	, CASE WHEN gender = 'Male' THEN 1 END AS male_gender
	, CASE WHEN gender = 'Female' THEN 1 END AS female_gender
FROM #patient_temp
)
SELECT TOP 2
	  postcode_area
	, COUNT(*) AS total_population
	, COUNT(indeterminate_gender) AS indeterminate_gender_count
	, COUNT(unknown_gender) AS unknown_gender_count
	, COUNT(male_gender) AS male_gender_count
	, COUNT(female_gender) AS female_gender_count
FROM gender_segmented
GROUP BY postcode_area
ORDER BY COUNT(*) DESC;


/*
Task 2: For the postcode areas LS and WF (with largest patient population),
		filter patients that fit the criteria defined.
*/

SELECT TOP 2 * FROM #patient_temp;
SELECT TOP 2 * FROM observation;
SELECT TOP 2 * FROM clinical_codes;
SELECT TOP 2 * FROM medication;

SELECT * 
FROM medication med
	INNER JOIN #patient_temp pat ON med.registration_guid = pat.registration_guid
WHERE pat.registration_guid = '887D961F-88A9-4E19-900F-AF120A3EAE91'