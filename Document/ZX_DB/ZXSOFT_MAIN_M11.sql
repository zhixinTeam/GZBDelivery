Delete From Sys_Menu  Where M_MenuID='M11S01'
insert into sys_menu(m_menuid,m_progid,m_entity,m_pMenu,m_title,m_imgindex,m_popedom,m_newOrder)
values('M11S01','ZXSOFT','MAIN','M00','-',0,null,9.4);

Delete From Sys_Menu  Where M_MenuID='M11'
insert into sys_menu(m_menuid,m_progid,m_entity,m_pMenu,m_title,m_imgindex,m_popedom,m_newOrder)
values('M11','ZXSOFT','MAIN','M00','采购合同',-1,null,9.5);

delete from sys_datadict where d_entity='ZXSOFT_MAIN_M11';
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(1,'ZXSOFT_MAIN_M11','记录编号',50,0,-1,'R_ID',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(2,'ZXSOFT_MAIN_M11','自动编号',80,0,-1,'pcid',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(3,'ZXSOFT_MAIN_M11','合同编号',100,0,-1,'con_code',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(4,'ZXSOFT_MAIN_M11','供应商编码',100,0,-1,'provider_code',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(5,'ZXSOFT_MAIN_M11','供应商名称',200,0,-1,'provider_name',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(6,'ZXSOFT_MAIN_M11','物料编码',100,0,-1,'con_materiel_Code',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(7,'ZXSOFT_MAIN_M11','物料名称',200,0,-1,'con_materiel_name',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(8,'ZXSOFT_MAIN_M11','单价',50,0,-1,'con_price',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(9,'ZXSOFT_MAIN_M11','数量',50,0,-1,'con_quantity',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(10,'ZXSOFT_MAIN_M11','金额',80,0,-1,'con_Amount',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(11,'ZXSOFT_MAIN_M11','合同时间',100,0,-1,'con_date',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(12,'ZXSOFT_MAIN_M11','录入人',100,0,-1,'con_Man',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(13,'ZXSOFT_MAIN_M11','状态',80,0,-1,'con_status',-1,0);
insert into sys_datadict(d_itemid,d_entity,d_title,d_width,d_index,d_visible,d_dbfield,d_dbiskey,d_dbtype) values(14,'ZXSOFT_MAIN_M11','备注',200,0,-1,'con_remark',-1,0);