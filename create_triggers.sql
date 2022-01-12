CREATE TRIGGER rd_check_update_id_user
    BEFORE UPDATE
    ON rd_user
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_update_const_id();


CREATE TRIGGER rd_check_update_id_writing
    BEFORE UPDATE
    ON rd_writing
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_update_const_id();


CREATE TRIGGER rd_check_const_id_role
    BEFORE UPDATE OR DELETE
    ON rd_role
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_const_id_role();


CREATE TRIGGER rd_check_user_role
    BEFORE UPDATE OR INSERT OR DELETE
    ON rd_user_role
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_user_role();


CREATE TRIGGER rd_check_parent_student
    BEFORE INSERT OR UPDATE
    ON rd_parent_student
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_parent_student();


CREATE TRIGGER rd_check_reading_task
    BEFORE INSERT OR UPDATE
    ON rd_reading_task
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_reading_task();


CREATE TRIGGER rd_check_reading_session
    BEFORE INSERT OR UPDATE
    ON rd_reading_session
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_reading_session();


CREATE TRIGGER rd_check_report
    BEFORE INSERT OR UPDATE
    ON rd_report
    FOR EACH ROW
EXECUTE PROCEDURE rd_check_report();