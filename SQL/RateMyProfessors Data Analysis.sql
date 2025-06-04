--Pearson correlation coefficient
https://www.socscistatistics.com/tests/pearson/default2.aspx
--Pvalue 
https://www.socscistatistics.com/pvalues/pearsondistribution.aspx
--With correlation: Causation can be explored, but be cautious and consider all possible explanations.

--Without correlation: Causation may not be worth exploring unless there are strong theoretical or domain-based reasons to suspect a hidden causal link.











-- Should we have training for professors to teach teaching skills to be more helpful and clear.
-- find if there is a correlation between teahcers who are called "helpful" or "clear" and a higher avg rating.
/*with count_of_reviews_for_professor as (SELECT * FROM Reviews Group BY Professor_Name)) AS count_of_reviews_for_professor);

SELECT p.Professor_Name, p.Department, ROUND(AVG(r.Quality),1) AS avg_rating, COUNT(r.Comment) AS amount_of_comments, COUNT(count_of_reviews_for_professor) AS count_of_reviews_for_professor
FROM Professors p
JOIN Reviews r ON p.Professor_ID = r.Professor_ID
WHERE (r.Comment LIKE '%clarity%' AND r.comment not like '%no clarity%' AND r.comment not like '%little clarity%') OR (r.Comment LIKE '%helpful%' and r.comment not like '%not helpful%' and r.comment not like '%unhelpful%')
GROUP BY p.Professor_Name, p.Department
ORDER BY avg_rating DESC;*/

--
WITH count_of_reviews_for_professor AS (
    SELECT Professor_ID, COUNT(*) AS total_reviews
    FROM Reviews
    GROUP BY Professor_ID
)

SELECT 
    p.Professor_Name, 
    p.Department, 
    ROUND(AVG(r.Quality), 1) AS avg_rating, 
    COUNT(r.Comment) AS amount_of_positive_comments,
    crfp.total_reviews AS total_reviews_for_professor
FROM Professors p
JOIN Reviews r ON p.Professor_ID = r.Professor_ID
JOIN count_of_reviews_for_professor crfp ON p.Professor_ID = crfp.Professor_ID
WHERE 
    (
        r.Comment LIKE '%clarity%' AND r.Comment NOT LIKE '%no clarity%' AND r.Comment NOT LIKE '%little clarity%'
    ) 
    OR 
    (
        r.Comment LIKE '%helpful%' AND r.Comment NOT LIKE '%not helpful%' AND r.Comment NOT LIKE '%unhelpful%'
    )
GROUP BY p.Professor_Name, p.Department, crfp.total_reviews
HAVING crfp.total_reviews >= 10
ORDER BY avg_rating DESC;


-- opposite
/*SELECT p.Professor_Name, p.Department, ROUND(AVG(r.Quality),1) AS avg_rating, COUNT(r.Comment) AS amount_of_comments
FROM Professors p
JOIN Reviews r ON p.Professor_ID = r.Professor_ID
WHERE r.Comment LIKE '%not clear%' OR r.Comment LIKE '%not helpful%' OR r.Comment LIKE '%unhelpful%' OR r.Comment LIKE '%unclear%' OR r.Comment LIKE '%unsure%' OR r.Comment LIKE '%ambiguous%' OR r.Comment LIKE '%hazy%' OR r.Comment LIKE '%confused%'
GROUP BY p.Professor_Name, p.Department
ORDER BY avg_rating ASC;*/


--
WITH count_of_reviews_for_professor AS (
    SELECT Professor_ID, COUNT(*) AS total_reviews
    FROM Reviews
    GROUP BY Professor_ID
)

SELECT 
    p.Professor_Name, 
    p.Department, 
    ROUND(AVG(r.Quality), 1) AS avg_rating, 
    COUNT(r.Comment) AS amount_of_negative_comments,
    crfp.total_reviews AS total_reviews_for_professor
FROM Professors p
JOIN Reviews r ON p.Professor_ID = r.Professor_ID
JOIN count_of_reviews_for_professor crfp ON p.Professor_ID = crfp.Professor_ID
WHERE 
    (
        r.Comment LIKE '%not clear%' 
        OR r.Comment LIKE '%unclear%' 
        OR r.Comment LIKE '%unsure%' 
        OR (r.Comment LIKE '%ambiguous%' AND r.Comment NOT LIKE '%unambiguous%')
        OR r.Comment LIKE '%not helpful%' 
        OR r.Comment LIKE '%unhelpful%'
    )
