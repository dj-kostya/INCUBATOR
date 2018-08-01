CREATE OR REPLACE FUNCTION STUDENT4."GET_ORDERS_3_2_6_PIPE" 
(
p_id_usr number

) return t_orders_table pipelined
AS --0 -все хорошо 1 - пользователь не найден
v_id_usr_count number;
v_rec t_orders_record;
BEGIN
  FOR i in(
  SELECT id_order from orders where id_user=p_id_usr and DEL_date is null)
  loop 
    v_rec:=t_orders_record(p_id_usr,i.id_order);
    pipe row(v_rec);
  end loop;
  
  return;
END ;
/
CREATE OR REPLACE FUNCTION STUDENT4."ADD_THING_3_1_2_FUNC" 
(  
p_NAME IN VARCHAR2, 
p_PRICE IN NUMBER,
p_message OUT varchar2
)return number
is
 
BEGIN

    Merge into things t
    using dual 
    ON (t.NAME_THING=p_name)
    when MATCHED then UPDATE set t.PRICE_THING=p_PRICE
    when NOT MATCHED then INSERT ("NAME_THING", "PRICE_THING")  
    VALUES
    (p_NAME, p_PRICE);
    p_message:='ВСЕ ГУД';
    return 0;
exception 
when others then 
begin
p_message:='Ошибочка';
return 1;

end;
END ;
/
CREATE OR REPLACE FUNCTION STUDENT4."EDIT_THING_3_1_3_FUNC" (
    p_ID          IN     NUMBER,
    p_NEW_NAME    IN     VARCHAR2,
    p_NEW_PRICE   IN     NUMBER,
    p_massage     OUT    VARCHAR2)-- 0 - запись обновлена 1- запись не найдена 2- аргументы не заданы
    return number
AS
v_thin_cou number;
BEGIN
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
                p_massage:='Все гуд';
                return 0;
            
            else
            p_massage:='Все записи удалены';
            return 1;
            
         END IF;  
        
    exception 
    when others then  p_massage:='Все сломалось сори (';return 1;
        
END;
/
CREATE OR REPLACE FUNCTION STUDENT4.GET_delivery_3_4_1_pipe 
return t_delivery_table pipelined
IS
v_rec t_delivery_record;

BEGIN
   for i in(
   select o.ID_ORDER,c.id_warehouse,c.id_thing
   FROM ORDERS o
   join Delivery d
   on d.id_order = o.ID_ORDER 
   join CARTS c
   on c.id_order=o.id_order
   where o.del_date is null and d.del_date is null  and d.ID_DELIVERY is not null and c.id_warehouse is not null
   order by c.id_warehouse)
   loop
    v_rec := t_delivery_record (i.id_warehouse,i.id_order,i.id_thing);
    pipe row(v_rec);
   end loop;
   return;
END ;
/
CREATE OR REPLACE FUNCTION STUDENT4.get_quantity_3_4_2_PIPE
(
p_quantity number
) return t_quantity_table pipelined
 IS
v_rec t_quantity_record;

BEGIN
   for i in( select id_warehouse,id_thing, quantity from Remnants where quantity < p_quantity and del_date is null)
   loop
    v_rec:=t_quantity_record(i.id_warehouse,i.id_thing,i.quantity);
    pipe row(v_rec);
   end loop;
   return ;
END ;
/
CREATE OR REPLACE FUNCTION STUDENT4."GET_THING_3_1_1_FUNC" 
(
 p_message out varchar2,
 p_status out number
)return SYS_REFCURSOR
is 
v_return  SYS_REFCURSOR;
BEGIN
OPEN v_return FOR
select NAME_THING,PRICE_THING from THINGS where DEL_DATE is null;
p_status:=0;
p_message:='ВСЕ ГУД';
return v_return;
exception 
when NO_DATA_FOUND then p_status:=1; p_message:='Все товары удалены'; return null;
when others then p_status:=2; p_message:='Все сломалось сори ('; return null;
END;
/
CREATE OR REPLACE FUNCTION STUDENT4.GET_THING_3_1_1_PIPE

 return t_THING_table pipelined
 AS
v_rec t_THING_record;

BEGIN
   for i in(select id_thing, NAME_THING,PRICE_THING from THINGS where DEL_DATE is null)
   loop
    v_rec:=t_THING_record(i.NAME_THING,i.id_thing,i.PRICE_THING);
    pipe row(v_rec);
   end loop;
   return ;
END ;
/
