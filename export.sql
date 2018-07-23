--------------------------------------------------------
--  File created - Monday-July-23-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure ADD_DELIVERY_3_2_5
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."ADD_DELIVERY_3_2_5" (  FIO IN VARCHAR2, ADRESS IN VARCHAR2, TELEFON IN VARCHAR2, ID IN NUMBER , STATUS OUT NUMBER ) AS --0 все хорошо 1 - не найден пользователь
id_cou number;
BEGIN
  SELECT count(id_USER) into id_cou FROM customers where ID_USER=ID;
  if id_cou > 0 then 
    UPDATE customers SET FIO_customer=FIO , ADRESS_CUSTOMER=ADRESS, TELEFON_CUSTOMER=TELEFON where ID=ID_USER;
    status:=0;
    else 
    status:=1;
    end if;
END ADD_DELIVERY_3_2_5;

/
--------------------------------------------------------
--  DDL for Procedure ADD_THING_3_1_2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."ADD_THING_3_1_2" (  NAME IN VARCHAR2, PRICE IN NUMBER) AS 
BEGIN
 INSERT INTO THINGS
("NAME_THING", "PRICE_THING")
VALUES
(NAME, PRICE);
COMMIT;
END ;

/
--------------------------------------------------------
--  DDL for Procedure ADD_THING_TO_CART_3_2_4_1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."ADD_THING_TO_CART_3_2_4_1" ( ID IN NUMBER ,thing IN NUMBER , STATUS OUT NUMBER ) AS --0 -все хорошо, 1 -- не найден пользователь
COU_USER number;
order_ number;

BEGIN
  Select  count(orders.ID_order) into COU_USER from ORDERS ,customers where customers.ID_CUSTOMER=orders.id_customer and customers.id_user=id;
  if COU_USER > 0 then
    Select  orders.ID_order into order_ from ORDERS ,customers where customers.ID_CUSTOMER=orders.id_customer and customers.id_user=id;
    insert into carts (id_order,id_thing) values(order_,thing);
    commit;
    status:=0;
    
    else
    status:=1;
    end if;
END ADD_THING_TO_CART_3_2_4_1;

/
--------------------------------------------------------
--  DDL for Procedure DEL_USER_3_2_3
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."DEL_USER_3_2_3" (  ID IN NUMBER , STATUS OUT NUMBER ) AS --0 -все хорошо, 1 -- не найден пользователь
COU_USER number;
cust_ID number;
BEGIN
   SELECT COUNT(ID_USER) into COU_USER  from USERS where id_user=id;
  if COU_USER > 0 then
    DELETE USERS where id_user=id;
    Delete FROM(Select ORDERS.*,CARTS.* FROM ORDERS,CARTS,CUSTOMERS where carts.ID_order=ORDERS.ID_order and orders.id_customer=customers.ID_customer and customers.ID_user=id );
    DELETE CUSTOMERS where id_user=id;
    commit;
    status:=0;
    
    else
    status:=1;
    end if;
END DEL_USER_3_2_3;

/
--------------------------------------------------------
--  DDL for Procedure DELETE_THING_3_1_4
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."DELETE_THING_3_1_4" ( ID IN NUMBER) AS 
BEGIN
  delete from things where id_thing=id;
  delete from REMNANTS where id_thing=id;
  delete from CARTS where id_thing=id;
  commit;
END ;

/
--------------------------------------------------------
--  DDL for Procedure DELL_THING_FROM_CART_3_2_4_2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."DELL_THING_FROM_CART_3_2_4_2" (  ORDER_ IN NUMBER , THING IN NUMBER , STATUS OUT NUMBER ) AS --0 -все хорошо, 1 -- запись не найдена
THING_COU NUMBER;
BEGIN
 Select  count(ID_LINE) into THING_COU from CARTS  where ID_ORDER=order_ and id_thing=thing;
 if THING_COU>0 then
    delete from carts where ID_ORDER=order_ and id_thing=thing;
    status:=0;
    else
    status:=1;
    end if;
END DELL_THING_FROM_CART_3_2_4_2;

/
--------------------------------------------------------
--  DDL for Procedure EDIT_THING_3_1_3
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."EDIT_THING_3_1_3" ( ID IN NUMBER , NEW_NAME IN VARCHAR2 , NEW_PRICE IN NUMBER ) AS 
BEGIN
  UPDATE THINGS SET NAME_THING=NEW_NAME, PRICE_THING=NEW_PRICE where ID_THING=id;
  commit;
END;

/
--------------------------------------------------------
--  DDL for Procedure EDIT_USER_3_2_2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."EDIT_USER_3_2_2" (ID IN NUMBER , NEW_NAME IN VARCHAR2 , NEW_PASS IN VARCHAR2, STATUS OUT NUMBER ) AS --0 -все хорошо, 1 -- запись польщователя не найдена
COU_USER number;
BEGIN
    status:=1;
  SELECT COUNT(ID_USER) into COU_USER  from USERS where id_user=id;
  if COU_USER > 0 then
    UPDATE USERS SET NAME_USER=NEW_NAME, PASS_USER=NEW_PASS where id_user=id;
    commit;
    status:=0;
    
    else
    status:=1;
    end if;

END EDIT_USER_3_2_2;

/
--------------------------------------------------------
--  DDL for Procedure GET_THING_3_1_1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."GET_THING_3_1_1" 
is   
BEGIN
for rec in (select NAME_THING,PRICE_THING from THINGS) loop

  dbms_output.put_line('НАЗВАНИЕ ТОВАРА: ' || rec.NAME_THING||'  ЦЕНА: ' || rec.PRICE_THING);

end loop;

END;

/
--------------------------------------------------------
--  DDL for Procedure LOG_IN_3_2_1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "INCUBATOR"."LOG_IN_3_2_1" (  NAME IN VARCHAR2, PASSWORD IN VARCHAR2, STATUS OUT NUMBER ) AS --0 -все хорошо, 1 - пароль не верен 2-не найден пользователь
name_ VARCHAR2(50);
pass_ VARCHAR2(50);
BEGIN
  status:=2;
  select  count(pass_user) into name_ from USERS where name_user=NAME;
  if name_>0 then 
    select  pass_user into pass_ from USERS where name_user=NAME;
    if pass_=PASSWORD   
        then status:=0;
        else status:=1;
    end if;
  else status:=2;
  end if;
  
END;

/
