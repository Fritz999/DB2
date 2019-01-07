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
SET @given_timestamp = '2017-05-05 18:27:40.000000';
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
SELECT point_uid, time_stamp, COALESCE(boolean_value, integer_value, float_value, string_value) AS 'Forward fill value'
FROM measured_values
WHERE point_uid = 31
AND time_stamp <= '2018-01-01 00:00:00.000000' -- "Empty set", if no value
ORDER BY time_stamp DESC
LIMIT 1; -- First row from results

-- -----------------------------------------------------------
-- 3.1 Maximum for a single sensor within a certain time range
-- -----------------------------------------------------------

-- Sensor named with point_uid
-- Ex.: Nr. 31 
SELECT MAX(COALESCE(boolean_value, integer_value, float_value, string_value)) AS 'Maximum value'
FROM measured_values 
WHERE point_uid = 31
AND (time_stamp BETWEEN '2017-05-06 00:00:00.000' AND '2017-05-06 23:59:59.999');

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
WHERE point_uid = 31
AND (time_stamp BETWEEN '2017-05-06 00:00:00.000' AND '2017-05-06 23:59:59.999');

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

-- --------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------
-- 4. Softsensor room climate: temperature + humiditiy in room pz206026 (Inffeldg. 13/6)
-- --------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------

-- Input: timestamp
SET @selected_timestamp = '2017-05-05 18:27:48.000000';

-- Temperature sensor (no. 31)
SET @latest_temperature_value = ( -- fill-forward
    SELECT COALESCE(boolean_value, integer_value, float_value, string_value)
    FROM measured_values
    WHERE point_uid = 31
    AND time_stamp <= @selected_timestamp
    ORDER BY time_stamp DESC
    LIMIT 1
);
SELECT @latest_temperature_value; -- DEBUG

SET @latest_humidity_value = ( -- fill-forward
    SELECT COALESCE(boolean_value, integer_value, float_value, string_value)
    FROM measured_values
    WHERE point_uid = 30
    AND time_stamp <= @selected_timestamp
    ORDER BY time_stamp DESC
    LIMIT 1
);
SELECT @latest_humidity_value; -- DEBUG

SET @room_climate_temperature = 
    CASE
        WHEN @latest_temperature_value < 18 THEN 3
        WHEN @latest_temperature_value < 20 THEN 2
        WHEN @latest_temperature_value < 23 THEN 1
        WHEN @latest_temperature_value < 24 THEN 2
        ELSE 3
    END; 
SELECT @room_climate_temperature; -- DEBUG

SET @room_climate_humidity = 
    CASE
        WHEN @latest_humidity_value < 30 THEN 3
        WHEN @latest_humidity_value < 40 THEN 2
        WHEN @latest_humidity_value < 60 THEN 1
        WHEN @latest_humidity_value < 70 THEN 2
        ELSE 3
    END;
SELECT @room_climate_humidity; -- DEBUG
SELECT (@room_climate_temperature + @room_climate_humidity)/2 AS 'room climate in room pz206026';

-- TODO: Sicherstellen, das letzte Messung nicht länger als halbe Stunde vor gewählten Zeitpunkt ist

-- =====================
-- Diverse Hilfsabfragen
-- =====================

SELECT count(*)
FROM measured_values 
WHERE point_uid = 31
AND (time_stamp BETWEEN '2017-05-06 00:00:00.000' AND '2017-05-06 23:59:59.999');


-- ========================
-- Hypothese
-- ========================
SET @senor_nr = 32;
SELECT
(
(
  SELECT COUNT(*)
  FROM measured_values
  WHERE point_uid = @senor_nr
  ) /
  (
      SELECT TIMESTAMPDIFF(SQL_TSI_SECOND, (
      SELECT MIN(time_stamp) FROM measured_values WHERE point_uid = @senor_nr
      ),(
    SELECT MAX(time_stamp) FROM measured_values WHERE point_uid = @senor_nr
    )
  ) / 5
  )
);










