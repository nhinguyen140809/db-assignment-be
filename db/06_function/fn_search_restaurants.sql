-- =============================================
-- File: fn_search_restaurants.sql
-- Purpose: Stored function to search for restaurants based on keyword, match name and menu items.
-- =============================================


CREATE OR ALTER FUNCTION fn_SearchRestaurants (@Keyword NVARCHAR(128))
RETURNS TABLE
AS
RETURN
    (
        WITH RestaurantData
        AS (
               SELECT
                   r.restaurant_id,
                   r.name                              AS restaurant_name,
                   r.longitude,
                   r.latitude,
                   AVG(CAST(rr.rating_point AS FLOAT)) AS average_rating,
                   COUNT(mi.food_id)                   AS number_of_items
               FROM
                   restaurant            r
                   LEFT JOIN
                       restaurant_review rr
                           ON r.restaurant_id = rr.restaurant_id
                   LEFT JOIN
                       menu_item         mi
                           ON r.restaurant_id = mi.restaurant_id
               GROUP BY
                   r.restaurant_id,
                   r.name,
                   r.longitude,
                   r.latitude
           )
        SELECT DISTINCT
            rd.restaurant_id,
            rd.restaurant_name,
            rd.longitude,
            rd.latitude,
            rd.average_rating,
            rd.number_of_items
        FROM
            RestaurantData rd
            LEFT JOIN
                menu_item  mi
                    ON rd.restaurant_id = mi.restaurant_id
        WHERE
            @Keyword IS NULL
            OR LTRIM(RTRIM(@Keyword)) = ''
            OR rd.restaurant_name LIKE '%' + @Keyword + '%'
            OR mi.name LIKE '%' + @Keyword + '%'
    );
GO