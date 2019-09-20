--coalesce
--returns first non-NULL value
--useful for selecting default or back up values when default value is NULL
--checks in order, returning first non-NULL value

-- Use coalesce
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       -- Don't forget to count!
       count(*)
  FROM fortune500
-- Group by what? (What are you counting by?)
 GROUP BY industry2
-- Order results to see most common first
 ORDER BY count(*) desc
-- Limit results to get just the one value you want
 LIMIT 1;

 --another coalesce example with a self join
 SELECT company_original.name, title, rank
  -- Start with original company information
  FROM company AS company_original
       -- Join to another copy of company with parent
       -- company information
	   LEFT JOIN company AS company_parent
       ON company_original.parent_id = company_parent.id
       -- Join to fortune500, only keep rows that match
       INNER JOIN fortune500
       -- Use parent ticker if there is one,
       -- otherwise original ticker
       ON coalesce(company_parent.ticker,
                   company_original.ticker) =
             fortune500.ticker
 -- For clarity, order by rank
 ORDER BY rank;

--truncation
-- Truncate employees to 10k use -4
--if wanted to truncate to 2 decimal places use 2
SELECT trunc(employees, -4) AS employee_bin,
       -- Count number of companies with each truncated value
       count(*)
  FROM fortune500
 -- Limit to which companies?
 WHERE employees < 100000
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;

--generate series
-- Create lower and upper bounds of bins
generate_series(from, to, step)
SELECT generate_series(2200, 3050, 50) AS lower,
       generate_series(2250, 3100, 50) AS upper;

--usage example
--the below summarise distribuion of number of questions with tag dropbox
--per day by binning the data
-- Bins created in Step 2
WITH bins AS (
      SELECT generate_series(2200, 3050, 50) AS lower,
             generate_series(2250, 3100, 50) AS upper),
     -- Subset stackoverflow to just tag dropbox (Step 1)
     dropbox AS (
      SELECT question_count
        FROM stackoverflow
       WHERE tag='dropbox')
-- Select columns for result
-- What column are you counting to summarize?
SELECT lower, upper, count(question_count)
  FROM bins  -- Created above
       -- Join to dropbox (created above),
       -- keeping all rows from the bins table in the join
       LEFT JOIN dropbox
       -- Compare question_count to lower and upper
         ON question_count >= lower
        AND question_count < upper
 -- Group by lower and upper to count values in each bin
 GROUP BY lower, upper
 -- Order by lower to put bins in order
 ORDER BY lower;

 --calculating correlation using corr()
 -- Correlation between revenues and profit
SELECT corr(revenues, profits) AS rev_profits,
	   -- Correlation between revenues and assets
       corr(revenues, assets) AS rev_assets,
       -- Correlation between revenues and equity
       corr(revenues, equity) AS rev_equity
  FROM fortune500;

  --looking at median using percentile
  --percentile_disc(0.5) WITHIN GROUP (ORDER BY column_name) AS median
  -- What groups are you computing statistics by?
SELECT sector,
       -- Select the mean of assets with the avg function
       avg(assets) AS mean,
       -- Select the median
       percentile_disc(0.5) WITHIN GROUP (ORDER BY assets) AS median
  FROM fortune500
 -- Computing statistics for each what?
 GROUP BY sector
 -- Order results by a value of interest
 ORDER BY mean;

--temp table example with percntile
--NOTE TERADATA HAS VOLATILE TABLE AS TEMP TABLE
-- Code from previous step
DROP TABLE IF EXISTS profit80;

CREATE TEMP TABLE profit80 AS
  SELECT sector,
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    FROM fortune500
   GROUP BY sector;

-- Select columns, aliasing as needed
SELECT title, fortune500.sector,
       profits, profits/pct80 AS ratio
-- What tables do you need to join?
  FROM fortune500
       LEFT JOIN profit80
-- How are the tables joined?
       ON fortune500.sector=profit80.sector
-- What rows do you want to select?
 WHERE profits > pct80;

 --concatenate and trim trailing spaces
 -- Concatenate house_num, a space, and street
-- and trim spaces from the start of the result
SELECT trim(concat(house_num, ' ', street)) AS address
  FROM evanston311;

--split string by delimiter
--in this case delimiter is the space
-- Select the first word of the street value
--split_part(string text, delimiter, field int)
SELECT split_part(street,' ', 1) AS street_name,
       count(*)
  FROM evanston311
 GROUP BY street_name
 ORDER BY count DESC
 LIMIT 20;

 --triming a strig when great than a certain length
 -- Select the first 50 chars when length is greater than 50
