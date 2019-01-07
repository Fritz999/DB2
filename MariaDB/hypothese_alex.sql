SELECT
(
  (
  SELECT TIMESTAMPDIFF(SQL_TSI_SECOND, (
  SELECT MIN(COALESCE(time_stamp)) FROM measured_values WHERE point_uid = 21
),(
SELECT MAX(COALESCE(time_stamp)) FROM measured_values WHERE point_uid = 21
)) / 5
  ) -
  (
  SELECT COUNT(*)
  FROM measured_values
  WHERE point_uid = 21
  )
)
