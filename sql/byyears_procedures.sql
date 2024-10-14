--------------------------------------------------------
--  File created - poniedzia≥ek-paüdziernika-14-2024   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure BYYEARS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KARKULOWSKIT"."BYYEARS" (result_cursor OUT SYS_REFCURSOR) AS
BEGIN
  OPEN result_cursor FOR 
  SELECT EXTRACT(YEAR FROM game_date) AS year, 
         SUM(home_score) AS home_score, 
         SUM(away_score) AS away_score
  FROM KARKULOWSKIT.GAME
  GROUP BY EXTRACT(YEAR FROM game_date)
  ORDER BY year;
END BYYEARS;

/
