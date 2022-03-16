1.	Write a query that finds the top 3 users with most active (frequency) on buying for each group 17-22 and 23-30  
```sql
WITH BASE1 AS (
SELECT A.*,
       A.Saham_invested_amount+A.Campuran_invested_amount+A.Pasar_Uang_invested_amount+A.Pendapatan_Tetap_invested_amount AS Total_Investment
from transaction A) -- Select transaction table with users' total investment

,BASE2 AS (
SELECT B.*,
       coalesce(LAG(B.TOTAL_INVESTMENT) OVER(PARTITION BY USER_ID ORDER BY B.DATE ASC),B.TOTAL_INVESTMENT) AS PREVIOUS_DAY_INVESTMENT,
       TOTAL_INVESTMENT - coalesce(LAG(B.TOTAL_INVESTMENT) OVER(PARTITION BY USER_ID ORDER BY B.DATE ASC),B.TOTAL_INVESTMENT) AS BUY_SELL
FROM BASE1 B) -- Select transaction table with users' previous investment and users' buy/sell amount columns

,BUY_SELL_ACTIVITY AS (
SELECT C.*,
       CASE WHEN BUY_SELL > 0 THEN 1 ELSE 0 END AS FLAG_BUY,
       CASE WHEN BUY_SELL < 0 THEN 1 ELSE 0 END AS FLAG_SELL
FROM BASE2 C) -- Select transaction table with flag buy and sell

,DEMOGRAPHY_AGE_17_30 AS (
SELECT T.*,
	   CASE WHEN T.user_age >=17 AND T.user_age <= 22 THEN '17-22'
               WHEN T.user_age >=23 AND T.user_age <= 30 THEN '23-30'
	   ELSE NULL
       END AS USER_AGE_DISTRIBUTION
FROM demography T
WHERE CASE WHEN T.user_age >=17 AND T.user_age <= 22 THEN '17-22'
	    WHEN T.user_age >=23 AND T.user_age <= 30 THEN '23-30'
	    ELSE NULL END IS NOT NULL ) --  Select demography table filtered by age group 17-22 and 23-30
       
, FINAL_DATA AS (
SELECT T.*,
	ROW_NUMBER()OVER(PARTITION BY USER_AGE_DISTRIBUTION ORDER BY COUNT_BUY DESC) AS RN
FROM (
SELECT DMG.USER_ID,
       DMG.USER_AGE_DISTRIBUTION,
       SUM(FLAG_BUY) AS COUNT_BUY 
FROM BUY_SELL_ACTIVITY BSA
JOIN DEMOGRAPHY_AGE_17_30 DMG ON BSA.USER_ID = DMG.USER_ID
GROUP BY USER_AGE_DISTRIBUTION,USER_ID ) T
) -- Select table with user_id, user age distribution, total count of user buy activity, and row number groupped by age 17-22 and 23-30 and ordered by the total user buy activity descending

SELECT * FROM FINAL_DATA 
where rn <= 3
order by USER_AGE_DISTRIBUTION asc -- Select top 3 users with most buying for each group 17-22 and 23-30 
 ```
2.	Write a query that finds the top 3 users with most active (frequency) on selling (Reksadana Saham Portfolio Only) who are female and income source not from "Keuntungan Bisnis" 
 ```sql
WITH BASE1 AS (
SELECT A.*,
       coalesce(LAG(A.Saham_invested_amount) OVER(PARTITION BY USER_ID ORDER BY A.DATE ASC),A.Saham_invested_amount) AS PREVIOUS_DAY_SAHAM_INVESTMENT,
       Saham_invested_amount - coalesce(LAG(A.Saham_invested_amount) OVER(PARTITION BY USER_ID ORDER BY A.DATE ASC),A.Saham_invested_amount) AS BUY_SELL
FROM TRANSACTION A) -- Select transaction table with users' total saham investment and users buy/sell amount

,BUY_SELL_SAHAM_ACTIVITY AS (
SELECT B.*,
       CASE WHEN BUY_SELL > 0 THEN 1 ELSE 0 END AS FLAG_BUY,
       CASE WHEN BUY_SELL < 0 THEN 1 ELSE 0 END AS FLAG_SELL
FROM BASE1 B) -- Select transaction table with flag buy and sell

,DEMOGRAPHY_FEMALE_NOT_FROM_KEUNTUNGAN_BISNIS AS (
SELECT * FROM demography T
WHERE T.user_gender = 'Female'
AND T.user_income_source <> 'Keuntungan Bisnis' ) -- Select demography table filtered by female gender and income source not from keuntungan bisnis

, FINAL_DATA AS (
SELECT DMG.USER_ID,
       DMG.USER_GENDER,
       DMG.USER_INCOME_SOURCE,
       SUM(FLAG_SELL) AS COUNT_SELL 
FROM BUY_SELL_SAHAM_ACTIVITY BSA
JOIN DEMOGRAPHY_FEMALE_NOT_FROM_KEUNTUNGAN_BISNIS DMG ON BSA.USER_ID = DMG.USER_ID
GROUP BY USER_GENDER,USER_INCOME_SOURCE,USER_ID ) -- Select table with user_id, user gender, user income source, total count of users' sell saham activity

SELECT * FROM FINAL_DATA 
ORDER BY COUNT_SELL DESC
LIMIT 3 -- Select top 3 users with most selling on saham who are female and income source not from keuntungan bisnis
```
