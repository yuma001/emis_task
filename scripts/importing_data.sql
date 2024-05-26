/*
Connected Visual Studio to GitHub and Microsoft SQL SERVER.
Importing all csv data into the database.
*/

-- Patient table
DROP TABLE IF EXISTS patient;
CREATE TABLE patient (
	  age int
	, postcode varchar(10)
	, patient_surname varchar(50)
	, patient_givenname varchar(50)
	, date_of_birth datetime
	, date_of_death datetime
	, registration_guid varchar(200)
	, patient_id int
	, gender varchar(20)
	, PRIMARY KEY (patient_id)
	);

BULK INSERT patient 
FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\patient.csv'
WITH (
      FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, ROWTERMINATOR = '0x0a'
	, KEEPNULLS
	, FORMAT = 'csv'
	);

-- SELECT COUNT(*), COUNT(patient_id) FROM patient	-- Checking count of rows and whether it matches primary key
-- SELECT TOP 10 * FROM patient     -- Checking data

-- Clinical codes table
DROP TABLE IF EXISTS clinical_codes;
CREATE TABLE clinical_codes (
	  refset_simple_id bigint
	, parent_code_id bigint
	, code_id bigint
	, snomed_concept_id bigint
	, emis_term nvarchar(200)
	);

BULK INSERT clinical_codes 
FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\clinical_codes.csv'
WITH (
      FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, ROWTERMINATOR = '0x0a'
	, KEEPNULLS
	, FORMAT = 'csv'
	);

-- SELECT count(*) FROM clinical_codes
-- SELECT TOP 10 * FROM clinical_codes


-- Observation table
DROP TABLE IF EXISTS observation;
CREATE TABLE observation (
	  abnormal varchar(50)
	, emis_code_id bigint
	, comparator varchar(50)
	, confidential_flag varchar(5)  -- Datatype bit was not working, therefore, used varcahar instead for flags
	, confidential_patient_flag varchar(5)
	, consultation_source_emis_code_id bigint
	, consultation_source_emis_original_term nvarchar(MAX)
	, document_guid nvarchar(MAX)
	, dummy_patient_flag varchar(5)
	, effective_date datetime
	, effective_date_precision varchar(50)
	, emis_enteredby_userinrole_guid nvarchar(MAX)
	, emis_episodicity smallint
	, end_date datetime
	, fhir_episodicity varchar(50)
	, emis_observation_guid nvarchar(MAX)
	, exa_observation_guid nvarchar(MAX)
	, fhir_interpretation_code varchar(50)
	, is_parent_flag varchar(5)
	, non_regular_and_current_active_flag varchar(5)
	, emis_observation_id int
	, observation_type varchar(50)
	, emis_observationtypeid smallint
	, opt_out_93c1_flag varchar(5)
	, opt_out_9nd19nu09nu4_flag varchar(5)
	, opt_out_9nd19nu0_flag varchar(5)
	, opt_out_9nu0_flag varchar(5)
	, other_code varchar(50)
	, other_code_system nvarchar(MAX)
	, other_display nvarchar(MAX)
	, range_lower numeric
	, range_upper numeric
	, readv2_code varchar(50)
	, recorded_date datetime
	, registration_guid nvarchar(MAX)
	, regular_and_current_active_flag varchar(5)
	, regular_current_active_and_inactive_flag varchar(5)
	, regular_patient_flag varchar(5)
	, emis_original_term nvarchar(MAX)
	, sensitive_flag varchar(5)
	, sensitive_patient_flag varchar(5)
	, snomed_concept_id bigint
	, snomed_description_id bigint
	, emis_parent_observation_guid nvarchar(MAX)
	, exa_parent_observation_guid nvarchar(MAX)
	, uom nvarchar(50)
	, uom_ucum nvarchar(50)
	, user_selected varchar(50)
	, numericvalue numeric
	, value_pq_2 varchar(50)
	);

BULK INSERT observation
FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation.csv'  -- Adding all files from observation folder
WITH (
      FIRSTROW = 2 
	, FIELDTERMINATOR = ','
	, ROWTERMINATOR = '0x0a'
	, KEEPNULLS
	, FORMAT = 'csv'
	);

