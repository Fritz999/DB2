-- -----------------
-- Mandatory queries
-- -----------------

----------------------------------------------------------------
-- 1. All values within a certain time range for a single sensor
----------------------------------------------------------------

-- Sensor named with point_uid
SELECT time_stamp, COALESCE(boolean_value, integer_value, float_value, string_value) AS 'value' 
FROM measured_values 
WHERE (point_uid = 21)
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-05-05 23:59:59.999');

-- Sensor named with type and id
SET @point_uid = (
    SELECT point_uid 
    FROM measuring_points 
    WHERE (type='tinkerforge/accelerometer/acceleration/z') 
    AND (id='03/pz206026/v75')
    );
SELECT time_stamp, COALESCE(boolean_value, integer_value, float_value, string_value) AS 'value' 
FROM measured_values 
WHERE point_uid = @point_uid
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-05-05 23:59:59.999');

-- ---------------------------------------
-- 2. Single data point for a given sensor
-- ---------------------------------------

-- 2.1 Linear Interpolation

-- Example:
-- R: 2017-05-05 18:27:38.757246, 1029
-- S: 2017-05-05 18:27:40.000000, ???? -> 1028.75!
-- T: 2017-05-05 18:27:43.77951, 1028

-- Input
SET @given_timestamp = 2017-05-05 18:27:40.000000;
SET @point_uid = 21;

SELECT time_stamp, COALESCE(boolean_value, integer_value, float_value, string_value)
INTO @timestamp_latest_value, @latest_value
FROM measured_values 
WHERE point_uid = @point_uid
AND time_stamp <= @given_timestamp
ORDER BY time_stamp DESC
LIMIT 1;
SET @timestamp_latest_value = UNIX_TIMESTAMP(@timestamp_latest_value);

SELECT time_stamp, COALESCE(boolean_value, integer_value, float_value, string_value)
INTO @timestamp_next_value, @next_value
FROM measured_values 
WHERE point_uid = @point_uid
AND time_stamp >= @given_timestamp
ORDER BY time_stamp ASC
LIMIT 1;
SET @timestamp_next_value= UNIX_TIMESTAMP(@timestamp_next_value);

-- Output
SELECT FROM_UNIXTIME(@timestamp_latest_value) AS 'Timestamp latest value', @latest_value AS 'Value';
SELECT FROM_UNIXTIME(@timestamp_next_value) AS 'Timestamp next value', @next_value AS 'Value';
SELECT @given_timestamp AS 'Selected timestamp', ((@latest_value - @next_value)/(@timestamp_latest_value - @timestamp_next_value) * (UNIX_TIMESTAMP(@given_timestamp) - @timestamp_next_value) + @next_value) AS 'Linearly interpolated value';

-- 2.2 Forward Fill
SELECT point_uid, COALESCE(boolean_value, integer_value, float_value, string_value) AS 'Forward fill value'
FROM measured_values
WHERE point_uid = 121
AND time_stamp <= '2017-12-01 18:51:47.663088' -- "Empty set", if no value
ORDER BY time_stamp DESC
LIMIT 1; -- First row from results

-- -----------------------------------------------------------
-- 3.1 Maximum for a single sensor within a certain time range
-- -----------------------------------------------------------

-- Sensor named with point_uid
SELECT MAX(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Maximum value'
FROM measured_values 
WHERE point_uid = 21
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-05-05 23:59:59.999');

-- Sensor named with type and id

-- With JOIN operation [FOR COMPARISON]
SELECT MAX(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Maximum value'
FROM measured_values mv
JOIN measuring_points mp USING (point_uid)
WHERE mp.type='tinkerforge/accelerometer/acceleration/z' 
AND mp.id='03/pz206026/v75'
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-12-31 23:59:59.999');

-- @point_uid
SET @point_uid = (
    SELECT point_uid 
    FROM measuring_points 
    WHERE type='tinkerforge/accelerometer/acceleration/z'
    AND id='03/pz206026/v75'
    );
SELECT MAX(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Maximum value'
FROM measured_values 
WHERE point_uid = @point_uid
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-12-31 23:59:59.999');

-- ----------------------------------------------------------
-- 3.2 Minimum for a single sensor within a certain time range
-- ----------------------------------------------------------

-- Sensor named with point_uid
SELECT MIN(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Minimal value'
FROM measured_values 
WHERE (point_uid = 21)
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-12-31 23:59:59.999');

-- Sensor named with type and id
SET @point_uid = (
    SELECT point_uid 
    FROM measuring_points 
    WHERE (type='tinkerforge/accelerometer/acceleration/z') 
    AND (id='03/pz206026/v75')
    );
SELECT MIN(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Minimal value'
FROM measured_values 
WHERE point_uid = @point_uid
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-12-31 23:59:59.999');

-- -----------------------------------------------------------
-- 3.3 Average for a single sensor within a certain time range
-- -----------------------------------------------------------

-- Sensor named with point_uid
SELECT AVG(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Average value'
FROM measured_values 
WHERE point_uid = 21
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-05-05 23:59:59.999');

-- Sensor named with type and id
SET @point_uid = (
    SELECT point_uid 
    FROM measuring_points 
    WHERE type='tinkerforge/accelerometer/acceleration/z' 
    AND id='03/pz206026/v75'
    );
SELECT AVG(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Average value'
FROM measured_values 
WHERE point_uid = @point_uid
AND (time_stamp BETWEEN '2017-05-05 00:00:00.000' AND '2017-05-05 23:59:59.999');

-- 4. [...]