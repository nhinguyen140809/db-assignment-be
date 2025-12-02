-- =====================================================
-- File: fn_get_category_restaurants.sql
-- Description: Function to retrieve restaurants with more than MinItems items in a given category.
-- =====================================================

CREATE OR ALTER FUNCTION fn_GetCategoryRestaurants
    (
        @CategoryName NVARCHAR(64),
        @MinItems     INT = 3
    )
RETURNS @Result TABLE
    (
        restaurant_id               IDType,
        restaurant_name             NVARCHAR(128),
        restaurant_longitude        LongitudeType,
        restaurant_latitude         LatitudeType,
        average_rating              FLOAT,
        number_of_items_in_category INT
    )
AS
    BEGIN
        IF (
               @MinItems IS NULL
               OR @MinItems < 1
           )
        RETURN;

        INSERT INTO @Result
        SELECT
            r.restaurant_id                     AS restaurant_id,
            r.name                              AS restaurant_name,
            r.longitude                         AS restaurant_longitude,
            r.latitude                          AS restaurant_latitude,
            AVG(CAST(rr.rating_point AS FLOAT)) AS average_rating,
            COUNT(ci.menu_item_id)              AS number_of_items_in_category
        FROM
            category_items        ci
            JOIN
                restaurant        r
                    ON ci.restaurant_id = r.restaurant_id
            LEFT JOIN
                restaurant_review rr
                    ON r.restaurant_id = rr.restaurant_id
        WHERE
            ci.category_name = @CategoryName
        GROUP BY
            r.restaurant_id,
            r.name,
            r.longitude,
            r.latitude
        HAVING
            COUNT(ci.menu_item_id) > @MinItems -- only include restaurants with more than MinItems items in this category

        RETURN;
    END
GO
