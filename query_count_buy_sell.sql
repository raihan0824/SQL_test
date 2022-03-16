-- CREATE TABLE BUY_SELL AS
WITH BASE1 AS (
SELECT A.*,
	   A.Saham_invested_amount+A.Campuran_invested_amount+A.Pasar_Uang_invested_amount+A.Pendapatan_Tetap_invested_amount AS Total_Investment
from transaction A)

,BASE2 AS (
SELECT B.*,
	   coalesce(LAG(B.TOTAL_INVESTMENT) OVER(PARTITION BY USER_ID ORDER BY B.DATE ASC),B.TOTAL_INVESTMENT) AS PREVIOUS_DAY_MONEY,
       TOTAL_INVESTMENT - coalesce(LAG(B.TOTAL_INVESTMENT) OVER(PARTITION BY USER_ID ORDER BY B.DATE ASC),B.TOTAL_INVESTMENT) AS BUY_SELL
FROM BASE1 B)

,BUY_SELL_ACTIVITY AS (
SELECT C.*,
	   CASE WHEN BUY_SELL > 0 THEN 1 ELSE 0 END AS FLAG_BUY ,
       CASE WHEN BUY_SELL < 0 THEN 1 ELSE 0 END AS FLAG_SELL
FROM BASE2 C)

SELECT DMG.user_id,
	   DMG.user_age,
	   DMG.user_income_range,
       DMG.user_income_source,
       DMG.user_occupation,
	   SUM(FLAG_BUY) AS COUNT_BUY
FROM demography DMG
JOIN BUY_SELL_ACTIVITY BSA ON DMG.user_id = BSA.user_id
GROUP BY
	   DMG.user_id,
	   DMG.user_age,
	   DMG.user_income_range,
       DMG.user_income_source,
       DMG.user_occupation
ORDER BY COUNT_BUY DESC;

