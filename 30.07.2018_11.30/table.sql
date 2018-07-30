CREATE TABLE STUDENT4.CARTS
(
  ID_LINE   NUMBER                              NOT NULL,
  ID_ORDER  NUMBER                              NOT NULL,
  ID_THING  NUMBER                              NOT NULL,
  DEL_DATE  DATE                                DEFAULT NULL,
  DEL_USER  VARCHAR2(200 CHAR)                  DEFAULT NULL
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


--  There is no statement for index STUDENT4.SYS_C0082781.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER STUDENT4.CARTS_ID_TRG
before insert ON STUDENT4.CARTS
for each row
begin
  if :new.ID_LINE is null then
    select CARTS_seq.nextval into :new.ID_LINE from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.CARTS ADD (
  PRIMARY KEY
  (ID_LINE)
  USING INDEX
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE)
/

ALTER TABLE STUDENT4.CARTS ADD (
  CONSTRAINT CARTS_FK_1 
  FOREIGN KEY (ID_ORDER) 
  REFERENCES STUDENT4.ORDERS (ID_ORDER)
  ENABLE VALIDATE,
  CONSTRAINT CARTS_FK_2 
  FOREIGN KEY (ID_THING) 
  REFERENCES STUDENT4.THINGS (ID_THING)
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.CITY
(
  ID_CITY    NUMBER,
  NAME_CITY  VARCHAR2(200 CHAR)
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


CREATE UNIQUE INDEX STUDENT4.CITY_PK ON STUDENT4.CITY
(ID_CITY)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
/

CREATE OR REPLACE TRIGGER STUDENT4.CITY_ID_TRG
before insert ON STUDENT4.CITY
for each row
begin
  if :new.ID_CITY is null then
    select CITY_seq.nextval into :new.ID_CITY from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.CITY ADD (
  CONSTRAINT CITY_PK
  PRIMARY KEY
  (ID_CITY)
  USING INDEX STUDENT4.CITY_PK
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.CUSTOMERS
(
  ID_USER              NUMBER                   NOT NULL,
  ADRESS_CUSTOMER      VARCHAR2(60 BYTE)        NOT NULL,
  TELEFON_CUSTOMER     VARCHAR2(60 BYTE)        NOT NULL,
  SURNAME_CUSTOMER     VARCHAR2(200 CHAR),
  NAME_CUSTOMER        VARCHAR2(200 CHAR),
  PATRONYMIC_CUSTOMER  VARCHAR2(200 CHAR),
  DEL_DATE             DATE                     DEFAULT NULL,
  DEL_USER             VARCHAR2(200 CHAR)       DEFAULT NULL,
  CITY_CUSTOMER        NUMBER
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


CREATE UNIQUE INDEX STUDENT4.CUSTOMERS_PK ON STUDENT4.CUSTOMERS
(ID_USER)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
/

CREATE OR REPLACE TRIGGER STUDENT4.CUSTOMERS_ID_TRG
before insert ON STUDENT4.CUSTOMERS
for each row
DISABLE
begin
  if :new.ID_CUSTOMER is null then
    select CUSTOMERS_seq.nextval into :new.ID_CUSTOMER from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.CUSTOMERS ADD (
  CONSTRAINT CUSTOMERS_PK
  PRIMARY KEY
  (ID_USER)
  USING INDEX STUDENT4.CUSTOMERS_PK
  ENABLE VALIDATE)
/

ALTER TABLE STUDENT4.CUSTOMERS ADD (
  CONSTRAINT CUSTOMERS_FK_1 
  FOREIGN KEY (ID_USER) 
  REFERENCES STUDENT4.USERS (ID_USER)
  ENABLE VALIDATE,
  CONSTRAINT CUSTOMERS_FK_2 
  FOREIGN KEY (CITY_CUSTOMER) 
  REFERENCES STUDENT4.CITY (ID_CITY)
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.DELIVERY
(
  ID_DELIVERY  NUMBER                           NOT NULL,
  ID_ORDER     NUMBER                           NOT NULL,
  DEL_USER     VARCHAR2(200 BYTE)               DEFAULT NULL,
  DEL_DATE     DATE                             DEFAULT NULL
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


--  There is no statement for index STUDENT4.SYS_C0082782.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER STUDENT4.DELIVERY_ID_TRG
before insert ON STUDENT4.DELIVERY
for each row
begin
  if :new.ID_DELIVERY is null then
    select DELIVERY_seq.nextval into :new.ID_DELIVERY from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.DELIVERY ADD (
  PRIMARY KEY
  (ID_DELIVERY)
  USING INDEX
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE)
/

ALTER TABLE STUDENT4.DELIVERY ADD (
  CONSTRAINT DELIVERY_FK_1 
  FOREIGN KEY (ID_ORDER) 
  REFERENCES STUDENT4.ORDERS (ID_ORDER)
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.ORDERS
(
  ID_ORDER      NUMBER                          NOT NULL,
  ID_USER       NUMBER                          NOT NULL,
  STATUS_ORDER  VARCHAR2(45 BYTE)               NOT NULL,
  DEL_DATE      DATE                            DEFAULT NULL,
  DEL_USER      VARCHAR2(200 CHAR)              DEFAULT NULL,
  ID_WAREHOUSE  NUMBER                          DEFAULT null
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


--  There is no statement for index STUDENT4.SYS_C0082779.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER STUDENT4.ORDERS_ID_TRG
before insert ON STUDENT4.ORDERS
for each row
begin
  if :new.ID_ORDER is null then
    select ORDERS_seq.nextval into :new.ID_ORDER from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.ORDERS ADD (
  PRIMARY KEY
  (ID_ORDER)
  USING INDEX
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE)
/

ALTER TABLE STUDENT4.ORDERS ADD (
  CONSTRAINT ORDER_FK_2 
  FOREIGN KEY (ID_WAREHOUSE) 
  REFERENCES STUDENT4.WAREHOUSES (ID_WAREHOUSE)
  ENABLE VALIDATE,
  CONSTRAINT ORDERS_FK 
  FOREIGN KEY (ID_USER) 
  REFERENCES STUDENT4.USERS (ID_USER)
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.REMNANTS
(
  ID_REMAINDER  NUMBER                          NOT NULL,
  ID_THING      NUMBER                          NOT NULL,
  ID_WAREHOUSE  NUMBER                          NOT NULL,
  QUANTITY      NUMBER                          NOT NULL,
  DEL_DATE      DATE                            DEFAULT NULL,
  DEL_USER      VARCHAR2(200 CHAR)              DEFAULT NULL
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


--  There is no statement for index STUDENT4.SYS_C0082780.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER STUDENT4.REMNANTS_ID_TRG
before insert ON STUDENT4.REMNANTS
for each row
begin
  if :new.ID_REMAINDER is null then
    select REMNANTS_seq.nextval into :new.ID_REMAINDER from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.REMNANTS ADD (
  PRIMARY KEY
  (ID_REMAINDER)
  USING INDEX
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE)
/

ALTER TABLE STUDENT4.REMNANTS ADD (
  CONSTRAINT REMNANTS_FK_1 
  FOREIGN KEY (ID_THING) 
  REFERENCES STUDENT4.THINGS (ID_THING)
  ENABLE VALIDATE,
  CONSTRAINT REMNANTS_FK_2 
  FOREIGN KEY (ID_WAREHOUSE) 
  REFERENCES STUDENT4.WAREHOUSES (ID_WAREHOUSE)
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.THINGS
(
  ID_THING     NUMBER                           NOT NULL,
  NAME_THING   VARCHAR2(45 BYTE)                NOT NULL,
  PRICE_THING  NUMBER                           NOT NULL,
  DEL_USER     VARCHAR2(200 CHAR)               DEFAULT NULL,
  DEL_DATE     DATE                             DEFAULT NULL
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


--  There is no statement for index STUDENT4.SYS_C0082775.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER STUDENT4.THINGS_ID_TRG
before insert ON STUDENT4.THINGS
for each row
begin
  if :new.ID_THING is null then
    select THINGS_seq.nextval into :new.ID_THING from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.THINGS ADD (
  PRIMARY KEY
  (ID_THING)
  USING INDEX
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.USERS
(
  ID_USER    NUMBER                             NOT NULL,
  NAME_USER  VARCHAR2(45 BYTE)                  NOT NULL,
  PASS_USER  VARCHAR2(45 BYTE)                  NOT NULL,
  DEL_USER   VARCHAR2(200 BYTE)                 DEFAULT NULL,
  DEL_DATE   DATE
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


--  There is no statement for index STUDENT4.SYS_C0082776.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER STUDENT4.USERS_ID_TRG
before insert ON STUDENT4.USERS
for each row
begin
  if :new.ID_USER is null then
    select USERS_seq.nextval into :new.ID_USER from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.USERS ADD (
  PRIMARY KEY
  (ID_USER)
  USING INDEX
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE)
/
CREATE TABLE STUDENT4.WAREHOUSES
(
  ID_WAREHOUSE      NUMBER                      NOT NULL,
  ADRESS_WAREHOUSE  VARCHAR2(70 BYTE)           NOT NULL,
  CITY_WAREHOUSE    NUMBER,
  DEL_DATE          DATE                        DEFAULT NULL,
  DEL_USER          VARCHAR2(200 CHAR)          DEFAULT NULL
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING
/


--  There is no statement for index STUDENT4.SYS_C0082777.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER STUDENT4.WAREHOUSES_ID_TRG
before insert ON STUDENT4.WAREHOUSES
for each row
begin
  if :new.ID_WAREHOUSE is null then
    select WAREHOUSES_seq.nextval into :new.ID_WAREHOUSE from dual;
  end if;
end;
/


ALTER TABLE STUDENT4.WAREHOUSES ADD (
  PRIMARY KEY
  (ID_WAREHOUSE)
  USING INDEX
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE)
/

ALTER TABLE STUDENT4.WAREHOUSES ADD (
  CONSTRAINT WAREHOUSES_FK 
  FOREIGN KEY (CITY_WAREHOUSE) 
  REFERENCES STUDENT4.CITY (ID_CITY)
  ENABLE VALIDATE)
/
