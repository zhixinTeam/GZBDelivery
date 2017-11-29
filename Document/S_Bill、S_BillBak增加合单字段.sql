Alter table S_Bill
add
   L_HdOrderId varchar(50)
   
Alter table S_BillBak
add
   L_HdOrderId varchar(50)

Alter table S_Bill
add
   L_HdOver varchar(1) not null default('N')
   
Alter table S_BillBak
add
   L_HdOver varchar(1) not null default('N')
   
  