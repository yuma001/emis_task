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
DROP TABLE IF EXISTS #patient_postcode; 
SELECT 
	  CONCAT(patient_givenname, ' ', patient_surname) AS patient_name   -- These columns are calculated here but will be used in the final patient table
	, patient_id
	, registration_guid
	, gender
	, CONVERT(date, date_of_birth, 103) AS date_of_birth
	, (DATEDIFF(MONTH, date_of_birth, GETDATE())) / 12 AS age
	, postcode
    , LEFT(postcode, PATINDEX('%[0-9]%', postcode)-1) AS postcode_area
INTO #patient_postcode
FROM patient
WHERE date_of_death IS NULL ;
--	AND postcode in ('B1 2DD', 'HX7 4NH')  -- To check postcode area is calculated properly



-- Caculating distribution of genders in each postcode area and finding the postcode areas with largest patient count 
DROP TABLE IF EXISTS #top_two_postcode_areas;
WITH gender_segmented AS (
SELECT patient_id
	, postcode_area
	, CASE WHEN gender = 'Indeterminate' THEN 1 END AS indeterminate_gender
	, CASE WHEN gender = 'Unknown' THEN 1 END AS unknown_gender
	, CASE WHEN gender = 'Male' THEN 1 END AS male_gender
	, CASE WHEN gender = 'Female' THEN 1 END AS female_gender
FROM #patient_postcode
)
SELECT TOP 2
	  postcode_area
	, COUNT(*) AS total_population
	, COUNT(indeterminate_gender) AS indeterminate_gender_count
	, COUNT(unknown_gender) AS unknown_gender_count
	, COUNT(male_gender) AS male_gender_count
	, COUNT(female_gender) AS female_gender_count
INTO #top_two_postcode_areas
FROM gender_segmented
GROUP BY postcode_area
ORDER BY COUNT(*) DESC;

SELECT * FROM #top_two_postcode_areas;  -- LS and WF were found to be top two postcode areas



/*
Task 2: For the postcode areas LS and WF (with largest patient population),
		filter patients that fit the criteria defined.
*/

-- Patients in LS and WF areas with asthma
DROP TABLE IF EXISTS #patients_asthma;
WITH asthma AS (
SELECT pat.registration_guid
	, o.end_date
	, ROW_NUMBER() OVER (PARTITION BY pat.registration_guid ORDER BY o.recorded_date DESC) AS rn
FROM observation o
INNER JOIN clinical_codes cc ON o.snomed_concept_id = cc.snomed_concept_id
INNER JOIN #patient_postcode pat ON o.registration_guid = pat.registration_guid
WHERE pat.postcode_area in (
							SELECT postcode_area FROM #top_two_postcode_areas  -- Use top two postcode areas found previously
							)
	AND cc.refset_simple_id = '999012891000230104'  -- Asthma
	AND dummy_patient_flag = 'false'  -- Flag to ensure real patient
)
-- Patients with current asthma
SELECT registration_guid
INTO  #patients_asthma
FROM asthma 
WHERE rn = 1  -- Most recent observation record with asthma diagnosis
	AND end_date IS NULL ; -- Asthma not resolved




-- Find patients with medical conditions to exclude: current smoker, weight < 40 kg and COPD not resolved

-- Exlude smokers
DROP TABLE IF EXISTS #exclude_smokers;
WITH smokers AS (
SELECT pat.registration_guid
	, end_date
	, ROW_NUMBER() OVER (PARTITION BY pat.registration_guid ORDER BY o.recorded_date DESC) AS rn
FROM #patients_asthma pat 
LEFT JOIN observation o ON o.registration_guid = pat.registration_guid
INNER JOIN clinical_codes cc ON o.snomed_concept_id = cc.snomed_concept_id
WHERE cc.refset_simple_id = '999004211000230104'  -- Smokers
)
SELECT registration_guid
INTO #exclude_smokers
FROM smokers
WHERE rn = 1  -- Most recent observation record for smoking
	AND end_date IS NULL ; -- Current smokers 


