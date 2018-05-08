--(DONE)Get the mail route
create or replace procedure getMailRoutes(empId in varchar2)
as
  cursor routes is
    select route_id from schedule
    join route using(schedule_id)
    where (emp_id = empId);
begin
  for item in routes loop
    dbms_output.put_line('Route Id: '||item.route_id);
  end loop;
end;

declare
  eid varchar2(5) := '1';
  eid2 varchar2(5) := '17';
  eid3 varchar2(5) := '18';
begin
  dbms_output.put_line('Test should equal 1 and 11');
  getMailRoutes(eid);
  dbms_output.put_line('Test should equal 9');
  getMailRoutes(eid2);
  dbms_output.put_line('Test should equal to 10');
  getMailRoutes(eid3);
end;

-- Get mail route cursor
create or replace procedure getMailRoutesCursor(empId in varchar2, crs1 out sys_refcursor)
as
begin
  open crs1 for 
    select route_id from schedule 
    join route using(schedule_id)
    where empId = emp_id;
end;


--(DONE) Get assigned vehicle for employee
create or replace function getAssignedVehicle(empId in varchar2)
return varchar2
as
  vid varchar2(5);
begin
  select vehicle_id into vid from schedule
  join vehicle using(schedule_id)
  where (emp_id = empId);
  return vid;
end;

declare
 empId varchar2(5) := '1';
 empId2 varchar2(5) := '6';
 vehicle varchar2(5);
 vehicle2 varchar2(5);
begin
  vehicle := getAssignedVehicle(empId);
  dbms_output.put_line('Should equal 1: ');
  dbms_output.put_line(vehicle);
  vehicle2 := getAssignedVehicle(empId2);
  dbms_output.put_line('Should equal 4: ');
  dbms_output.put_line(vehicle2);
end;

-- get assigned vehicle cursor
create or replace procedure getVehicleCursor(empId in varchar2, crs out sys_refcursor)
as
begin
  open crs for
    select vehicle_id from schedule
    join vehicle using(schedule_id)
    where (emp_id = empId); 
end;


-- Get all mail to be delivered by carrier
create or replace procedure getMailToDeliver(empId in varchar2)
is
  cursor crs1 is 
    select mail_id from registeredmail r
    join postal_code p on(p.code = r.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId);

  cursor crs2 is 
    select mail_id from unregisteredmail u
    join postal_code p on(p.code = u.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId);
begin
  dbms_output.put_line('Registered Mail to Deliver:');
  for item in crs1 loop
       dbms_output.put_line(item.mail_id);
  end loop;
  dbms_output.put_line('Unregistered Mail to Deliver:');
  for item in crs2 loop
       dbms_output.put_line(item.mail_id);
  end loop;
end;

declare
  eid varchar2(5) := '1';
begin
  getMailToDeliver(eid);
end;

