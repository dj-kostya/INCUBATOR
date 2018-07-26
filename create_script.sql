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
                CITY_CUSTOMER=CASE when p_CITY is null then CITY_CUSTOMER else p_CITY end               
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


CREATE OR REPLACE PROCEDURE STUDENT4."DELETE_THING_3_1_4" ( p_ID IN NUMBER) AS 
BEGIN
  
  commit;
END ;
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


CREATE OR REPLACE PROCEDURE STUDENT4."GET_THING_3_1_1" 
is   
BEGIN
for rec in (select NAME_THING,PRICE_THING from THINGS where DEL_DATE is not null) loop

  dbms_output.put_line('NAME: ' || rec.NAME_THING||'  PRICE: ' || rec.PRICE_THING);

end loop;

END;
/