-- SELECT count(*) FROM observation --23186, 23073, 23073, 23043, 23151, 23167, 23152, 22990, 22965, 22978, 22918, 22076 - TOTAL 275772
--  SELECT TOP 10 * FROM observation

-- Adding the rest of the observation files
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_2.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_2.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_4.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_5.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_6.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_7.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_8.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_9.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_10.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_11.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT observation FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\observation\observation_12.csv' WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');


-- Medication table
DROP TABLE IF EXISTS medication;
CREATE TABLE medication (
      nhs_prescribing_agency nvarchar(50)
    , emis_drug_guid nvarchar(50)
    , authorisedissues_authorised_date datetime
    , authorisedissues_first_issue_date datetime
    , cancellation_reason nvarchar(50)
    , emis_code_id bigint
    , confidential_flag varchar(5)
    , consultation_source_emis_code_id bigint
    , consultation_source_emis_original_term nvarchar(50)
    , dose nvarchar(MAX)
    , emis_medication_status int
    , dummy_patient_flag varchar(5)
    , duration_in_days int
    , duration_uom varchar(5)
    , effective_date datetime
    , effective_date_precision varchar(5)
    , emis_issue_method nvarchar(MAX)
    , emis_mostrecent_issue_date datetime
    , emis_prescription_type varchar(50)
    , emis_registration_organisation_guid nvarchar(MAX)
    , emis_encounter_guid nvarchar(MAX)
    , exa_encounter_guid nvarchar(MAX)
    , end_date datetime
    , emis_enteredby_userinrole_guid nvarchar(MAX)
    , exa_prescription_guid nvarchar(MAX)
    , estimated_nhs_cost numeric
    , exa_drug_guid nvarchar(MAX)
    , medication_guid nvarchar(MAX)
    , exa_medication_guid nvarchar(MAX)
    , fhir_medication_intent varchar(50)
    , exa_mostrecent_issue_date datetime
    , max_nextissue_days int
    , min_nextissue_days int
    , non_regular_and_current_active_flag varchar(5)
    , number_authorised int
    , number_of_issues int
    , opt_out_93c1_flag varchar(5)
    , opt_out_9nd19nu09nu4_flag varchar(5)
    , opt_out_9nd19nu0_flag varchar(5)
    , opt_out_9nu0_flag varchar(5)
    , emis_medication_organisation_guid nvarchar(MAX)
    , other_code nvarchar(MAX)
    , other_code_system nvarchar(MAX)
    , prescribed_as_contraceptive_flag varchar(5)
    , privately_prescribed_flag varchar(5)
    , quantity numeric
    , recorded_date datetime
    , registration_guid nvarchar(MAX)
    , regular_and_current_active_flag varchar(5)
    , regular_current_active_and_inactive_flag varchar(5)
    , regular_patient_flag varchar(5)
    , reimburse_type bigint
    , review_date datetime
    , emis_original_term nvarchar(MAX)
    , sensitive_flag varchar(5)
    , sensitive_patient_flag varchar(5)
    , snomed_concept_id bigint
    , snomed_description_id bigint
    , fhir_medication_status varchar(50)
    , cancellation_date datetime
    , nhs_prescription_type varchar(50)
    , uom nvarchar(50)
    , uom_dmd nvarchar(50)
	);

BULK INSERT medication
FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication.csv'  
WITH (
      FIRSTROW = 2 
	, FIELDTERMINATOR = ','
	, ROWTERMINATOR = '0x0a'
	, KEEPNULLS
	, FORMAT = 'csv'
	);

-- SELECT count(*) FROM medication --15096 - TOTAL 275772
--  SELECT TOP 10 * FROM medication

-- Adding the rest of the medication files
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_2.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_3.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_4.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_5.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_6.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_7.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_8.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_9.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_10.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_11.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_12.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_13.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_14.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
BULK INSERT medication FROM 'C:\Users\yumar\Desktop\Projects\20240524_sql_emis\data\medication\medication_15.csv'  WITH (FIRSTROW = 1, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS, FORMAT = 'csv');
