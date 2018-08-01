CREATE OR REPLACE PACKAGE STUDENT4.THING_3_1 
is  
  FUNCTION "GET_THING_3_1_1" 
    (
     p_message out varchar2,
     p_status out number
    )return SYS_REFCURSOR;
  FUNCTION "GET_THING_3_1_1_PIPE"
    (
        p_message out varchar2,
        p_status out number
    )return t_THING_table pipelined;
  FUNCTION "GET_THING_3_1_1_JSON" 
    (
      p_message out varchar2,
      p_status out number
    ) return clob;
  function "ADD_THING_3_1_2" 
    (  
    p_NAME IN VARCHAR2, 
    p_PRICE IN NUMBER,
    p_message OUT varchar2
    )return number;  
  FUNCTION "EDIT_THING_3_1_3" (
    p_ID          IN     NUMBER,
    p_NEW_NAME    IN     VARCHAR2,
    p_NEW_PRICE   IN     NUMBER,
    p_message     OUT    VARCHAR2)
    return number;
    FUNCTION "DELETE_THING_3_1_4" 
    ( 
        p_ID IN NUMBER,
        p_WHO_DEL IN VARCHAR2,
        p_message out VARCHAR2 
        
    ) RETURN NUMBER;
   
end;
/
CREATE OR REPLACE PACKAGE STUDENT4.USERS_3_2 AS
    FUNCTION "LOG_IN_3_2_1" 
    (  
        p_NAME IN VARCHAR2, 
        p_PASSWORD IN VARCHAR2, 
        p_message out varchar2
    )  return number;
    FUNCTION "EDIT_USER_3_2_2" 
    (
        p_ID IN NUMBER , 
        p_NEW_NAME IN VARCHAR2 , 
        p_NEW_PASS IN VARCHAR2, 
        p_message out varchar2
    ) return number;
    FUNCTION "DEL_USER_3_2_3" 
    ( 
     P_ID_USER IN NUMBER , 
     P_WHO_DEL IN varchar2 , 
     p_message out varchar2 
     ) return number;
    FUNCTION "ADD_THING_TO_CART_3_2_4_1" 
    ( 
        p_ID IN NUMBER ,
        p_thing IN NUMBER , 
        p_message out varchar2 
    ) return number;
    FUNCTION "DEL_THING_FROM_CART_3_2_4_2" 
    (  
    p_ORDER_ IN NUMBER , 
    p_THING IN NUMBER , 
    p_WHO_DEL in varchar2,
    p_message out varchar2 
    ) return number;
    function "ADD_DELIVERY_3_2_5" (
    p_SURNAME    IN     VARCHAR2,
    p_NAME       IN     VARCHAR2,
    p_PATRONYMIC IN     VARCHAR2,
    p_ADRESS     IN     VARCHAR2,
    p_TELEFON    IN     VARCHAR2,
    p_ID_ORDER   IN     NUMBER,
    p_CITY       IN     NUMBER,
    p_message    out    varchar2 
    ) return number;
    function "GET_ORDERS_3_2_6" 
    (
        p_id_usr number,
        p_status OUT number,
        p_message    out    varchar2 
    ) return SYS_REFCURSOR;
    function "GET_ORDERS_3_2_6_JSON" 
    (
    p_id_usr number,
    p_message    out    varchar2,
    p_status OUT number
    ) return clob;
    FUNCTION "GET_ORDERS_3_2_6_PIPE" 
    (
    p_id_usr number,
    p_message    out    varchar2,
    p_status OUT number
    ) return t_orders_table pipelined;
    function ADD_ORDER_3_2_7 
    (
        p_id_usr number,
        p_status_order varchar2,
        p_message out varchar2 
    ) return number;
    function DEL_ORDER_3_2_7 
    (
        p_order number,
        p_status_order varchar2,
        p_del_user varchar2,
        p_message out varchar2 
    ) return number;
END ;
/
