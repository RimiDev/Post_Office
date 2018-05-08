create or replace trigger markSchedule
after update
on route
begin 
  if(:New.status = 'finished' AND :old.status = 'started') then
    update schedule set end_time = SYSDATE
    where schedule_id = schedule_id;
  end if;
  
  if(:new.status = 'started' AND :old.status = 'finished') then
    update schedule set start_time = SYSDATE
    where schedule_id = schedule_id;
  end if;
  
  if(:old.status = 'not started' and :new.status = 'started') then
    update schedule set start_time = SYSDATE
    where schedule_id = schedule_id;
  end if;
end;

