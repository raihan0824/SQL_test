-- CREATE TABLE RETENTION AS
WITH LOYAL_USER AS (
select DISTINCT USER_ID,MAX(RN) AS TOTAL_ACTIVE_DAYS from (
select t.*,
	   CASE WHEN TOTAL_INVESTMENT IS NOT NULL AND TOTAL_INVESTMENT <> 0 THEN ROW_NUMBER()OVER(partition by T.user_id ORDER BY T.DATE) END AS RN
FROM
(
SELECT T.*,
	   T.Saham_invested_amount+T.Campuran_invested_amount+T.Pasar_Uang_invested_amount+T.Pendapatan_Tetap_invested_amount AS Total_Investment
from transaction T
) t
) T
GROUP BY USER_ID
)
SELECT A.*,B.TOTAL_ACTIVE_DAYS
FROM demography A 
LEFT JOIN LOYAL_USER B ON A.USER_ID = B.USER_ID
#where a.user_occupation = 'Pensiunan'