SELECT CASE WHEN length(description) > 50
            THEN left(description, 50) || '...'
       -- otherwise just select description
       ELSE description
       END
  FROM evanston311
 -- limit to descriptions that start with the word I
 WHERE description like 'I %'
 ORDER BY description;

--group and recode values
--step 1
-- Fill in the command below with the name of the temp table
DROP TABLE IF EXISTS ___;

-- Create and name the temporary table
CREATE TEMP table recode AS
-- Write the select query to generate the table
-- with distinct values of category and standardized values
  SELECT DISTINCT category,
         rtrim(split_part(category, '-', 1)) AS standardized
    -- What table are you selecting the above values from?
    FROM evanston311;

-- Look at a few values before the next step
SELECT DISTINCT standardized
  FROM recode
 WHERE standardized LIKE 'Trash%Cart'
    OR standardized LIKE 'Snow%Removal%';

--step 2
-- Code from previous step
DROP TABLE IF EXISTS recode;

CREATE TEMP TABLE recode AS
  SELECT DISTINCT category,
         rtrim(split_part(category, '-', 1)) AS standardized
    FROM evanston311;

-- Update to group trash cart values
UPDATE recode
   SET standardized='Trash Cart'
 WHERE standardized like '%Trash%Cart';

-- Update to group snow removal values
UPDATE recode
   SET standardized='Snow Removal'
 WHERE standardized like 'Snow%';

-- Examine effect of updates
SELECT DISTINCT standardized
  FROM recode
 WHERE standardized LIKE 'Trash%Cart'
    OR standardized LIKE 'Snow%Removal%';

--step 3
-- Code from previous step
DROP TABLE IF EXISTS recode;

CREATE TEMP TABLE recode AS
  SELECT DISTINCT category,
         rtrim(split_part(category, '-', 1)) AS standardized
    FROM evanston311;

UPDATE recode SET standardized='Trash Cart'
 WHERE standardized LIKE 'Trash%Cart';

UPDATE recode SET standardized='Snow Removal'
 WHERE standardized LIKE 'Snow%Removal%';


-- Update to group unused/inactive values
UPDATE recode
   SET standardized='UNUSED'
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart',
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash',
               'NO LONGER IN USE');

-- Examine effect of updates
SELECT DISTINCT standardized
  FROM recode
 ORDER BY standardized;

--step 4
-- Code from previous step
DROP TABLE IF EXISTS recode;
CREATE TEMP TABLE recode AS
  SELECT DISTINCT category,
         rtrim(split_part(category, '-', 1)) AS standardized
  FROM evanston311;
UPDATE recode SET standardized='Trash Cart'
 WHERE standardized LIKE 'Trash%Cart';
UPDATE recode SET standardized='Snow Removal'
 WHERE standardized LIKE 'Snow%Removal%';
UPDATE recode SET standardized='UNUSED'
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart',
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash', 'NO LONGER IN USE');

-- Select the recoded categories and the count of each
SELECT standardized, count(*)
-- From the original table and table with recoded values
  FROM evanston311
       LEFT JOIN recode
       -- What column do they have in common?
       ON evanston311.category = recode.category
 -- What do you need to group by to count?
 GROUP BY standardized
 -- Display the most common val values first
 ORDER BY count(*) desc;

--creating an table with indicator variables
--step 1
-- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the indicators temp table
CREATE TEMP TABLE indicators AS
  -- Select id
  SELECT id,
         -- Create the email indicator (find @)
         CAST (description LIKE '%@%' AS integer) AS email,
         -- Create the phone indicator
         CAST (description like '%___-___-____%' AS integer) AS phone
    -- What table contains the data?
    FROM evanston311;

-- Inspect the contents of the new temp table
SELECT *
  FROM indicators;

--step 2
-- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the temp table
CREATE TEMP TABLE indicators AS
  SELECT id,
         CAST (description LIKE '%@%' AS integer) AS email,
         CAST (description LIKE '%___-___-____%' AS integer) AS phone
    FROM evanston311;

-- Select the column you'll group by
SELECT priority,
       -- Compute the proportion of rows with each indicator
       SUM(email)/count(*)::numeric AS email_prop,
       sum(phone)/count(*)::numeric AS phone_prop
  -- Tables to select from
  FROM evanston311
       left JOIN indicators
       -- Joining condition
       ON evanston311.id=indicators.id
 -- What are you grouping by?
 GROUP BY priority;
