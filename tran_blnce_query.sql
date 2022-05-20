

DROP TABLE public.mb_dfs_deposit_transaction_limit_details;

CREATE TABLE public.mb_dfs_deposit_transaction_limit_details (
id bigserial NOT null PRIMARY KEY,
mbdfs_transaction_limit_deposit_request_id int8 NULL,
client_id int8 NULL,
service_option_id int8 NULL,
created_date timestamp NULL,
balance numeric(19,2) NULL,
credit_amount numeric(19,2) NULL,
debit_amount numeric(19,2) NULL,
is_settle boolean,
last_modified_date timestamp NULL,
created_by int8 NULL,
last_modified_by int8 NULL,
beneficiary_account_no varchar(255) NULL,
coop_settlement_bank_account_no varchar(255) NULL,
hub_settlement_bank_account_no varchar(255) NULL,
originating_transaction_id varchar(255) NULL,
sender_account_no varchar(255) NULL,
settlement_id varchar(255) NULL,
transaction_type varchar(255) NULL,
dfs_transaction_id int8 NULL
);


drop function request_transaction(clientid int,serviceoptionid int,cramount DECIMAL(10,2),dramount DECIMAL(10,2));

create or replace function request_transaction(clientid int,serviceoptionid int,dramount DECIMAL(10,2),cramount DECIMAL(10,2))
returns int
language plpgsql
as $$
declare 
     actual_balance decimal(10,2);
     blnce decimal(10,2);
     idd int;
begin 
    select balance into blnce
    from mb_dfs_deposit_transaction_limit_details
    where client_id=clientid
    group by clientid,id,balance 
    order by id desc 
    limit 1;
    if dramount > 0 then
    begin 
	    select coalesce(blnce,0) + dramount into blnce;
	    insert into mb_dfs_deposit_transaction_limit_details(
	    mbdfs_transaction_limit_deposit_request_id,
	    client_id,
	    service_option_id,
        created_date ,
        balance ,
        credit_amount ,
        debit_amount ,
        is_settle ,
        last_modified_date ,
        created_by ,
        last_modified_by,
        beneficiary_account_no ,
        coop_settlement_bank_account_no ,
        hub_settlement_bank_account_no,
        originating_transaction_id,
        sender_account_no,
        settlement_id ,
        transaction_type        
	    )
	    values(
	    clientid,
	    clientid,
	    serviceoptionid,
	    current_date,
	    blnce,
	    null,
	    dramount,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null );
	    select max(id) into idd 
	    from mb_dfs_deposit_transaction_limit_details;
	   
	end;
	end if;

	if cramount>0 and coalesce(blnce,0)>=cramount then
	begin 
		select  coalesce(blnce,0) - cramount into blnce;
	    insert into mb_dfs_deposit_transaction_limit_details(
	    mbdfs_transaction_limit_deposit_request_id,
	    client_id,
	    service_option_id,
        created_date ,
        balance ,
        credit_amount ,
        debit_amount ,
        is_settle ,
        last_modified_date ,
        created_by ,
        last_modified_by,
        beneficiary_account_no ,
        coop_settlement_bank_account_no ,
        hub_settlement_bank_account_no,
        originating_transaction_id,
        sender_account_no,
        settlement_id ,
        transaction_type        
	    )
	    values(
	    null,
	    clientid,
	    serviceoptionid,
	    current_date,
	    blnce,
	    cramount,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null,
	    null );
	    select max(id) into idd 
	    from mb_dfs_deposit_transaction_limit_details;
	end;
 elsif cramount>coalesce(blnce,0) then
   begin
	    raise exception 'balance is insufficient than % to withdraw',cramount;
   end;
 end if;
return idd;
end;$$

select * from idd;
select * from mb_dfs_deposit_transaction_limit_details order by client_id,id;
select * from request_transaction(1,100,0000,5000);
update mb_dfs_deposit_transaction_limit_details
set is_settle=false
where id not in (3,6,7,8);

drop function balance_inquiry;

create or replace function balance_inquiry(clientid int,serviceoptionid int)
returns table(client__id int8,service__option__id int8,available_balance numeric(19,2),ledger_balance numeric(19,2),
unsettled_balance numeric(19,2),settled_balance numeric(19,2))
language plpgsql
as $$
begin
return query 
select  client_id,service_option_id,(sum(debit_amount)-sum(credit_amount)) as available_balance,sum(case when is_settle=true
        then (coalesce(debit_amount,0)-coalesce(credit_amount,0)) end) as ledger_balance,sum(case when is_settle=false
        then debit_amount end) as unsettled_amount,sum(case when is_settle=true
        then (coalesce(debit_amount,0)+coalesce(credit_amount,0)) end) as settled_amount
from mb_dfs_deposit_transaction_limit_details
where client_id=clientid and service_option_id=serviceoptionid
group by client_id,service_option_id
order by client_id;
end;$$

select * from balance_inquiry(1,100);


