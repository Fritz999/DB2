/*
cd c:\xampp\mysql\bin
mysql.exe -u root -p //PW: root
use db2_ws2018_19_test
*/

-- ---------------------------------
-- Creating database 'db2_ws2018_19_test'
-- ---------------------------------
DROP DATABASE IF EXISTS db2_ws2018_19_test;
CREATE DATABASE db2_ws2018_19_test CHARACTER SET utf8 COLLATE utf8_general_ci;
USE db2_ws2018_19_test;
-- ---------------------------------
-- Creating table 'measuring_points'
-- ---------------------------------
DROP TABLE IF EXISTS measuring_points;
CREATE TABLE measuring_points (point_uid SMALLINT NOT NULL, type varchar(255) NOT NULL, id varchar(255) NOT NULL, data_type ENUM ('boolean', 'bigint', 'double precision', 'text') NOT NULL, PRIMARY KEY (point_uid));
-- --------------------------------
-- Creating table 'measured_values'
-- --------------------------------
DROP TABLE IF EXISTS measured_values;
CREATE TABLE measured_values (value_uid INT NOT NULL AUTO_INCREMENT, point_uid SMALLINT NOT NULL, time_stamp TIMESTAMP(6), boolean_value ENUM ('f','t'), integer_value BIGINT, float_value DOUBLE PRECISION, string_value varchar(255), PRIMARY KEY (value_uid), FOREIGN KEY (point_uid) REFERENCES measuring_points(point_uid));
-- ---------------------------------------------------------
-- Loading data from dataset into the table measuring_points
-- ---------------------------------------------------------
LOAD DATA LOCAL INFILE 'D:/Bernd/Daten/Informatik/VU DB2/points.csv' INTO TABLE measuring_points  FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
-- --------------------------------------------------------
-- Loading data from dataset into the table measured_values
-- --------------------------------------------------------
LOAD DATA LOCAL INFILE 'D:/Bernd/Daten/Informatik/VU DB2/values_test.csv' INTO TABLE measured_values FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES (point_uid, time_stamp, @boolean_value, @integer_value, @float_value, @string_value) SET boolean_value = NULLIF(@boolean_value,''), integer_value = NULLIF(@integer_value,''), float_value = NULLIF(@float_value,''), string_value = NULLIF(@string_value,''), value_uid = NULL;
-- https://www.w3resource.com/mysql/comparision-functions-and-operators/coalesce-function.php
-- https://stackoverflow.com/questions/2675323/mysql-load-null-values-from-csv-data
-- -----------------
-- Mandatory queries
-- -----------------
SELECT value_uid, point_uid, COALESCE(boolean_value, integer_value, float_value, string_value) AS 'value' 
FROM measured_values 
WHERE (point_uid = 123)
AND (time_stamp BETWEEN '2017-04-20 00:00:00.000' AND '2017-04-20 23:59:59.999');

SELECT value_uid, mv.point_uid, COALESCE(boolean_value, integer_value, float_value, string_value) AS 'value' 
FROM measured_values mv     -- , measuring_points mp
                            -- WHERE (mv.point_uid = mp.point_uid)
JOIN measuring_points mp USING (point_uid)
WHERE (mp.type='tinkerforge/accelerometer/temperature') AND (time_stamp BETWEEN '2017-04-20 00:00:00.000' AND '2017-04-20 23:59:59.999');