-- Get cursor for all mail to deliver this shift
create or replace procedure getMailToDeliverCursor(empId in varchar2, crs1 out sys_refcursor, crs2 out sys_refcursor)
as
begin
  open crs1 for
    select mail_id from registeredmail r
    join postal_code p on(p.code = r.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where emp_id = empId;
    
  open crs2 for
    select mail_id from unregisteredmail u
    join postal_code p on(p.code = u.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where emp_id = empId;
end;


-- Get mail by routeid
create or replace procedure getMailByRoute(routeId in varchar2)
as
  cursor crs1 is
    select mail_id from unregisteredMail u
    join postal_code p on(p.code = u.delivery_code)
    where route_id = routeId;
    
    cursor crs2 is
      select mail_id from registeredMail r
      join postal_code p on(p.code = r.delivery_code)
     where route_id = routeId;
begin
  dbms_output.put_line('Registered Mail to Deliver:');
  for item in crs2 loop
       dbms_output.put_line(item.mail_id);
  end loop;
  dbms_output.put_line('Unregistered Mail to Deliver:');
  for item in crs1 loop
       dbms_output.put_line(item.mail_id);
  end loop;
end;

declare
  rid varchar2(5) := '1';
begin
  getMailByRoute(rid);
end;

--(done) get Mail by route cursor 
create or replace procedure getMailByRouteCursor(routeId in varchar2, csr out sys_refcursor, csr2 out sys_refcursor)
as
begin
  open csr for select mail_id from unregisteredMail u
    join postal_code p on(p.code = u.delivery_code)
    where route_id = routeId;

  open csr2 for select mail_id from registeredMail r
    join postal_code p on(p.code = r.delivery_code)
    where route_id = routeId;
end;


--(done) get mail by postal code
create or replace procedure getMailToDeliverByCode(empId in varchar2, pc in varchar2)
is
  cursor rm is 
    select mail_id from registeredmail r
    join postal_code p on(p.code = r.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND (code = pc);
    
  cursor um is 
    select mail_id from unregisteredmail u
    join postal_code p on(p.code = u.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND (code = pc);
begin
  dbms_output.put_line('Registered mail:');
  for item in rm loop 
    dbms_output.put_line(item.mail_id);
  end loop;
  dbms_output.put_line('Unregistered mail:');
  for item2 in um loop
    dbms_output.put_line(item2.mail_id);
  end loop;
end;

declare
  eid varchar2(5) := '2';
  pc varchar2(7) := 'H8N 8T1';
begin
  getMailToDeliverByCode(eid, pc);
end;

-- Get cursor for mail to be delivered by postal code 
create or replace procedure getDeliveryCodeCursor(empId in varchar2, pc in varchar2, crs1 out sys_refcursor, crs2 out sys_refcursor)
as
begin
  open crs1 for
    select mail_id from registeredmail r
    join postal_code p on(p.code = r.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND(code = pc);
  
  open crs2 for
    select mail_id from unregisteredmail u
    join postal_code p on(p.code = u.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND (code = pc);
end;


--(done) get mail to be dlivered by address
create or replace procedure getMailToDeliverAddress(empId in varchar2, myAddress in varchar2)
is
  cursor rm is 
    select mail_id from registeredmail r
    join postal_code p on(p.code = r.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND (delivery_address = myAddress);
    
  cursor um is 
    select mail_id from unregisteredmail u
    join postal_code p on(p.code = u.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND (delivery_address = myAddress);
begin
  dbms_output.put_line('Registered mail:');
  for item in rm loop 
    dbms_output.put_line(item.mail_id);
  end loop;
  dbms_output.put_line('Unregistered mail:');
  for item2 in um loop
    dbms_output.put_line(item2.mail_id);
  end loop;
end;

declare
  eid varchar2(5) := '2';
  address varchar2(50) := '2 Cherokee Place';
begin
  getMailToDeliverAddress(eid, address);
end;

-- Get cursor for mail to deliver by address
create or replace procedure getMaillToDeliverAddressCursor(empId in varchar2, myAddress in varchar2, crs1 out sys_refcursor, crs2 out sys_refcursor)
as
begin
  open crs1 for
    select mail_id from registeredmail r
    join postal_code p on(p.code = r.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND (delivery_address = myAddress);
      
  open crs2 for
    select mail_id from unregisteredmail u
    join postal_code p on(p.code = u.delivery_code)
    join route using(route_id)
    join schedule using(schedule_id)
    where (emp_id = empId) AND (delivery_address = myAddress);
end;


--(done)mark a registered mail as delivered 
create or replace procedure markRegisteredMail(mailId in varchar2)
is
begin
    update registeredMail
    set status = 'delivered'
    where mail_id = mailId;
end;

declare
  mid varchar2(5) := '1';
begin
  markRegisteredMail(mid);
end;

--(done) mark route as started
create or replace procedure startRoute(routeId in varchar2)
is
begin
  update route set status = 'started'
  where route_id = routeId;
end;

declare
  rid varchar2(5) := '1';
begin
  startRoute(rid);
end;

--(done)mark route as completed
create or replace procedure completeRoute(routeId in varchar2)
is
begin
  update route set status = 'finished'
  where route_id = routeId;
end;

declare
  rid varchar2(5) := '1';
begin
  completeRoute(rid);
end;

--(done)mark registered mail as undeliverable
create or replace procedure undeliverableRegisteredMail(mailId in varchar2)
is
begin
  update registeredMail set status = 'undeliverable'
  where mail_id = mailId;
end;

declare
  mid varchar2(5) := '1';
begin
  undeliverableRegisteredMail(mid);
end;

--(done)mark unregistered mail as undeliverable
create or replace procedure undeliverableUnregisteredMail(mailId in varchar2)
is
begin
  update unregisteredMail set status = 'undeliverable'
  where mail_id = mailId;
end;

declare
  mid varchar2(5) := '1';
begin
  undeliverableUnregisteredMail(mid);
end;

--(done)employee unable to work on a specific day
create or replace procedure carrierDayOff(empid in varchar2, day_off in date)
is
begin
    update post_employee set dayoff = to_date(day_off, 'DD-MON-YY')
    where emp_id = empid;
end;

declare
  eid varchar2(5) := '2';
begin
  carrierDayoff(eid, SYSDATE+7);
end;