/*
cd c:\xampp\mysql\bin
mysql.exe -u root -p //PW: root
use db2_ws2018_19
*/
-- ---------------------------------
-- Creating database 'db2_ws2018_19'
-- ---------------------------------
DROP DATABASE IF EXISTS db2_ws2018_19;
CREATE DATABASE db2_ws2018_19 CHARACTER SET utf8 COLLATE utf8_general_ci;
USE db2_ws2018_19;
-- ---------------------------------
-- Creating table 'measuring_points'
-- ---------------------------------
DROP TABLE IF EXISTS measuring_points;
CREATE TABLE measuring_points (point_uid SMALLINT NOT NULL, type varchar(255) NOT NULL, id varchar(255) NOT NULL, data_type ENUM ('boolean', 'bigint', 'double precision', 'text') NOT NULL, PRIMARY KEY (point_uid), UNIQUE KEY (type, id));
-- --------------------------------
-- Creating table 'measured_values'
-- --------------------------------
DROP TABLE IF EXISTS measured_values;
CREATE TABLE measured_values (point_uid SMALLINT NOT NULL, time_stamp TIMESTAMP(6), boolean_value ENUM ('f','t'), integer_value BIGINT, float_value DOUBLE PRECISION, string_value varchar(255), PRIMARY KEY (point_uid, time_stamp), FOREIGN KEY (point_uid) REFERENCES measuring_points(point_uid))
-- ---------------------------------------------------------
-- Loading data from dataset into the table measuring_points
-- ---------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/Bernd/Documents/Informatik/LV/2018_19/VU DB2/Projekt/points.csv' INTO TABLE measuring_points  FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;
-- --------------------------------------------------------
-- Loading data from dataset into the table measured_values
-- --------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/Bernd/Documents/Informatik/LV/2018_19/VU DB2/Projekt/values.csv' INTO TABLE measured_values FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES (point_uid, time_stamp, @boolean_value, @integer_value, @float_value, @string_value) SET boolean_value = NULLIF(@boolean_value,''), integer_value = NULLIF(@integer_value,''), float_value = NULLIF(@float_value,''), string_value = NULLIF(@string_value,'');