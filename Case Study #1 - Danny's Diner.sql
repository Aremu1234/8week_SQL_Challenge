--============================================= Q1 ===========================================================
SELECT 
	s.customer_id
	,[Amount Spent] = SUM(price)
FROM
	sales s
	JOIN menu m
		ON s.product_id = m.product_id
GROUP BY customer_id
--============================================ Q2 ============================================================
SELECT 
	s.customer_id
	,[Number of Visit] = COUNT(customer_id)
FROM
	sales s
GROUP BY customer_id
	

--=========================================== Q3 ==============================================================

SELECT
	 customer_id
	,[Product Name] = product_name
	FROM(
SELECT s.order_date,
		[Rank] = RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date),
		s.customer_id,
		m.product_name FROM sales s
     JOIN menu m ON s.product_id = m.product_id
	 ) V1
WHERE [Rank] = 1
------------------------------------------- OR ----------------------------------------------------------------

SELECT customer_id,
       [Product Name] = STUFF(
            (SELECT ', ' + V2.product_name
             FROM (
                 SELECT s.order_date,
                        [Rank] = RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date),
                        s.customer_id,
                        m.product_name
                 FROM sales s
                 JOIN menu m ON s.product_id = m.product_id
             ) V2
             WHERE V2.customer_id = V1.customer_id
             AND V2.[Rank] = 1
             FOR XML PATH('')), 1, 1, '')
FROM (
     SELECT s.order_date,
            [Rank] = RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date),
            s.customer_id,
            m.product_name
     FROM sales s
     JOIN menu m ON s.product_id = m.product_id
     ) V1
WHERE V1.[Rank] = 1
GROUP BY customer_id

--============================================= Q4 ===============================================================

SELECT
	[Product Name] = M.product_name
	, COUNT(M.product_id) AS [Purchase Times]
FROM
	sales s
		JOIN menu m 
			ON s.product_id = m.product_id
GROUP BY M.product_name
Having max(m.product_id) in (SELECT COUNT(s.product_id) FROM sales s JOIN menu m ON s.product_id = m.product_id group by product_name)


--============================================= Q5 ========================================================

SELECT
	customer_id
	,[Product Name]
FROM
(
	SELECT
		customer_id
		,[Product Name]
		,[Prouduct Count]
		,[Rank] = Rank() OVER(PARTITION BY customer_id ORDER BY [Prouduct Count] DESC)
	FROM
	(
		SELECT
			s.customer_id
			,[Product Name] = M.product_name
			, COUNT(M.product_id) AS [Prouduct Count]
		FROM
			sales s
				JOIN menu m 
					ON s.product_id = m.product_id
		GROUP BY S.customer_id,M.product_name
	) V1
)V2
WHERE [Rank] = 1

------------------------------------------ OR -----------------------------------------------------------------

SELECT
	customer_id
	,[Product Name] =
						STUFF (
						( SELECT 
								',' + V4.[Product Name]
							FROM
									(
									SELECT
										customer_id
										,[Product Name]
										,[Prouduct Count]
										,[Rank] = Rank() OVER(PARTITION BY customer_id ORDER BY [Prouduct Count] DESC)
									FROM
									(
										SELECT
											s.customer_id
											,[Product Name] = M.product_name
											, COUNT(M.product_id) AS [Prouduct Count]
										FROM
											sales s
												JOIN menu m 
													ON s.product_id = m.product_id
										GROUP BY S.customer_id,M.product_name
									) V3
								)V4
						WHERE V4.customer_id = V2.customer_id
						AND [Rank] = 1
						FOR XML PATH('')),1,1,'')
								
FROM
(
	SELECT
		customer_id
		,[Product Name]
		,[Prouduct Count]
		,[Rank] = Rank() OVER(PARTITION BY customer_id ORDER BY [Prouduct Count] DESC)
	FROM
	(
		SELECT
			s.customer_id
			,[Product Name] = M.product_name
			, COUNT(M.product_id) AS [Prouduct Count]
		FROM
			sales s
				JOIN menu m 
					ON s.product_id = m.product_id
		GROUP BY S.customer_id,M.product_name
	) V1
)V2
WHERE [Rank] = 1
GROUP BY customer_id

--============================================ Q6 ================================================================

SELECT
	customer_id
   ,product_name
FROM
(
SELECT
customer_id
,product_name
, [Rank] = RANK() OVER(PARTITION BY customer_id ORDER BY order_date )
FROM
(
SELECT
	s.customer_id
	,order_date
	,product_name
	,join_date
FROM
	sales s
		JOIN menu m 
			ON S.product_id = M.product_id
		JOIN members mb 
			ON S.customer_id = MB.customer_id
)v1
WHERE
	order_date > join_date
) V2
WHERE [RANK] = 1

