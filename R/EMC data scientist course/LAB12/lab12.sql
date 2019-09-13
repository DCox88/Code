----Step 1
Select * from daily_data;

----Step 2
select yr,season,sum(cnt) as seasonal_count from daily_data group by yr,season order by 1,2;
select yr,mnth,sum(cnt) as monthly_count from daily_data group by yr,mnth order by 1,2;

select yr,weathersit,sum(cnt) as weather_count, avg(temp) as avg_temp, avg(hum) as avg_humidity, avg(windspeed) as avg_windspeed from daily_data group by yr,weathersit order by 1,2;

-- Daily Arithmetic means by month
select mnth,avg(cnt) as avg_count from daily_data group by mnth order by 1;
-- Daily Avg difference by month and year
select yr,mnth,avg(cnt) as avg_count from daily_data group by yr,mnth order by 1,2;

----Step 3
-- Comparing mean and median
-- Compute Mean
select yr,mnth,avg(cnt) as avg_count, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cnt) AS Median_Count from daily_data group by yr,mnth order by 1,2;
-- Compute Median 
SELECT C.yr,C.mnth, AVG(R.cnt) AS median
FROM (SELECT yr,mnth, COUNT(*) AS cnt
FROM daily_data
GROUP BY yr,mnth 
order by yr) C INNER JOIN (select l.yr,l.mnth, l.cnt, count(*) as n 
from daily_data as l
left join daily_data as r
    on l.yr = r.yr 
    AND l.mnth = r.mnth
    and l.cnt >= r.cnt
group by l.yr,l.mnth, l.cnt) AS R
on C.yr = R.yr and C.mnth = R.mnth
WHERE n IN ( ( C.cnt + 1 ) / 2, ( C.cnt + 2 ) / 2 )
GROUP BY C.yr,C.mnth order by 1,2;

----Step 4
--PART 1
CREATE OR REPLACE FUNCTION ewma_calc(numeric, numeric, numeric) RETURNS numeric as
/* $1 = prior value of EWMA         */
/* $2 = current value of series     */
/* $3 = alpha, the smoothing factor */
'SELECT CASE
    WHEN $3 IS NULL                       /* bad alpha */
    OR $3 < 0
    OR $3 > 1 THEN NULL
    WHEN $1 IS NULL THEN $2               /* t = 1        */
    WHEN $2 IS NULL THEN $1               /* y is unknown */
    ELSE ($3 * $2) + (1-$3) *$1           /* t >= 2       */
    END'
LANGUAGE SQL
IMMUTABLE;

--PART 2
CREATE OR REPLACE FUNCTION dummy_function(numeric,numeric) RETURNS numeric as
'SELECT -4000.00'
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;

--PART 3
DROP AGGREGATE IF EXISTS ewma(numeric, numeric)
CREATE AGGREGATE ewma(numeric, numeric)
    (SFUNC = ewma_calc,
    STYPE = numeric,
    PREFUNC = dummy_function);

--PART 4
create table ewma_cnt_1 (dteday date, cnt numeric(10,2), ewma numeric(10,2));

Insert into EWMA_CNT_1  
SELECT 
    dteday,
    cnt,
    ewma(cnt, .1)  
    OVER (
        ORDER BY  dteday)
    FROM   daily_data
ORDER  BY 
    dteday;
    
create table ewma_cnt_2 (dteday date, cnt numeric(10,2), ewma numeric(10,2));

Insert into EWMA_CNT_2  
SELECT 
    dteday,
    cnt,
    ewma(cnt, .2)  
    OVER (
        ORDER BY  dteday)
    FROM   daily_data
ORDER  BY 
    dteday;

--PART 5
create table ewma_cnt_final as select a.*,b.ewma as ewma_2 from ewma_cnt_1 a inner join ewma_cnt_2 b on a.dteday = b.dteday;

--PART 6
GRANT ALL PRIVILEGES ON TABLE ewma_cnt_final to training;
	
----Step 5
--Part 1
/* Generate Single Regression for all data */
DROP TABLE IF EXISTS daily_data_linreg, daily_data_linreg_summary;
SELECT madlib.linregr_train( 'daily_data',
                             'daily_data_linreg',
                             'cnt',
                             'ARRAY[1, season,weekday,atemp,hum,casual,registered]'
                           );

						   
--PART 2
/* Two output models one for each value of holiday */
DROP TABLE IF EXISTS daily_data_linreg_hday, daily_data_linreg_hday_summary;
SELECT madlib.linregr_train( 'daily_data',
                             'daily_data_linreg_hday',
                             'cnt',
                             'ARRAY[1, season,weekday,atemp,hum,casual,registered]',
                             'holiday'
                           );

						   
--PART 3
\x ON
SELECT * FROM daily_data_linreg;

--PART 4
\x OFF
SELECT unnest(ARRAY['intercept','season','yr','month','weekday','atemp','hum','casual','registered']) as attribute,
       unnest(coef) as coefficient,
       unnest(std_err) as standard_error,
       unnest(t_stats) as t_stat,
       unnest(p_values) as pvalue
FROM daily_data_linreg;

\x ON
SELECT * FROM daily_data_linreg_hday ORDER BY holiday;

						   
						   
