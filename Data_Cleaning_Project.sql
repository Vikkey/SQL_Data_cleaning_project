SELECT Funding_Stage ,UPPER(Funding_Stage) FROM layoff_raw_data;

UPDATE layoff_raw_data
SET Funding_Stage = UPPER(TRIM(Funding_Stage));

With duplicate_date AS
(
SELECT *, row_number() over(partition by Company, layoff_date, Employees_Laid_Off, Percentage_Laid_Off, department, location, stage, reason, company_size, funding_stage) AS row_num FROM layoff_raw_data
)

SELECT Department FROM duplicate_date
where row_num > 1;


SELECT  distinct stage,
CASE 
	When stage like '%DONE%' Then 'Done'
    When stage like '%Pending%' Then 'Pending'
    When stage like '%Ongoing%' Then 'Ongoing'
    When stage like '%Announced%' Then 'Announced'
    When stage like '%TBD%' Then 'TBD'
    When stage like '%Inprocess%' Then 'Inprocess'
    When stage like '%Completed%' Then 'Done'
    else NULL 
END AS Stage_cleaned
FROM layoff_raw_data 
;

Update layoff_raw_data
SET stage = CASE 
	When stage like '%DONE%' Then 'Done'
    When stage like '%Pending%' Then 'Pending'
    When stage like '%Ongoing%' Then 'Ongoing'
    When stage like '%Announced%' Then 'Announced'
    When stage like '%TBD%' Then 'TBD'
    When stage like '%Inprocess%' Then 'Inprocess'
    When stage like '%Completed%' Then 'Done'
    else NULL 
END;

UPDATE layoff_raw_data
SET Company_size = 'Unknown'
where Company_size like '%+' 
OR
Company_size like '-%'
OR
Company_size like '%Small'
OR
Company_size like '%Large'
;

UPDATE layoff_raw_data
SET company = 'Amazon'
where company like '%amazon.com';

UPDATE layoff_raw_data
SET company = 'Better'
where company like '%Better.com';

UPDATE layoff_raw_data
SET company = 'Google'
where company like '%google inc';

UPDATE layoff_raw_data
SET company = 'We Work'
where company like '%we work';

UPDATE layoff_raw_data
SET Funding_stage = 'SEED'
where Funding_stage like '%SEED STAGE%';

UPDATE layoff_raw_data
SET 
Funding_stage = 'Unknown',
Reason = 'Unknown',
Department = 'Unknown',
Percentage_laid_off = 'Unknown',
Employees_Laid_off = 'Unknown',
layoff_date = 'Unknown',
stage = 'Unknown',
Company_size = 'Unknown'
where
Funding_stage is null or Funding_stage = ''
OR Reason is null or  Reason = ''
OR Department is null or  Department = ''
OR Percentage_laid_off is null or  Percentage_laid_off = ''
OR Employees_Laid_off is null or  Employees_Laid_off = ''
OR Layoff_date is null or  Layoff_date = ''
OR stage is null or  stage = ''
OR Company_size is null or  Company_size = '';

UPDATE layoff_raw_data
SET Funding_stage = ''
where Funding_stage = '';

DELETE FROM layoff_raw_data
where Layoff_Date = 'Unknown' AND Percentage_Laid_Off = 'Unknown' AND Department = 'Unknown';

Alter table layoff_raw_data
Drop Column Source_URL;

select * 
from
( 
SELECT *, count(*) over(partition by company, department, employees_laid_off, location) AS Duplicate_count
FROM layoff_raw_data
) temp_name
where Duplicate_count > 1;


ALTER TABLE layoff_raw_data
ADD column duplicate_id int AUTO_INCREMENT UNIQUE;


With duplicate as (
SELECT *, row_number() over(partition by company, department, employees_laid_off, location order by duplicate_id) as dupli_cate 
FROM layoff_raw_data
)
DELETE from layoff_raw_data
where duplicate_id in (select duplicate_id from duplicate where dupli_cate > 1);