--================================================== Q7 ===========================================================================

WITH Purchases AS
(
	SELECT
		s.customer_id
		,order_date
		,product_name
		,join_date
		, [Rank] = RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC)
	FROM
		sales s
			JOIN menu m 
				ON S.product_id = M.product_id
			JOIN members mb 
				ON S.customer_id = MB.customer_id
	WHERE 
			order_date < join_date
)
SELECT 
	customer_id
	,product_name
FROM
Purchases
WHERE [Rank] = 1

----------------------------------------- OR ---------------------------------------------------------
SELECT
	 customer_id,
	[Product Name] = 
					STUFF( 
						(SELECT
							', ' + V2.product_name
						FROM
						(
							SELECT
								s.customer_id
								,order_date
								,product_name
								,join_date
								, [Rank] = RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC)
							FROM
								sales s
									JOIN menu m 
										ON S.product_id = M.product_id
									JOIN members mb 
										ON S.customer_id = MB.customer_id
							WHERE 
									order_date < join_date) V2
							WHERE v2.customer_id = v1.customer_id
							AND [Rank] = 1
							FOR XML PATH('')),1,1,'')
FROM
(
	
	SELECT
		s.customer_id
		,order_date
		,product_name
		,join_date
		, [Rank] = RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC)
	FROM
		sales s
			JOIN menu m 
				ON S.product_id = M.product_id
			JOIN members mb 
				ON S.customer_id = MB.customer_id
	WHERE 
			order_date < join_date
) V1
GROUP BY customer_id;

--========================================================= Q8 =====================================================================


	SELECT
		s.customer_id
		,COUNT(S.customer_id) [Total Items]
	    ,SUM(price) [Amount]
	FROM
		sales s
			JOIN menu m 
				ON S.product_id = M.product_id
			JOIN members mb 
				ON S.customer_id = MB.customer_id
	WHERE 
			order_date < join_date
	GROUP BY S.customer_id;


--================================================================= Q9 =============================================================================
WITH PointCal AS
(
SELECT
	s.customer_id AS Customers
	,m.product_name AS [Product Name]
	,m.price
	,Points = 
		CASE
			WHEN m.product_name = 'sushi' THEN m.price * 20
			ELSE m.price * 10
		END
FROM
	sales s
	JOIN menu m
		ON s.product_id = m.product_id
	)
	SELECT
		Customers
		,[Total Points] = SUM(Points)
	FROM
		PointCal
	GROUP BY Customers;

--==================================================================== Q10 ==========================================================================

WITH tblPoints AS
(
SELECT
	s.customer_id
	,product_name
	,price
	,points = m.price * 20
FROM
	sales s
		JOIN menu m 
			ON S.product_id = M.product_id
		JOIN members mb 
			ON S.customer_id = MB.customer_id
WHERE
	order_date >= join_date
		AND MONTH(order_date) = 1
)
SELECT 
	customer_id
	,[Total points] = SUM(points)
FROM
	tblpoints
GROUP BY customer_id

--====================================== BONUS QUESTION ===========================================================


---------------------------------------------- JOINING ALL THINGS ---------------------------------------------------------
CREATE TABLE FactSales 
	(
		customer_id		VARCHAR(1)
		,order_date		DATE
		,product_name	VARCHAR(6)
		,price			SMALLMONEY
		,member			VARCHAR(1)
	)


INSERT INTO FactSales VALUES
('A', '2021-01-01', 'curry', 15, 'N'),
('A', '2021-01-01', 'sushi', 10, 'N'),
('A', '2021-01-07', 'curry', 15, 'Y'),
('A', '2021-01-10', 'ramen', 12, 'Y'),
('A', '2021-01-11', 'ramen', 12, 'Y'),
('A', '2021-01-11', 'ramen', 12, 'Y'),
('B', '2021-01-01', 'curry', 15, 'N'),
('B', '2021-01-02', 'curry', 15, 'N'),
('B', '2021-01-04', 'sushi', 10, 'N'),
('B', '2021-01-11', 'sushi', 10, 'Y'),
('B', '2021-01-16', 'ramen', 12, 'Y'),
('B', '2021-02-01', 'ramen', 12, 'Y'),
('C', '2021-01-01', 'ramen', 12, 'N'),
('C', '2021-01-01', 'ramen', 12, 'N'),
('C', '2021-01-07', 'ramen', 12, 'N')

--============================================= RANK ALL THE THINGS =====================================================================================
SELECT 
*
,[Ranking] =   
		CASE	
			WHEN member = 'Y' THEN DENSE_RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
			ELSE NULL 
		END 
FROM FactSales