-- Exlude current COPD patients
DROP TABLE IF EXISTS #exclude_copd;
WITH copd AS (
SELECT pat.registration_guid
	, end_date
	, ROW_NUMBER() OVER (PARTITION BY pat.registration_guid ORDER BY o.recorded_date DESC) AS rn
FROM #patients_asthma pat 
LEFT JOIN observation o ON o.registration_guid = pat.registration_guid
INNER JOIN clinical_codes cc ON o.snomed_concept_id = cc.snomed_concept_id
WHERE cc.refset_simple_id = '999011571000230107'  -- COPD
)
SELECT registration_guid
INTO #exclude_copd
FROM copd
WHERE rn = 1  -- Most recent observation record for COPD
	AND end_date IS NULL ; -- COPD not resolved


-- Exlude current weight < 40kg
DROP TABLE IF EXISTS #exclude_weight;
WITH weights AS (
SELECT pat.registration_guid
	, o.recorded_date
	, o.numericvalue
	, ROW_NUMBER() OVER (PARTITION BY pat.registration_guid ORDER BY o.recorded_date DESC) AS rn
FROM #patients_asthma pat 
LEFT JOIN observation o ON o.registration_guid = pat.registration_guid
WHERE o.snomed_concept_id = '27113001'  -- Weight
)
SELECT registration_guid
INTO #exclude_weight
FROM weights
WHERE rn = 1  -- Most recent observation record for patient weight
	AND numericvalue < 40 ; -- Weight < 40kg


