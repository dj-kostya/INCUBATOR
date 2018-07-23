CREATE TABLE USERS(
    ID_USER NUMBER NOT NULL ,
    NAME_USER varchar(45) NOT NULL, 
    PASS_USER varchar(45) NOT NULL,
    PRIMARY KEY (ID_USER)
);

CREATE SEQUENCE USERS_seq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

create or replace trigger USERS_id_trg
before insert on USERS
for each row
begin
  if :new.ID_USER is null then
    select USERS_seq.nextval into :new.ID_USER from dual;
  end if;
end;
/

CREATE TABLE CUSTOMERS(
    ID_CUSTOMER NUMBER NOT NULL ,
    ID_USER NUMBER NOT NULL ,
    FIO_CUSTOMER varchar(45) NOT NULL, 
    ADRESS_CUSTOMER varchar(60) NOT NULL,
    TELEFON_CUSTOMER varchar(60) NOT NULL,
    PRIMARY KEY (ID_CUSTOMER),
    CONSTRAINT CUSTOMERS_FK
        FOREIGN KEY (ID_USER)
        REFERENCES USERS(ID_USER)
);

CREATE SEQUENCE CUSTOMERS_seq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

create or replace trigger CUSTOMERS_id_trg
before insert on CUSTOMERS
for each row
begin
  if :new.ID_CUSTOMER is null then
    select CUSTOMERS_seq.nextval into :new.ID_CUSTOMER from dual;
  end if;
end;
/

CREATE TABLE ORDERS(
    ID_ORDER NUMBER NOT NULL ,
    ID_CUSTOMER NUMBER NOT NULL ,
    STATUS_ORDER varchar(45) NOT NULL, 
    PRIMARY KEY (ID_ORDER),
    CONSTRAINT ORDERS_FK
        FOREIGN KEY (ID_CUSTOMER)
        REFERENCES CUSTOMERS(ID_CUSTOMER)
);

CREATE SEQUENCE ORDERS_seq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

create or replace trigger ORDERS_id_trg
before insert on ORDERS
for each row
begin
  if :new.ID_ORDER is null then
    select ORDERS_seq.nextval into :new.ID_ORDER from dual;
  end if;
end;
/

CREATE TABLE WAREHOUSES(
    ID_WAREHOUSE NUMBER NOT NULL ,
    ADRESS_WAREHOUSE varchar(70) NOT NULL, 
    PRIMARY KEY (ID_WAREHOUSE)
);

CREATE SEQUENCE WAREHOUSES_seq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

create or replace trigger WAREHOUSES_id_trg
before insert on WAREHOUSES
for each row
begin
  if :new.ID_WAREHOUSE is null then
    select WAREHOUSES_seq.nextval into :new.ID_WAREHOUSE from dual;
  end if;
end;
/

CREATE TABLE THINGS(
    ID_THING NUMBER NOT NULL ,
    NAME_THING varchar(45) NOT NULL, 
    PRICE_THING NUMBER NOT NULL ,
    PRIMARY KEY (ID_THING)
);

CREATE SEQUENCE THINGS_seq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

create or replace trigger THINGS_id_trg
before insert on THINGS
for each row
begin
  if :new.ID_THING is null then
    select THINGS_seq.nextval into :new.ID_THING from dual;
  end if;
end;
/
CREATE TABLE REMNANTS(
    ID_REMAINDER NUMBER NOT NULL ,
    ID_THING NUMBER NOT NULL ,
    ID_WAREHOUSE NUMBER NOT NULL , 
    QUANTITY NUMBER NOT NULL ,
    PRIMARY KEY (ID_REMAINDER),
    CONSTRAINT REMNANTS_FK_1
        FOREIGN KEY (ID_THING)
        REFERENCES THINGS(ID_THING),
    CONSTRAINT REMNANTS_FK_2
        FOREIGN KEY (ID_WAREHOUSE)
        REFERENCES WAREHOUSES(ID_WAREHOUSE)
    
);

CREATE SEQUENCE REMNANTS_seq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

create or replace trigger REMNANTS_id_trg
before insert on REMNANTS
for each row
begin
  if :new.ID_REMAINDER is null then
    select REMNANTS_seq.nextval into :new.ID_REMAINDER from dual;
  end if;
end;
/

CREATE TABLE CARTS(
    ID_LINE NUMBER NOT NULL ,
    ID_ORDER NUMBER NOT NULL ,
    ID_THING NUMBER NOT NULL ,
    PRIMARY KEY (ID_LINE),
    CONSTRAINT CARTS_FK_1
        FOREIGN KEY (ID_ORDER)
        REFERENCES ORDERS(ID_ORDER)
    
);

CREATE SEQUENCE CARTS_seq
START WITH 1 
INCREMENT BY 1 
NOMAXVALUE;

create or replace trigger CARTS_id_trg
before insert on CARTS
for each row
begin
  if :new.ID_LINE is null then
    select CARTS_seq.nextval into :new.ID_LINE from dual;
  end if;
end;
/ 