ALTER TABLE layoff_raw_data
DROP column duplicate_id;

UPDATE layoff_raw_data
SET employees_laid_off = 'Unknown' 
where employees_laid_off like '%-%' OR employees_laid_off like '%+%' OR employees_laid_off like '%~%';

DELETE FROM layoff_raw_data
where Layoff_Date like '2020%' OR Layoff_Date like '2022%' OR Layoff_Date like '2023%' OR Layoff_Date like '2021';

Update layoff_raw_data
Set Layoff_Date = STR_TO_DATE(Layoff_Date, '%M %d, %Y')
where Layoff_Date like '%,%';

Update layoff_raw_data
Set Layoff_Date = STR_TO_DATE(Layoff_Date, '%m/%d/%Y')
where Layoff_Date like '%/%';

Update layoff_raw_data
Set Layoff_Date = STR_TO_DATE(Layoff_Date, '%d-%m-%Y')
where Layoff_Date like '%-%';

SELECT distinct Department, 
CASE 
	when department like 'Ux%' then 'Ui/Ux'
    when department like '%Data Analytics%' then 'Data Analystics'
    when department like '%Customer service' OR department like '%Cs' then 'Customer Service'
    when department like 'support%'  OR department like '%support%' then 'Customer Support'
    when department like 'hr%' then 'Human Resource'
	when department like 'Research & development%' then 'R&D'
    when department like 'Pm%' OR department like 'Productmanagement%' then 'Project Management'
    when department like 'Operations%' then 'Business Operations'
    Else NULL
END AS Cleaned_Department
FROM layoff_raw_data;

UPDATE layoff_raw_data
SET Department = 
CASE 
	when department like 'Ux%' then 'Ui/Ux'
    when department like '%Data Analytics%' then 'Data Analystics'
    when department like '%Customer service' OR department like '%Cs' then 'Customer Service'
    when department like 'support%'  OR department like '%support%' then 'Customer Support'
    when department like 'hr%' then 'Human Resource'
	when department like 'Research & development%' then 'R&D'
    when department like 'Pm%' OR department like 'Productmanagement%' then 'Project Management'
    when department like 'Operations%' then 'Business Operations'
    Else NULL
END;

SELECT Department, CONCAT(UPPER(LEFT(Department, 1)), LOWER(SUBSTRING(Department, 2))) As Clean_department FROM layoff_raw_data;

Update layoff_raw_data
Set Department = CONCAT(UPPER(LEFT(Department, 1)), LOWER(SUBSTRING(Department, 2)));

SELECT Percentage_Laid_Off, replace( replace( replace( Percentage_Laid_Off, '%', ''), '-',''), '~', '') AS cleaned_Percent_layoff FROM layoff_raw_data;

Update layoff_raw_data
Set Percentage_Laid_Off = replace( replace( replace( Percentage_Laid_Off, '%', ''), '-',''), '~', '');

SELECT distinct reason,TRIM(Concat(upper(left(reason,1)), lower(substring(reason,2)))) FROM layoff_raw_data; 

Update layoff_raw_data
Set reason = TRIM(Concat(upper(left(reason,1)), lower(substring(reason,2))));

SELECT distinct reason, replace(replace(reason,'Cost reduction', 'Cost cut'),'Cost cutting','Cost cut') FROM layoff_raw_data; 

Update layoff_raw_data
Set reason = replace(replace(reason,'Cost reduction', 'Cost cut'),'Cost cutting','Cost cut');

SELECT distinct location, replace( replace ( replace( location, 'REMOTE', 'WFH'), 'NYC', 'New York'),'NYC', 'New York') FROM layoff_raw_data;

SELECT location, substring_index(location, ',',1) location  FROM layoff_raw_data;

Update layoff_raw_data
Set location = substring_index(location, ',',1);

Update layoff_raw_data
Set location = replace( replace ( replace( location, 'REMOTE', 'WFH'), 'NYC', 'New York'),'NYC', 'New York');

SELECT * FROM layoff_raw_data;