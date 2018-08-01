CREATE OR REPLACE PACKAGE BODY STUDENT4.THING_3_1
AS
    FUNCTION "GET_THING_3_1_1" (p_message OUT VARCHAR2, p_status OUT NUMBER)
        RETURN SYS_REFCURSOR
    IS
        v_return   SYS_REFCURSOR;
    BEGIN
        OPEN v_return FOR SELECT NAME_THING, PRICE_THING
                            FROM THINGS
                           WHERE DEL_DATE IS NULL;

        p_status := 0;
        p_message := 'ВСЕ ГУД';
        RETURN v_return;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            RETURN NULL;
    END;

    FUNCTION GET_THING_3_1_1_PIPE (p_message   OUT VARCHAR2,
                                   p_status    OUT NUMBER)
        RETURN t_THING_table
        PIPELINED
    AS
        v_rec   t_THING_record;
    BEGIN
        FOR i IN (SELECT id_thing, NAME_THING, PRICE_THING
                    FROM THINGS
                   WHERE DEL_DATE IS NULL)
        LOOP
            v_rec := t_THING_record (i.NAME_THING, i.id_thing, i.PRICE_THING);
            PIPE ROW (v_rec);
        END LOOP;

        p_status := 0;
        p_message := 'ВСЕ ГУД';
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            RETURN;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            RETURN;
    END;

    FUNCTION "GET_THING_3_1_1_JSON" (p_message   OUT VARCHAR2,
                                     p_status    OUT NUMBER)
        RETURN CLOB
    IS
        v_table          CLOB;
        v_sum_quantity   NUMBER;
    BEGIN
        apex_json.free_output;
        apex_json.initialize_clob_output;
        apex_json.open_object ();
        apex_json.open_array ('THINGS');

        FOR i IN (SELECT id_thing, NAME_THING, PRICE_THING
                    FROM THINGS
                   WHERE DEL_DATE IS NULL)
        LOOP
            apex_json.open_object ();
            apex_json.write ('Id', i.id_thing);
            apex_json.write ('NAME', i.NAME_THING);
            apex_json.write ('PRICE', i.PRICE_THING);
            v_sum_quantity := 0;

            SELECT SUM (quantity)
              INTO v_sum_quantity
              FROM remnants
             WHERE i.id_thing = id_thing AND DEL_DATE IS NULL;

            apex_json.write ('Quantity', NVL (v_sum_quantity, 0));
            apex_json.close_object ();
        END LOOP;

        apex_json.close_array ();
        apex_json.close_object ();

        v_table := apex_json.get_clob_output;
        apex_json.free_output;
        p_status := 0;
        p_message := 'ВСЕ ГУД';
        RETURN v_table;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_status := 1;
            p_message := 'Все товары удалены';
            RETURN NULL;
        WHEN OTHERS
        THEN
            p_status := 2;
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            RETURN NULL;
    END;


    FUNCTION "ADD_THING_3_1_2" (p_NAME      IN     VARCHAR2,
                                p_PRICE     IN     NUMBER,
                                p_message      OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        MERGE INTO things t
             USING DUAL
                ON (t.NAME_THING = p_name)
        WHEN MATCHED
        THEN
            UPDATE SET t.PRICE_THING = p_PRICE
        WHEN NOT MATCHED
        THEN
            INSERT     ("NAME_THING", "PRICE_THING")
                VALUES (p_NAME, p_PRICE);

        p_message := 'ВСЕ ГУД';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            RETURN 1;
    END;

    FUNCTION "EDIT_THING_3_1_3" (p_ID          IN     NUMBER,
                                 p_NEW_NAME    IN     VARCHAR2,
                                 p_NEW_PRICE   IN     NUMBER,
                                 p_message        OUT VARCHAR2) -- 0 - запись обновлена 1- запись не найдена 2- ВСЕ сломалось
        RETURN NUMBER
    AS
        v_thin_cou   NUMBER;
    BEGIN
        SELECT COUNT (ID_THING)
          INTO v_thin_cou
          FROM THINGS
         WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

        IF v_THIN_COU > 0
        THEN
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
             WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

            p_message := 'Все гуд';
            RETURN 0;
        ELSE
            p_message := 'Все записи удалены';
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            RETURN 2;
    END;

    FUNCTION "DELETE_THING_3_1_4" (p_ID        IN     NUMBER,
                                   p_WHO_DEL   IN     VARCHAR2,
                                   p_message      OUT VARCHAR2)
        RETURN NUMBER       -- 0- все хорошо 1 - id не найден 2- другая ошибка
    AS
        v_id_count   NUMBER;
        v_date       DATE;
        v_del_user   VARCHAR2 (200);
    BEGIN
        SELECT COUNT (ID_THING)
          INTO v_id_count
          FROM THINGS
         WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

        IF v_id_count > 0
        THEN
            v_date := SYSDATE;
            v_del_user :=
                CASE
                    WHEN p_who_del IS NOT NULL THEN p_who_del
                    ELSE 'UNKNOWN'
                END;

            UPDATE REMNANTS
               SET DEL_DATE = v_date, DEL_USER = v_del_user
             WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

            UPDATE CARTS
               SET DEL_DATE = v_date, DEL_USER = v_del_user
             WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

            UPDATE THINGS
               SET DEL_DATE = v_date, DEL_USER = v_del_user
             WHERE ID_THING = p_ID AND DEL_DATE IS NULL;

            p_message := 'ВСЕ ГУД';
            RETURN 0;
        ELSE
            p_message := 'Данный товар уже удален';
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_message :=
                   'Все сломалось сорри ( : '
                || TO_CHAR (SQLCODE)
                || ' - '
                || SQLERRM;
            RETURN 2;
    END;
END;
/
CREATE OR REPLACE PACKAGE BODY STUDENT4.USERS_3_2 AS

    FUNCTION "LOG_IN_3_2_1" 
    (  
        p_NAME IN VARCHAR2, 
        p_PASSWORD IN VARCHAR2, 
        p_message out varchar2
    )  return number
    AS --0 -все хорошо, 1 - пароль не верен 2-не найден пользователь
    v_name VARCHAR2(200);
    v_pass VARCHAR2(200);
    BEGIN      
      select  count(pass_user) into v_name from USERS where name_user=p_NAME and DEL_DATE is NULL;
      if v_name>0 then 
        select  pass_user into v_pass from USERS where name_user=p_NAME and DEL_DATE is NULL;
        if v_pass=p_PASSWORD   
            then 
            
            p_message:='ВСЕ ГУД';
            return 0;
            else 
            p_message:='Пароль неверен';
            return 1;
        end if;
      else 
      p_message:='Пользователь не существует';
      return 2;
      end if;
    exception
    when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 3;  
    END;
    
    FUNCTION "EDIT_USER_3_2_2" 
    (
        p_ID IN NUMBER , 
        p_NEW_NAME IN VARCHAR2 , 
        p_NEW_PASS IN VARCHAR2, 
        p_message out varchar2
    ) return number--0 -все хорошо, 1 -- запись польщователя не найдена
    AS 
    COU_USER number;
    BEGIN
        
      SELECT COUNT(ID_USER) into COU_USER  from USERS where id_user=p_ID;
      if COU_USER > 0 then
        UPDATE USERS SET NAME_USER=p_NEW_NAME, PASS_USER=p_NEW_PASS where id_user=p_ID;
        
        p_message:='ВСЕ ГУД';
        return 0;        
        else
        p_message:='Пользователь не существует';
        return 1;
        end if;
    exception
    when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 2; 
    END;
    
    FUNCTION "DEL_USER_3_2_3" 
    ( 
     P_ID_USER IN NUMBER , 
     P_WHO_DEL IN varchar2 , 
     p_message out varchar2 
     ) return number --0 -все хорошо, 1 -- не найден пользователь 2 - не задан удаляющий 
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
        
        
        p_message:='ВСЕ ГУД';
        return 0;
        else
        p_message:='Пользователь не существует';
        return 1;
        end if;
    exception
    when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 2;    
    END;
    
    FUNCTION "ADD_THING_TO_CART_3_2_4_1" 
    ( 
        p_ID IN NUMBER ,
        p_thing IN NUMBER , 
        p_message out varchar2 
    ) return number --0 -все хорошо, 1 -- не найден пользователь 2 -- такой уже есть
    AS 
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
                p_message:='ВСЕ ГУД';
                return 0;
            else 
                p_message:='Запись существует';
                return 2;
            end if;
        else
            p_message:='Пользователь не найден';
            return 1;
        end if;
        exception
        when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 3;
    END ;
    
    FUNCTION "DEL_THING_FROM_CART_3_2_4_2" 
    (  
        p_ORDER_ IN NUMBER , 
        p_THING IN NUMBER , 
        p_WHO_DEL in varchar2,
        p_message out varchar2 
    ) return number --0 -все хорошо, 1 -- запись не найдена
    AS 
    v_THING_COU NUMBER;
    v_date date;
    v_who_del varchar2(200);
    
    BEGIN
     Select  count(ID_LINE) into v_THING_COU from CARTS  where ID_ORDER=P_order_ and id_thing=p_thing and DEL_DATE is null;
     if v_THING_COU>0 then
        v_date:=sysdate;
        v_who_del:=P_WHO_DEL;
        UPDATE CARTS 
        set 
            DEL_DATE=v_date,
            DEL_USER=v_who_del
        where 
            ID_ORDER=P_order_ and id_thing= p_thing and DEL_DATE is null;
        p_message:='ВСЕ ГУД';
        return 0;
        /*SELECT count(ID_LINE) 
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
        end if;*/
        else
            p_message:='Заказ не найден';
            return 1;
        end if;
        exception
        when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 3;
    END;
    
    function "ADD_DELIVERY_3_2_5" (
    p_SURNAME    IN     VARCHAR2,
    p_NAME       IN     VARCHAR2,
    p_PATRONYMIC IN     VARCHAR2,
    p_ADRESS     IN     VARCHAR2,
    p_TELEFON    IN     VARCHAR2,
    p_ID_ORDER   IN     NUMBER,
    p_CITY       IN     NUMBER,
    p_message    out    varchar2 
    ) return number
    AS     --0 все хорошо 1 - не найден заказ 2 - Данные обновлены 
        v_id_ord_cou    NUMBER;
        v_id_us         NUMBER;
        v_id_us_count   NUMBER;
        
    BEGIN
        
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

                    p_message:='ВСЕ ГУД';
                    return 0;
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
                   p_message:='Данные обновлены';
                   return 2;
                END IF;
                COMMIT;
            ELSE
            p_message:='Заказ не найден';
            return 1;

            END IF;
        exception
        when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 3;
    end;
    
    function "GET_ORDERS_3_2_6" 
    (
        p_id_usr number,
        p_status OUT number,
        p_message    out    varchar2 
    ) return SYS_REFCURSOR
    AS --0 -все хорошо 1 - пользователь не найден
    v_id_usr_count number;
    v_cart SYS_REFCURSOR;
    BEGIN
      Select count(id_user) into v_id_usr_count  from orders where id_user=p_id_usr and DEL_date is null;
      if v_id_usr_count > 0 then
          OPEN v_cart FOR
          SELECT id_order from orders where id_user=p_id_usr and DEL_date is null;
          p_message:='ВСЕ ГУД';
          p_status:=0;
      else 
      p_message:='Пользователь не найден';
      p_status:=1;
      end if;
      exception
        when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ;p_status:=2; return null;
    end;
    
    function "GET_ORDERS_3_2_6_JSON" 
    (
    p_id_usr number,
    p_message    out    varchar2,
    p_status OUT number
    ) return clob
    AS --0 -все хорошо 1 - пользователь не найден
    v_user varchar2(200);
    v_cart clob;
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
        v_cart := apex_json.get_clob_output;
        apex_json.free_output;
        p_message:='ВСЕ ГУД';
        p_status:=0;
        return v_cart;
     exception 
     WHEN NO_DATA_FOUND THEN  p_status:=1; return null;
     when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ;p_status:=2; return null;
      
    END ;  
    
    FUNCTION "GET_ORDERS_3_2_6_PIPE" 
    (
    p_id_usr number,
    p_message    out    varchar2,
    p_status OUT number
    ) return t_orders_table pipelined
    AS 
    v_id_usr_count number;
    v_rec t_orders_record;
    BEGIN
      FOR i in(
      SELECT id_order from orders where id_user=p_id_usr and DEL_date is null)
      loop 
        v_rec:=t_orders_record(p_id_usr,i.id_order);
        pipe row(v_rec);
      end loop;
      p_message:='ВСЕ ГУД';
      p_status:=0;
      return;
      exception 
     WHEN NO_DATA_FOUND THEN  p_status:=1; return ;
     when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ;p_status:=2; return ;
    END ;
    
    function ADD_ORDER_3_2_7 
    (
        p_id_usr number,
        p_status_order varchar2,
        p_message out varchar2 
    ) return number
    as
    begin
       INSERT INTO ORDERS (id_user,status_order,del_date,del_user) values (p_id_usr, p_status_order,null,null);
       p_message:='ВСЕ ГУД';
       return 0;
       exception
       when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 1;
    end;
    
    function DEL_ORDER_3_2_7 
    (
        p_order number,
        p_status_order varchar2,
        p_del_user varchar2,
        p_message out varchar2 
    ) return number
    as
    begin
       
       UPDATE ORDERS
        set
            del_date=sysdate,
            del_user=p_del_user
       where id_order=p_order and del_date is null;
       
       update carts
        set
            del_date=sysdate,
            del_user=p_del_user
       where id_order=p_order and del_date is null;
       
       update delivery 
            set 
            DEL_DATE=sysdate,
            DEL_USER=p_del_user
            where ID_ORDER=P_order and del_date is null; 
       
       p_message:='ВСЕ ГУД';
       return 0;
       
       exception
       when others then  p_message:='Все сломалось сорри ( : '|| TO_CHAR(SQLCODE) || ' - ' || SQLERRM ; return 1;
    end;
END ;
/