GROUP BY p.Professor_Name, p.Department, crfp.total_reviews
HAVING crfp.total_reviews >= 10
ORDER BY avg_rating ASC;




select Review_Date
FROM Reviews



-- should we cut down on number of courses a teacher is allowed to teach?
-- Is there a correlation between a professor�s number of courses taught per semester and ratings?
-- more courses, lower ratings?
-- less courses, higher ratings?

/*SELECT p.Professor_Name, COUNT(DISTINCT r.Class_Name) AS courses_taught, ROUND(AVG(r.Quality),1) AS avg_rating
FROM Professors p
JOIN Reviews r ON p.Professor_ID = r.Professor_ID
GROUP BY p.Professor_Name
ORDER BY courses_taught DESC, avg_rating DESC;*/

SELECT 
    p.Professor_Name, 
    COUNT(DISTINCT r.Class_Name) AS courses_taught, 
    ROUND(AVG(r.Quality), 1) AS avg_rating,
    COUNT(r.Review_Date) AS total_reviews
FROM Professors p
JOIN Reviews r ON p.Professor_ID = r.Professor_ID
GROUP BY p.Professor_Name
HAVING COUNT(r.Review_Date) > 10
ORDER BY courses_taught DESC, avg_rating DESC;
-- change review date count to have a bigger n (pairs)

-- it seems like there is - - correlation between amount of courses taught and avg rating so - - we - - cut down on number of courses a teacher is allowed to teach


SELECT 
    review_count,
    COUNT(*) AS number_of_professors
FROM (
    SELECT 
        p.Professor_ID,
        COUNT(*) AS review_count
    FROM Reviews r
    JOIN Professors p ON p.Professor_ID = r.Professor_ID
    GROUP BY p.Professor_ID
) AS review_counts
GROUP BY review_count
ORDER BY number_of_professors desc;



-- What percentage of a department's professors fall below a 3.0 average quality rating, and how has this trended over time?
WITH ProfessorYearlyRatings AS (
    SELECT 
        p.Professor_ID,
        p.Professor_Name,
        p.Department,
        YEAR(r.Review_Date) AS review_year,
        ROUND(AVG(r.Quality), 2) AS avg_rating
    FROM Professors p
    JOIN Reviews r ON p.Professor_ID = r.Professor_ID
    GROUP BY p.Professor_ID, p.Professor_Name, p.Department, YEAR(r.Review_Date)
)

SELECT 
    Department,
    review_year,
    COUNT(*) AS total_professors,
    COUNT(CASE WHEN avg_rating < 3.0 THEN 1 END) AS professors_below_3_rating,
    ROUND(100.0 * COUNT(CASE WHEN avg_rating < 3.0 THEN 1 END) / COUNT(*), 1) AS percent_below_3_rating
FROM ProfessorYearlyRatings
GROUP BY Department, review_year
ORDER BY Department, review_year;



-- Are newer post covid professors (those who started appearing post-2023) performing better or worse than longer-tenured ones
-- we need post 2023 professors (they have to have no records before 2022. use YEAR() on dates) 2023-2025 reviews and see avg rating
-- we need pre 2023 professors (they have to have records before 2022. use Year() on dates) 2023-2025 reviews and see avg rating
WITH NewerProfessors AS (
    SELECT professor_id
    FROM Reviews
    GROUP BY professor_id
    HAVING MIN(YEAR(review_date)) >= 2023
),
LongerTenuredProfessors AS (
    SELECT professor_id
    FROM Reviews
    GROUP BY professor_id
    HAVING MIN(YEAR(review_date)) < 2022
),
FilteredReviews AS (
    SELECT professor_id, rating
    FROM Reviews
    WHERE YEAR(review_date) BETWEEN 2023 AND 2025
)

SELECT 
    'Newer Professors (Post-2023)' AS professor_group,
    AVG(F.rating) AS avg_rating
FROM FilteredReviews F
JOIN NewerProfessors N ON F.professor_id = N.professor_id

UNION ALL

SELECT 
    'Longer-Tenured Professors (Pre-2022)' AS professor_group,
    AVG(F.rating) AS avg_rating
FROM FilteredReviews F
JOIN LongerTenuredProfessors L ON F.professor_id = L.professor_id;



