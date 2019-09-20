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

 
