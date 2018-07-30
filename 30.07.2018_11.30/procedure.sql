CREATE OR REPLACE PROCEDURE STUDENT4.TRANS_FROM_WAREHOUSE_3_3_3 
(
P_WAREHOUSE_IN NUMBER,
P_WAREHOUSE_OUT NUMBER,
P_THING NUMBER,
p_quantity number,
P_STATUS OUT NUMBER -- 0-все хорошо 1- не сработало(
)
IS
v_quantity_in NUMBER;

BEGIN

   SELECT QUANTITY 
    INTO    
        v_quantity_in 
    FROM 
        REMNANTS 
    where 
        id_thing=p_thing and del_date is null and id_warehouse = p_warehouse_in;
    if v_quantity_in < p_quantity then p_status:=1;
    else 
    
    update 
        REMNANTS
    set 
        QUANTITY=QUANTITY-p_quantity
    where 
        id_thing=p_thing and del_date is null and id_warehouse = p_warehouse_in;
         
    merge into REMNANTS r
    using dual d
    on (r.id_thing=p_thing and r.id_warehouse=P_WAREHOUSE_OUT and r.DEL_DATE is null)
    when matched then 
    update set r.Quantity = r.Quantity+p_quantity
    when not matched then 
    INSERT (id_thing,id_warehouse,quantity) values(p_thing,p_warehouse_out,p_quantity);
    p_status:=0;
    end if;    
END TRANS_FROM_WAREHOUSE_3_3_3;
/
CREATE OR REPLACE PROCEDURE STUDENT4.predict_3_5 
(

 p_id_thing number,
 p_id_order number,
 p_return_curs OUT sys_refcursor,
 p_status OUT number
)
IS

BEGIN
   open p_return_curs for 
   select 
    id_thing  
   from 
    Carts 
   where 
    id_order = 
    (select 
        id_order 
     from 
        carts 
     where 
        id_thing = p_id_thing and id_order <> p_id_order and del_date is null) 
    and id_thing <> p_id_thing and del_date is null;
    p_status:=0;
END predict_3_5;
/
CREATE OR REPLACE PROCEDURE STUDENT4."ADD_DELIVERY_3_2_5" (
    p_SURNAME    IN     VARCHAR2,
    p_NAME       IN     VARCHAR2,
    p_PATRONYMIC IN     VARCHAR2,
    p_ADRESS     IN     VARCHAR2,
    p_TELEFON    IN     VARCHAR2,
    p_ID_ORDER   IN     NUMBER,
    p_CITY       IN     NUMBER,
    p_STATUS        OUT NUMBER)
AS     --0 все хорошо 1 - не найден заказ 2 - Данные обновлены 3 - пустые параметры
    v_id_ord_cou    NUMBER;
    v_id_us         NUMBER;
    v_id_us_count   NUMBER;
    
BEGIN
    if p_SURNAME is NULL and p_NAME is NULL and p_PATRONYMIC is NULL and p_ADRESS is NULL and p_TELEFON is NULL and p_CITY is NULL then p_status:=3;
    else
        SELECT COUNT (ID_ORDER) -- существует ли такой заказ
          INTO v_id_ord_cou
          FROM ORDERS
         WHERE ORDERS.ID_ORDER = p_ID_ORDER;

        IF v_id_ord_cou > 0
        THEN
            SELECT ID_USER
              INTO v_id_us
              FROM ORDERS
             WHERE ORDERS.ID_ORDER = p_ID_ORDER;

            INSERT INTO delivery (ID_ORDER)
                 VALUES (p_ID_ORDER);

            SELECT COUNT (ID_USER)
              INTO v_id_us_count
              FROM CUSTOMERS
             WHERE CUSTOMERS.ID_USER = v_id_us;

            IF v_id_us_count = 0
            THEN
                INSERT INTO CUSTOMERS (ID_USER,
                                      SURNAME_CUSTOMER,
                                      NAME_CUSTOMER,
                                      PATRONYMIC_CUSTOMER,
                                      CITY_CUSTOMER,
                                      ADRESS_CUSTOMER,
                                      TELEFON_CUSTOMER)
                    VALUES (v_id_us,
                             p_SURNAME,p_NAME,p_PATRONYMIC,p_CITY,p_ADRESS,p_TELEFON);

                p_status := 0;
            ELSE
               UPDATE CUSTOMERS
               set        
                ADRESS_CUSTOMER=CASE when p_ADRESS is null then ADRESS_CUSTOMER else p_ADRESS end,/*(SELECT ADRESS_CUSTOMER FROM CUSTOMERS WHERE CUSTOMERS.ID_USER = v_id_us)*/ 
                TELEFON_CUSTOMER=CASE when p_TELEFON is null then TELEFON_CUSTOMER else p_TELEFON end,
                SURNAME_CUSTOMER=CASE when p_SURNAME is null then SURNAME_CUSTOMER else p_SURNAME end,
                NAME_CUSTOMER=CASE when p_NAME is null then NAME_CUSTOMER else p_NAME end,
                PATRONYMIC_CUSTOMER=CASE when p_PATRONYMIC is null then PATRONYMIC_CUSTOMER else p_PATRONYMIC end,
                CITY_CUSTOMER=CASE when p_CITY is null then CITY_CUSTOMER else p_CITY end,        
                DEL_DATE = null,
                DEL_USER = null
               WHERE CUSTOMERS.ID_USER = v_id_us; 
               
               p_status:=2;
            END IF;
            COMMIT;
        ELSE
            p_status := 1;
        END IF;
    END IF;
END ADD_DELIVERY_3_2_5;
/
CREATE OR REPLACE PROCEDURE STUDENT4."ADD_THING_TO_CART_3_2_4_1" ( p_ID IN NUMBER ,p_thing IN NUMBER , p_STATUS OUT NUMBER ) AS --0 -все хорошо, 1 -- не найден пользователь 2 -- такой уже есть
V_COU_USER number;
v_order_ number;
v_count_line number;
BEGIN
  Select  count(orders.ID_order) into v_COU_USER from ORDERS ,customers where customers.id_user=p_id;
  if v_COU_USER > 0 then
    Select  orders.ID_order into v_order_ from ORDERS ,customers where customers.id_user=p_id;
    select count(id_line) into v_count_line from carts where id_order=v_order_ and id_thing=p_thing;
    if v_count_line = 0 then
        insert into carts (id_order,id_thing) values(v_order_,p_thing);
        commit;
        p_status:=0;
    else 
        p_status:=2;
    end if;
  else
    p_status:=1;
    end if;
END ADD_THING_TO_CART_3_2_4_1;
/
CREATE OR REPLACE PROCEDURE STUDENT4."ADD_THING_3_1_2" (  p_NAME IN VARCHAR2, p_PRICE IN NUMBER) AS 
BEGIN
/*
 INSERT INTO THINGS
    ("NAME_THING", "PRICE_THING")
    VALUES
    (NAME, PRICE);*/
    Merge into things t
    using dual 
    ON (t.NAME_THING=p_name)
    when MATCHED then UPDATE set t.PRICE_THING=p_PRICE
    when NOT MATCHED then INSERT ("NAME_THING", "PRICE_THING")  
    VALUES
    (p_NAME, p_PRICE);
COMMIT;
END ;
/
CREATE OR REPLACE PROCEDURE STUDENT4."ADD_WAREHOUSE_3_3_1" 
(
p_city number,
p_adress varchar2,
p_status OUT number -- 0- хорошо 1-не найден город 2- адресс не известен
)
IS
v_count_city NUMBER;

BEGIN
   select count(id_city) into v_count_city from city where Id_city=p_city;
   if v_count_city>0 then
   INSERT INTO WAREHOUSES(ADRESS_WAREHOUSE,CITY_WAREHOUSE) values(NVL(p_adress,'UNKNOWN'),p_city);
   p_status:=0;
   commit;
   if p_adress is null then p_status:=2;
   end if;
   else
   p_status:=1;
   end if;
END;
/
CREATE OR REPLACE PROCEDURE STUDENT4."DELETE_THING_3_1_4" 
( 
    p_ID IN NUMBER,
    p_WHO_DEL IN VARCHAR2,
    p_status out number -- 0- все хорошо 1 - id не найден 2- не задан параметр "удаляющего"
    
) 
AS 
v_id_count number;
v_date date;
v_del_user varchar2(200);
BEGIN
  SELECT count (ID_THING) into v_id_count from THINGS where ID_THING=p_ID and DEL_DATE is NULL;
  if v_id_count>0 then
    v_date:=sysdate;
    v_del_user:=case when p_who_del is not null then p_who_del  else 'UNKNOWN' end;
    UPDATE REMNANTS 
        SET DEL_DATE=v_date,
        DEL_USER=v_del_user
    where ID_THING=p_ID and DEL_DATE is NULL;  
    
    UPDATE CARTS 
        SET DEL_DATE=v_date,
        DEL_USER=v_del_user
    where ID_THING=p_ID and DEL_DATE is NULL;
    
    UPDATE THINGS 
        SET DEL_DATE=v_date,
        DEL_USER=v_del_user
    where ID_THING=p_ID and DEL_DATE is NULL;
    
    if p_who_del is null then p_status:=2;
    else p_status:=0;
    end if;
    commit;
  else
  p_status:=1;
       end if;
  
END ;
/
CREATE OR REPLACE PROCEDURE STUDENT4."DEL_THING_FROM_CART_3_2_4_2" (  p_ORDER_ IN NUMBER , p_THING IN NUMBER , p_STATUS OUT NUMBER,p_WHO_DEL in varchar2) AS --0 -все хорошо, 1 -- запись не найдена
v_THING_COU NUMBER;
v_date date;
v_who_del varchar2(200);
v_count_thing number;
BEGIN
 Select  count(ID_LINE) into v_THING_COU from CARTS  where ID_ORDER=P_order_ and id_thing=p_thing and DEL_DATE is null;
 if v_THING_COU>0 then
    v_date:=sysdate;
    v_who_del:=NVL(P_WHO_DEL,'UNKNOWN');
    UPDATE CARTS 
    set 
        DEL_DATE=v_date,
        DEL_USER=v_who_del
    where 
        ID_ORDER=P_order_ and id_thing=p_thing and DEL_DATE is null;
    
    SELECT count(ID_LINE) 
    into 
        v_count_thing 
    from 
        carts 
    where 
        ID_ORDER=P_ORDER_ and DEL_DATE is null;
        
    if v_count_thing = 0 then 
        update ORDERS 
        set 
        DEL_DATE=v_date,
        DEL_USER='auto'
        where ID_ORDER=P_order_ and del_date is null;
        update delivery 
        set 
        DEL_DATE=v_date,
        DEL_USER='auto'
        where ID_ORDER=P_order_ and del_date is null;
    end if;
 end if;
END DEL_THING_FROM_CART_3_2_4_2;
/
CREATE OR REPLACE PROCEDURE STUDENT4."DEL_USER_3_2_3" 
( 
 P_ID_USER IN NUMBER , 
 P_WHO_DEL IN varchar2 , 
 p_STATUS OUT NUMBER --0 -все хорошо, 1 -- не найден пользователь 2 - не задан удаляющий 
 ) 
AS 
V_COU_USER number;
v_DATE date;

BEGIN
   SELECT COUNT(ID_USER) into v_COU_USER from USERS where id_user=P_ID_USER;
  if v_COU_USER > 0 then
    update CUSTOMERS 
    set DEl_date=sysdate,
    DEL_USER=NVL(P_WHO_DEL,'UNKNOWN')
    where id_user=P_ID_USER;
    
    update (select d.DEL_USER,d.DEL_DATE from DELIVERY d
    left join ORDERS o 
    on d.ID_ORDER=o.ID_ORDER 
    where o.ID_USER=p_ID_USER and d.DEL_DATE is null) 
    set DEl_date=sysdate,
    DEL_USER=NVL(P_WHO_DEL,'UNKNOWN');
    
    update (select d.DEL_USER,d.DEL_DATE from CARTS d
    left join ORDERS o on d.ID_ORDER=o.ID_ORDER where o.ID_USER=p_ID_USER and d.DEL_DATE is null) 
    set DEl_date=sysdate,
    DEL_USER=NVL(P_WHO_DEL,'UNKNOWN');
    
    update ORDERS 
    set DEl_date=sysdate,
    DEL_USER=NVL(P_WHO_DEL,'UNKNOWN')
    where id_user=P_ID_USER; 
    commit;
    if P_WHO_DEL is null then
    p_status:=2;
    else 
    p_status:=0;
    end if;
    
    else
    p_status:=1;
    end if;
END DEL_USER_3_2_3;
/
CREATE OR REPLACE PROCEDURE STUDENT4."DEL_WAREHOUSE_3_3_1" 
(
p_id number,
p_WHO_DEL varchar2,
p_status OUT number -- 0- хорошо 1-не найден склад 2- удаляющий не известен
)
IS
v_count_ware NUMBER;
v_date date;
v_who varchar2(200);
BEGIN
   Select count (ID_WAREHOUSE) INTO v_count_ware FROM WAREHOUSES where p_id= ID_WAREHOUSE and DEL_DATE is null;
   if v_count_ware > 0 THEN 
    v_date:=sysdate;
    v_who:=NVL(p_WHO_DEL,'UNKNOWN');
    
       UPDATE WAREHOUSES 
       SET 
            DEL_date=v_date,
            del_USER=v_WHO
       where p_id= ID_WAREHOUSE and DEL_DATE is null;   
      commit;
      p_status:=0;
    if p_who_del is null then p_status:=2;
    end if;
   else
    p_status:=1;
   end if;
END;
/
CREATE OR REPLACE PROCEDURE STUDENT4."EDIT_THING_3_1_3" (
    p_ID          IN     NUMBER,
    p_NEW_NAME    IN     VARCHAR2,
    p_NEW_PRICE   IN     NUMBER,
    p_STATUS         OUT NUMBER)-- 0 - запись обновлена 1- запись не найдена 2- аргументы не заданы
AS
v_thin_cou number;
BEGIN
    if p_NEW_NAME IS NULL and p_NEW_PRICE IS NULL then
    p_status:=2;
    else
        SELECT count(ID_THING) INTO v_thin_cou FROM THINGS WHERE ID_THING=p_ID and DEL_DATE is null;
        if v_THIN_COU>0 then
        UPDATE THINGS
                    SET NAME_THING =
                           CASE
                               WHEN p_NEW_NAME IS NULL THEN NAME_THING
                               ELSE p_NEW_NAME
                           END,
                    PRICE_THING =
                           CASE
                               WHEN p_NEW_PRICE IS NULL THEN PRICE_THING
                               ELSE p_NEW_PRICE
                           END
        WHERE ID_THING=p_ID and DEL_DATE is null;    
                 COMMIT;
                p_status:=0;
            
            else
            p_status:=1;
         END IF;   
        end if;
END;
/
CREATE OR REPLACE PROCEDURE STUDENT4."EDIT_USER_3_2_2" (ID IN NUMBER , NEW_NAME IN VARCHAR2 , NEW_PASS IN VARCHAR2, STATUS OUT NUMBER ) AS --0 -все хорошо, 1 -- запись польщователя не найдена
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
CREATE OR REPLACE PROCEDURE STUDENT4."GET_ORDERS_3_2_6" 
(
p_id_usr number,
p_cart OUT SYS_REFCURSOR,
p_status OUT number
) 
AS --0 -все хорошо 1 - пользователь не найден
v_id_usr_count number;
BEGIN
  Select count(id_user) into v_id_usr_count  from orders where id_user=p_id_usr and DEL_date is null;
  if v_id_usr_count > 0 then
  OPEN p_cart FOR
  SELECT id_order from orders where id_user=p_id_usr and DEL_date is null;
  p_status:=0;
  else p_status:=1;
  end if;
END ;
/
CREATE OR REPLACE PROCEDURE STUDENT4."GET_THING_3_1_1" 
(
 p_table OUT SYS_REFCURSOR
)
is   
BEGIN
OPEN p_table FOR
select NAME_THING,PRICE_THING from THINGS where DEL_DATE is null;
END;
/
CREATE OR REPLACE PROCEDURE STUDENT4."LOG_IN_3_2_1" (  NAME IN VARCHAR2, PASSWORD IN VARCHAR2, STATUS OUT NUMBER ) AS --0 -все хорошо, 1 - пароль не верен 2-не найден пользователь
name_ VARCHAR2(50);
pass_ VARCHAR2(50);
BEGIN
  status:=2;
  select  count(pass_user) into name_ from USERS where name_user=NAME and DEL_DATE is NULL;
  if name_>0 then 
    select  pass_user into pass_ from USERS where name_user=NAME and DEL_DATE is NULL;
    if pass_=PASSWORD   
        then status:=0;
        else status:=1;
    end if;
  else status:=2;
  end if;
  
END;
/
CREATE OR REPLACE PROCEDURE STUDENT4.get_quantity_3_4_2
(
p_quantity number,
p_out_cursor out sys_refcursor

)
 IS


BEGIN
   open p_out_cursor for 
    select id_thing, quantity from Remnants where quantity < p_quantity and del_date is null;
END get_quantity_3_4_2;
/
CREATE OR REPLACE PROCEDURE STUDENT4.GET_delivery_3_4_1 
(
p_out_ref_cursor OUT sys_refcursor
)
IS


BEGIN
   open p_out_ref_cursor for
   select o.ID_ORDER,o.id_warehouse 
   FROM ORDERS o
   left join Delivery d
   on d.id_order = o.ID_ORDER
   where o.del_date is null and d.del_date is null  and d.ID_DELIVERY is not null
   group by id_warehouse;
   
END ;
/
