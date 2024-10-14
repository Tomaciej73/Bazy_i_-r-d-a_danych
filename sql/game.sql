--------------------------------------------------------
--  File created - poniedziałek-października-14-2024   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table GAME
--------------------------------------------------------

  CREATE TABLE "KARKULOWSKIT"."GAME" 
   (	"ID" NUMBER GENERATED BY DEFAULT AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"GAME_DATE" DATE, 
	"HOME_TEAM_ID" NUMBER, 
	"AWAY_TEAM_ID" NUMBER, 
	"HOME_SCORE" NUMBER, 
	"AWAY_SCORE" NUMBER, 
	"TOURNAMENT_ID" NUMBER, 
	"CITY_ID" NUMBER, 
	"COUNTRY_ID" NUMBER, 
	"NEUTRAL" NUMBER(1,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Index SYS_C00194482
--------------------------------------------------------

  CREATE UNIQUE INDEX "KARKULOWSKIT"."SYS_C00194482" ON "KARKULOWSKIT"."GAME" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  Constraints for Table GAME
--------------------------------------------------------

  ALTER TABLE "KARKULOWSKIT"."GAME" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "KARKULOWSKIT"."GAME" MODIFY ("GAME_DATE" NOT NULL ENABLE);
  ALTER TABLE "KARKULOWSKIT"."GAME" ADD PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table GAME
--------------------------------------------------------

  ALTER TABLE "KARKULOWSKIT"."GAME" ADD FOREIGN KEY ("HOME_TEAM_ID")
	  REFERENCES "KARKULOWSKIT"."TEAM" ("ID") ENABLE;
  ALTER TABLE "KARKULOWSKIT"."GAME" ADD FOREIGN KEY ("AWAY_TEAM_ID")
	  REFERENCES "KARKULOWSKIT"."TEAM" ("ID") ENABLE;
  ALTER TABLE "KARKULOWSKIT"."GAME" ADD FOREIGN KEY ("TOURNAMENT_ID")
	  REFERENCES "KARKULOWSKIT"."TOURNAMENT" ("ID") ENABLE;
  ALTER TABLE "KARKULOWSKIT"."GAME" ADD FOREIGN KEY ("CITY_ID")
	  REFERENCES "KARKULOWSKIT"."CITY" ("ID") ENABLE;
  ALTER TABLE "KARKULOWSKIT"."GAME" ADD FOREIGN KEY ("COUNTRY_ID")
	  REFERENCES "KARKULOWSKIT"."COUNTRY" ("ID") ENABLE;
