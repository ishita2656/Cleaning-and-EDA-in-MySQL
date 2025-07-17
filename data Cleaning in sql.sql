-- Data Cleaning 

select * from layoffs;

-- 1. remove duplicates ,
-- 2.standardize the data,
-- 3.null values or blank values,
-- 4.remove any columns


-- 1.Removing duplicates

create table layoffs_staging
like layoffs;

select * from layoffs_staging; -- Its a COPY of actual raw data layoffs we will make all the changes here its looks proffesional in workspace!!!

insert layoffs_staging
select * 
from layoffs;

select *, 
Row_number() over(
partition by company,location,industry,total_laid_off,'date')
from layoffs_staging;

with duplicates_cte as 
(
select *, 
Row_number() over(
partition by company,location,industry,total_laid_off,'date',stage,
country,funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicates_cte
where row_num > 1;

select * from layoffs_staging
where company = 'Casper';

-- deleting those with row_num is 2

with duplicates_cte as 
(
select *, 
Row_number() over(
partition by company,location,industry,total_laid_off,'date',stage,
country,funds_raised_millions) as row_num
from layoffs_staging
)
delete from duplicates_cte
where row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



select * from layoffs_staging2;


insert into layoffs_staging2
select *, 
Row_number() over(
partition by company,location,industry,total_laid_off,'date',stage,
country,funds_raised_millions) as row_num
from layoffs_staging;

set SQL_SAFE_UPDATES = 0;

delete from layoffs_staging2
where row_num>1 ;

select * from layoffs_staging2;

-- 2. Standardizing data
 
 -- trim just wipes off the white space 
 
select distinct company,trim(company)  
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry from layoffs_staging2;

select * from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Cryto%';

select * from layoffs_staging2
where industry = 'Crypto';

select  distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select * from layoffs_staging2;

select `date`,
str_to_date (`date`,'%m/%d/%Y') 
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` DATE;

-- 3. solving null and blanks
-- checking

select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoffs_staging2
where industry is null
or industry = '';

select * from layoffs_staging2 
where company = 'Bally';

   
select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where t1.industry is null 
and t2.industry is not null;


update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 
set industry = null
where industry = '';

select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;




