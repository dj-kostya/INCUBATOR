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
  Select count(o.ID_order)
  into  v_COU_USER
    from ORDERS o
    join USERS u
    on o.id_user=u.id_user
    where u.id_user=p_id;
  if v_COU_USER > 0 then
    Select o.ID_order 
    into v_order_
from ORDERS o
join USERS u
on o.id_user=u.id_user
where u.id_user=p_id;
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


BEGIN
   SELECT COUNT(ID_USER) into v_COU_USER from USERS where id_user=P_ID_USER;
  if v_COU_USER > 0 then
    update CUSTOMERS 
    set DEl_date=sysdate,
    DEL_USER=NVL(P_WHO_DEL,'UNKNOWN')
    where id_user=P_ID_USER;
    
    update (select d.DEL_USER,d.DEL_DATE from DELIVERY d
    join ORDERS o 
    on d.ID_ORDER=o.ID_ORDER 
    where o.ID_USER=p_ID_USER and d.DEL_DATE is null) 
    set DEl_date=sysdate,
    DEL_USER=NVL(P_WHO_DEL,'UNKNOWN');
    
    update (select d.DEL_USER,d.DEL_DATE from CARTS d
    join ORDERS o on d.ID_ORDER=o.ID_ORDER where o.ID_USER=p_ID_USER and d.DEL_DATE is null) 
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
    select id_warehouse,id_thing, quantity from Remnants where quantity < p_quantity and del_date is null;
END get_quantity_3_4_2;
/
CREATE OR REPLACE PROCEDURE STUDENT4.GET_delivery_3_4_1 
(
p_out_ref_cursor OUT sys_refcursor
)
IS


BEGIN
   open p_out_ref_cursor for
   select o.ID_ORDER,c.id_warehouse,c.id_thing
   FROM ORDERS o
   join Delivery d
   on d.id_order = o.ID_ORDER 
   join CARTS c
   on c.id_order=o.id_order
   where o.del_date is null and d.del_date is null  and d.ID_DELIVERY is not null and c.id_warehouse is not null
   order by c.id_warehouse;
   
