DELIMITER  $$
CREATE PROCEDURE `seckill`.`execute_seckill`
  (in v_seckill_id BIGINT,in v_phone bigint,
   IN v_kill_time timestamp, out r_result int)
  BEGIN
    DECLARE  insert_count int DEFAULT 0;
    START TRANSACTION;
    INSERT  ignore into success_killed
    (seckill_id,user_phone,create_time)
    values (v_seckill_id,v_phone,v_kill_time);
    SELECT  row_count() INTO  insert_count;
    IF(insert_count = 0) then
      ROLLBACK ;
      set r_result = -1;
    elseif(insert_count <0) then
      ROLLBACK ;
      set r_result = -2 ;
    ELSE
        UPDATE  seckill
        SET number=number-1
        where seckill_id = v_seckill_id
          and end_time>v_kill_time
          and start_time < v_kill_time
          and number>0;
        SELECT  row_count() INTO  insert_count;
        if(insert_count=0) then
            ROLLBACK ;
            set r_result = 0;
        elseif(insert_count<0)then
            ROLLBACK ;
            set r_result = -2;
        else
            COMMIT ;
            set r_result = 1;
        end if;
    end if;
  end;
$$
-- 存储过程结束

DELIMITER ;
set @r_result = -3;
-- 执行存储过程
call execute_seckill(1003,13542422422,now(),@r_result);
-- 获取结果
select @r_result

--存储过程
-- 1.存储过程优化，事务行级锁持有时间减短
-- 2. 不要过度依赖存储过程
-- 3.简单的逻辑可以应用存储过程
-- 4.QPS:1个秒杀单 6000/QPS