drop table post_users;
drop table registeredMail;
drop table unregisteredMail;
drop table postal_code;
drop table route;
drop table office_room;
drop table vehicle;
drop table schedule;
drop table post_employee;
drop table post_office;


create table post_office(
  office_id varchar2(5) primary key,
  address varchar2(50) not null,
  province varchar2(2) not null,
  forward_section_area varchar2(3) not null
);

create table post_employee(
  emp_id varchar2(5) primary key,
  first_name varchar2(50) not null,
  last_name varchar2(50) not null,
  role varchar2(15) check(role in ('carrier', 'clerk', 'postmaster')) not null,
  dayoff date,
  phone_number varchar2(15) not null,
  email varchar2(50) not null
);

create table office_room(
  office_id varchar2(5) references post_office(office_id),
  emp_id varchar2(5) references post_employee(emp_id),
  room_number varchar2(4) not null,
  PRIMARY KEY(office_id, emp_id)
);

create table schedule(
  schedule_id varchar2(5) primary key,
  start_time date NOT NULL,
  end_time date,
  emp_id varchar2(5) references post_employee(emp_id),
  office_id varchar2(5) references post_office(office_id)
);

create table vehicle(
  vehicle_id varchar2(5) primary key,
  plate_number varchar2(10) not null unique,
  status varchar2(15) check(status in ('in use', 'available', 'decommissioned')) not null,
  office_id varchar2(5) references post_office(office_id),
  schedule_id varchar2(5) references schedule(schedule_id)
);

create table route(
  route_id varchar2(5) primary key,
  name varchar2(50) not null,
  last_delivery date,
  status varchar2(15) check(status in('not started', 'started', 'finished')) not null,
  schedule_id varchar2(5) references schedule(schedule_id)
);

create table postal_code(
 code varchar2(7) primary key,
 province varchar2(50) not null,
 city varchar2(50) not null,
 route_id varchar2(5) references route(route_id)
);

create table registeredMail(
  mail_id varchar2(5) primary key,
  weight number(6,2) not null,
  postage number(5,2) not null,
  status varchar2(25) not null,
  delivery_address varchar2(50) not null,
  return_address varchar2(50) not null,
  delivery_country varchar2(50) not null,
  delivery_code varchar2(7) references postal_code(code),
  return_code varchar2(7) references postal_code(code)
);

create table unregisteredMail(
  mail_id varchar2(5) primary key,
  weight number(6,2) not null,
  postage number(5,2) not null,
  status varchar2(25) not null,
  delivery_address varchar2(50) not null,
  return_address varchar2(50),
  delivery_country varchar2(50) not null,
  delivery_code varchar2(7) references postal_code(code),
  return_code varchar2(7)
);

create table post_users(
  userid varchar2(5) primary key,
  emp_id varchar2(5) not null references post_employee(emp_id),
  salt varchar2(30) not null,
  hash raw(256) not null
);