END ;
/
CREATE OR REPLACE PROCEDURE STUDENT4.GET_delivery_3_4_1_JSON
(
p_OUTPUT_CLOB OUT clob
)
IS
/*
[
{
"id_warehouse":1
,"adress_warehouse":"TEST_ADRESS"
,"city_warehouse":"KEM"
,"ORDERS":[
{
"ORDER":1
,"CITY":"KEM"
,"ADRESS":"2"
,"SURNAME":"3"
,"NAME":"3"
,"PATRONYMIC":"4"
,"TELEFON":"2"
,"ORDER":[
{
"ID_THING":3
,"NAME_THING":"TEST_NAME"
}
]
}
,{
"ORDER":2
,"CITY":"KEM"
,"ADRESS":"123"
,"SURNAME":"123"
,"NAME":"123"
,"PATRONYMIC":"12"
,"TELEFON":"123"
,"ORDER":[
{
"ID_THING":4
,"NAME_THING":"TEST_NAME_2"
}
]
}
]
}
,{
"id_warehouse":2
,"adress_warehouse":"trsr"
,"city_warehouse":"KEM"
,"ORDERS":[
{
"ORDER":1
,"CITY":"KEM"
,"ADRESS":"2"
,"SURNAME":"3"
,"NAME":"3"
,"PATRONYMIC":"4"
,"TELEFON":"2"
,"ORDER":[
{
"ID_THING":1
,"NAME_THING":"TEST"
}
]
}
]
}
]


*/
v_city varchar2(200);
v_adress varchar2(200);
BEGIN
    apex_json.free_output;
    apex_json.initialize_clob_output;
    apex_json.open_array();
    for i in(select DISTINCT c.id_warehouse
   FROM ORDERS o
   join Delivery d
   on d.id_order = o.ID_ORDER 
   join CARTS c
   on c.id_order=o.id_order
   
   where o.del_date is null and d.del_date is null  and d.ID_DELIVERY is not null and c.id_warehouse is not null)
   loop
        select adress_warehouse, c.NAME_CITY 
        into v_adress,v_city
        from warehouses w
        join city c
        on c.id_city=w.city_warehouse
        where id_warehouse=i.id_warehouse and del_date is null;
        apex_json.open_object('');
        apex_json.write('id_warehouse',i.id_warehouse);
        apex_json.write('adress_warehouse',v_adress);
        apex_json.write('city_warehouse',v_city);
        apex_json.open_array('ORDERS');
        
       for j in(select distinct o.ID_ORDER, u.ADRESS_CUSTOMER,u.TELEFON_CUSTOMER,u.NAME_CUSTOMER,u.SURNAME_CUSTOMER,u.PATRONYMIC_CUSTOMER,g.NAME_CITY--,c.id_thing
       FROM ORDERS o
       join Delivery d
       on d.id_order = o.ID_ORDER 
       join CARTS c
       on c.id_order=o.id_order
       join CUSTOMERS u
       on u.id_user=o.id_user
       join city g
       on g.id_city=u.CITY_CUSTOMER
       where o.del_date is null and d.del_date is null and u.del_date is null  and d.ID_DELIVERY is not null and c.id_warehouse is not null and c.id_warehouse=i.id_warehouse)
       loop
        apex_json.open_object(); 
        apex_json.write('ORDER',j.ID_ORDER);  
        apex_json.write('CITY',j.NAME_CITY);  
        apex_json.write('ADRESS',j.ADRESS_CUSTOMER);  
        apex_json.write('SURNAME',j.SURNAME_CUSTOMER); 
        apex_json.write('NAME',j.NAME_CUSTOMER); 
        apex_json.write('PATRONYMIC',j.PATRONYMIC_CUSTOMER); 
        apex_json.write('TELEFON',j.TELEFON_CUSTOMER); 
        apex_json.open_array('ORDER');  
        for f in (select c.id_thing,t.NAME_THING
       FROM ORDERS o
       join Delivery d
       on d.id_order = o.ID_ORDER 
       join CARTS c
       on c.id_order=o.id_order
       join things t
       on c.id_thing=t.id_thing
       where o.del_date is null and d.del_date is null and c.del_date is null  and d.ID_DELIVERY is not null and c.id_warehouse is not null and c.id_warehouse=i.id_warehouse and o.ID_ORDER= j.id_order)
         loop
            apex_json.open_object(); 
            apex_json.write('ID_THING',f.id_thing); 
            apex_json.write('NAME_THING',f.NAME_THING); 
            apex_json.close_object();
         end loop;
        apex_json.close_array(); 
        apex_json.close_object();
       end loop;
       apex_json.close_array();
       apex_json.close_object();
   end loop;
   apex_json.close_array();
   p_OUTPUT_CLOB := apex_json.get_clob_output;
   apex_json.free_output;
END ;
/
CREATE OR REPLACE PROCEDURE STUDENT4."GET_ORDERS_3_2_6_JSON" 
(
p_id_usr number,
p_cart OUT clob,
p_status OUT number
) 
AS --0 -все хорошо 1 - пользователь не найден
v_user varchar2(200);
BEGIN
    apex_json.free_output;
    apex_json.initialize_clob_output;
    apex_json.open_object();
    apex_json.write('USER',p_id_usr);
    select NAME_USER into v_user from USERS where id_user=p_id_usr and del_date is null;
    apex_json.write('NAME',v_user);
    apex_json.open_array('ORDERS');
    for i in (select ID_ORDER from ORDERS where id_user = p_id_usr )
    loop
        apex_json.open_object();
        apex_json.write('ORDER',i.ID_ORDER);
        apex_json.open_array('THING');
        for j in (select t.NAME_thing,t.PRICE_THING
                from THINGS t
                join carts c 
                on t.id_thing= c.id_thing
                where c.id_order=i.ID_ORDER and c.del_date is null and t.del_date is null)
        loop
            apex_json.open_object();
            apex_json.write('NAME',j.NAME_thing);
            apex_json.write('PRICE',j.PRICE_THING);
            apex_json.close_object();
        end loop;
        apex_json.close_array();
        apex_json.close_object();
    end loop;
    apex_json.close_array();
    apex_json.close_object();
    p_cart := apex_json.get_clob_output;
    apex_json.free_output;
    p_status:=0;
 exception 
 WHEN NO_DATA_FOUND THEN  p_status:=1;
 
  