-- Now use the "exclude" temp tables to exclude appropriate patients from the target patient population
DROP TABLE IF EXISTS #patients_asthma_excluding_other_illness;
SELECT registration_guid
INTO #patients_asthma_excluding_other_illness
FROM #patients_asthma pat
WHERE registration_guid NOT IN (SELECT registration_guid FROM #exclude_smokers) 
	AND registration_guid NOT IN (SELECT registration_guid FROM #exclude_copd)
	AND registration_guid NOT IN (SELECT registration_guid FROM #exclude_weight);

-- SELECT COUNT(*) FROM #patients_asthma_excluding_other_illness  -- 119 patients



-- Patients with defined medications in the last 30 years for target patients

		-- -- Double checking the relationship between registration_guid and emis_registration_organisation_guid 
		--select registration_guid, COUNT(DISTINCT(emis_registration_organisation_guid))
		--from medication
		--GROUP BY registration_guid 
		--HAVING COUNT(DISTINCT(emis_registration_organisation_guid)) > 1;  -- Found to be one to one relationship
		-- -- However, there seems to be only one organisation_guid in the entire dataset, for both emis_registration_organisation_guid and emis_medication_organisation_guid


DROP TABLE IF EXISTS #all_patients_with_meds;
SELECT DISTINCT(pat.registration_guid)
	 , emis_registration_organisation_guid  -- Since registration_guid has one to one relationship with emis_registration_organisation_guid
INTO #all_patients_with_meds
FROM medication med 
INNER JOIN #patients_asthma_excluding_other_illness pat on med.registration_guid = pat.registration_guid
WHERE (med.snomed_concept_id in ('129490002'  -- Formoterol Fumarate		
						   	   , '108606009'  -- Salmeterol Xinafoate
							   , '702408004'  -- Vilanterol 
							   , '702801003'  -- Indacaterol 
							   , '704459002'  -- Olodaterol 
							    ) -- List of medication codes 
		OR med.emis_original_term LIKE '%Formoterol Fumarate%'  -- Medications with these ingredients 
		OR med.emis_original_term LIKE '%Salmeterol Xinafoate%'
		OR med.emis_original_term LIKE '%Vilanterol%'
		OR med.emis_original_term LIKE '%Indacaterol%'
		OR med.emis_original_term LIKE '%Olodaterol%'
		)
		AND recorded_date >= (DATEADD(year, -30, GETDATE())) ;

-- SELECT * FROM #all_patients_with_meds;  -- 6 patients

		


-- To exclude patients not opted out
-- Check patient's latest observations to check if they have opted out from taking part in research or sharing their medical record
DROP TABLE IF EXISTS #opt_out_observation;
WITH observation_flag AS (
SELECT pat.registration_guid
	 , o.confidential_flag
	 , o.confidential_patient_flag 
	 , o.opt_out_93c1_flag
	 , o.opt_out_9nd19nu0_flag 
	 , o.opt_out_9nd19nu09nu4_flag
	 , o.opt_out_9nu0_flag 
	 , o.sensitive_flag
	 , o.sensitive_patient_flag
	, ROW_NUMBER() OVER (PARTITION BY pat.registration_guid ORDER BY o.recorded_date DESC) AS rn
FROM #all_patients_with_meds pat 
INNER JOIN observation o ON o.registration_guid = pat.registration_guid
)
SELECT registration_guid
INTO #opt_out_observation
FROM observation_flag
WHERE rn = 1  -- Most recent observation record for patient
	AND (confidential_flag = 'true'
	  OR confidential_patient_flag = 'true' 
	  OR opt_out_93c1_flag = 'true'
	  OR opt_out_9nd19nu0_flag = 'true' 
	  OR opt_out_9nd19nu09nu4_flag = 'true'
	  OR opt_out_9nu0_flag = 'true' 
	  OR sensitive_flag = 'true'
	  OR sensitive_patient_flag = 'true');  -- If flags are true then should not be contacted


-- Check patient's latest medication to check if they have opted out from taking part in research or sharing their medical record
DROP TABLE IF EXISTS #opt_out_medication;
WITH medication_flag AS (
SELECT pat.registration_guid
	 , med.confidential_flag
	 , med.opt_out_93c1_flag
	 , med.opt_out_9nd19nu0_flag 
	 , med.opt_out_9nd19nu09nu4_flag
	 , med.opt_out_9nu0_flag 
	 , med.sensitive_flag
	 , med.sensitive_patient_flag
	, ROW_NUMBER() OVER (PARTITION BY pat.registration_guid ORDER BY med.recorded_date DESC) AS rn
FROM #all_patients_with_meds pat 
INNER JOIN medication med ON med.registration_guid = pat.registration_guid
)
SELECT registration_guid
INTO #opt_out_medication
FROM medication_flag
WHERE rn = 1  -- Most recent medication record for patient
	AND (confidential_flag = 'true'
	  OR opt_out_93c1_flag = 'true'
	  OR opt_out_9nd19nu0_flag = 'true' 
	  OR opt_out_9nd19nu09nu4_flag = 'true'
	  OR opt_out_9nu0_flag = 'true' 
	  OR sensitive_flag = 'true'
	  OR sensitive_patient_flag = 'true');  -- If flags are true then should not be contacted




-- Now use the "exclude" opt out temp tables to exclude appropriate patients from the target patient population
DROP TABLE IF EXISTS #research_patients;
SELECT registration_guid
	, emis_registration_organisation_guid
INTO #research_patients
FROM #all_patients_with_meds pat
WHERE registration_guid NOT IN (SELECT registration_guid FROM #opt_out_observation) 
	AND registration_guid NOT IN (SELECT registration_guid FROM #opt_out_medication);

-- SELECT * FROM #research_patients;  -- 6 patients



-- Creating the final research patient table
SELECT 
	  pat.emis_registration_organisation_guid AS 'organisation'
	, pp.registration_guid AS 'registration_id'
	, pp.patient_id 
	, pp.patient_name AS 'patient_fullname'
	, pp.postcode 
	, pp.age
	, pp.gender
FROM #research_patients pat
INNER JOIN #patient_postcode pp ON pat.registration_guid = pp.registration_guid
ORDER BY pat.emis_registration_organisation_guid, pp.patient_id  