-- individual
WITH NewerProfessors AS (
    SELECT professor_id
    FROM Reviews
    GROUP BY professor_id
    HAVING MIN(YEAR(review_date)) >= 2023
),
LongerTenuredProfessors AS (
    SELECT professor_id
    FROM Reviews
    GROUP BY professor_id
    HAVING MIN(YEAR(review_date)) < 2022
),
FilteredReviews AS (
    SELECT professor_id, rating
    FROM Reviews
    WHERE YEAR(review_date) BETWEEN 2023 AND 2025
)

SELECT 
    P.professor_name,
    F.professor_id,
    'Newer Professor (Post-2023)' AS professor_type,
    AVG(F.rating) AS avg_rating_2023_2025
FROM FilteredReviews F
JOIN NewerProfessors N ON F.professor_id = N.professor_id
JOIN Professors P ON F.professor_id = P.professor_id
GROUP BY P.professor_name, F.professor_id

UNION ALL

SELECT 
    P.professor_name,
    F.professor_id,
    'Longer-Tenured Professor (Pre-2022)' AS professor_type,
    AVG(F.rating) AS avg_rating_2023_2025
FROM FilteredReviews F
JOIN LongerTenuredProfessors L ON F.professor_id = L.professor_id
JOIN Professors P ON F.professor_id = P.professor_id
GROUP BY P.professor_name, F.professor_id;

-- Are Professor Rating improving or declining over time?

SELECT YEAR(Review_Date) as Review_year, round(avg(Avg_Rating),1) rating_over_time, COUNT(*) as Num_Reviews
FROM Professors P
JOIN Reviews R on P.Professor_ID = R.Professor_ID
GROUP BY YEAR(Review_Date)
ORDER BY YEAR(Review_Date)

-- Department Analysis 
-- What department have the most or least engaged students (number of reviews/comments)
-- What classes contains the highest rating or highest difficulty?
-- Which colleges have the most professor reviews, and how do they compare in terms of average professor quality, difficulty, and number of unique professors?

SELECT P.Department, count(r.comment) as num_reviews
FROM Professors P
JOIN Reviews R on P.Professor_ID = R.Professor_ID
GROUP BY P.Department
order by count(r.comment) desc

SELECT Class_Name, avg(Quality) as avg_quality, avg(Difficulty) as avg_dfficulty
FROM Professors P
JOIN Reviews R on P.Professor_ID = R.Professor_ID
Group by Class_Name
order by avg(Quality) desc, avg(Difficulty) desc

SELECT Colleges, count(*) as num_reviews, count(distinct(Professor_Name)) as num_professors, avg(quality) as avg_college_quality, avg(difficulty) as avg_college_difficulty
FROM Reviews
WHERE Colleges like 'College%'
group by Colleges
order by count(*) desc

-- Do comments that mention 'easy' or 'hard' correlate with difficulty ratings?
SELECT 
    CASE 
        WHEN Comment LIKE '%easy%' THEN 'Mentions Easy'
        WHEN Comment LIKE '%hard%' THEN 'Mentions Hard'
        ELSE 'No Mention'
    END AS Mention_Type,
    COUNT(*) AS Num_Reviews,
    AVG(Difficulty) AS Avg_Difficulty
FROM Reviews
WHERE Comment LIKE '%easy%' OR Comment LIKE '%hard%'
GROUP BY 
    CASE 
        WHEN Comment LIKE '%easy%' THEN 'Mentions Easy'
        WHEN Comment LIKE '%hard%' THEN 'Mentions Hard'
        ELSE 'No Mention'
    END
ORDER BY Avg_Difficulty

-- What are the most frequently used words in comments for highly rated vs poorly rated professors. 
-- Positive review words
SELECT LOWER(TRIM(REPLACE(REPLACE(REPLACE(value, '.', ''), ',', ''), '!', ''))) AS word,
       COUNT(*) AS freq
FROM Reviews
CROSS APPLY STRING_SPLIT(Comment, ' ')
WHERE Quality >= 4.0
  AND LEN(value) > 3
GROUP BY LOWER(TRIM(REPLACE(REPLACE(REPLACE(value, '.', ''), ',', ''), '!', '')))
ORDER BY freq DESC;

-- Negative Review Words
SELECT LOWER(TRIM(REPLACE(REPLACE(REPLACE(value, '.', ''), ',', ''), '!', ''))) AS word,
       COUNT(*) AS freq
FROM Reviews
CROSS APPLY STRING_SPLIT(Comment, ' ')
WHERE Quality <= 2.0
  AND LEN(value) > 3
GROUP BY LOWER(TRIM(REPLACE(REPLACE(REPLACE(value, '.', ''), ',', ''), '!', '')))
ORDER BY freq DESC;