END ;
/
CREATE OR REPLACE PROCEDURE STUDENT4."GET_THING_3_1_1_JSON" 
(
 p_table OUT clob
)
is   
BEGIN
    apex_json.free_output;
    apex_json.initialize_clob_output;
    apex_json.open_object();
    apex_json.open_array('THINGS');
    for i in (select id_thing,NAME_THING,PRICE_THING from THINGS where DEL_DATE is null)
    loop 
        apex_json.open_object();
        apex_json.write('NAME',i.NAME_THING);
        apex_json.write('PRICE',i.PRICE_THING);
        apex_json.open_array('QUANTITY');
        for j in (select r.QUANTITY,w.ADRESS_WAREHOUSE,c.NAME_CITY
        from REMNANTS r
        join WAREHOUSES w
        on w.ID_WAREHOUSE=r.ID_WAREHOUSE
        join city c
        on c.ID_CITY = w.CITY_WAREHOUSE
        where r.ID_THING=i.id_thing)
        loop
          apex_json.open_object();
          apex_json.write('CITY',j.NAME_CITY);
          apex_json.write('ADRESS',j.ADRESS_WAREHOUSE);
          apex_json.write('QUANTITY',j.QUANTITY);
          apex_json.close_object();  
        end loop;
        apex_json.close_array();
        apex_json.close_object();
    end loop;
    apex_json.close_array();
    apex_json.close_object();
    
    p_table := apex_json.get_clob_output;
   apex_json.free_output;
END;
/
CREATE OR REPLACE PROCEDURE STUDENT4.get_quantity_3_4_2_JSON
(
p_quantity number,
p_table out clob

)
 IS


BEGIN
  apex_json.free_output;
    apex_json.initialize_clob_output;
    apex_json.open_object();
    apex_json.open_array('THINGS');
    for i in (select distinct t.id_thing,t.NAME_THING,t.PRICE_THING from THINGS t join REMNANTS r on r.ID_THING = t.ID_THING where t.DEL_DATE is null and r.DEL_DATE is null and r.QUANTITY<p_quantity)
    loop 
        apex_json.open_object();
        apex_json.write('NAME',i.NAME_THING);
        apex_json.write('PRICE',i.PRICE_THING);
        apex_json.open_array('QUANTITY');
        for j in (select r.QUANTITY,w.ADRESS_WAREHOUSE,c.NAME_CITY
        from REMNANTS r
        join WAREHOUSES w
        on w.ID_WAREHOUSE=r.ID_WAREHOUSE
        join city c
        on c.ID_CITY = w.CITY_WAREHOUSE
        where r.ID_THING=i.id_thing and w.DEL_DATE is null and r.DEL_DATE is null and r.QUANTITY<p_quantity)
        loop
          apex_json.open_object();
          apex_json.write('CITY',j.NAME_CITY);
          apex_json.write('ADRESS',j.ADRESS_WAREHOUSE);
          apex_json.write('QUANTITY',j.QUANTITY);
          apex_json.close_object();  
        end loop;
        apex_json.close_array();
        apex_json.close_object();
    end loop;
    apex_json.close_array();
    apex_json.close_object();
    
    p_table := apex_json.get_clob_output;
   apex_json.free_output;
END ;
/
