CREATE OR REPLACE TYPE STUDENT4.t_orders_table as table of t_orders_record;
/
CREATE OR REPLACE TYPE STUDENT4.t_quantity_record as object
(
 id_warehouse number,
 id_thing number,
 quantity number
)
/
CREATE OR REPLACE TYPE STUDENT4.t_quantity_table as table of t_quantity_record;
/
CREATE OR REPLACE TYPE STUDENT4.t_THING_record as object
(
 NAME_THING number,
 id_thing number,
 PRICE_THING number
)
/
CREATE OR REPLACE TYPE STUDENT4.t_THING_table as table of t_THING_record;
/
CREATE OR REPLACE TYPE STUDENT4.t_delivery_record as object
(
 id_warehouse number,
 id_order number,
 id_thing number
)
/
CREATE OR REPLACE TYPE STUDENT4.t_delivery_table as table of t_delivery_record;
/
CREATE OR REPLACE TYPE STUDENT4.t_orders_record as object
(
 id_user number,
 id_order number
)
/
