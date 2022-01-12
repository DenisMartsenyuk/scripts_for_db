CREATE OR REPLACE FUNCTION rd_check_update_const_id() RETURNS TRIGGER AS $$
BEGIN

	IF OLD.id != NEW.id THEN
		RAISE EXCEPTION 'Can not update id column in this table.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION rd_check_const_id_role() RETURNS TRIGGER AS $$
BEGIN

	IF TG_OP = 'DELETE' THEN
		IF OLD.id = 1 OR OLD.id = 2 OR OLD.id = 3 THEN
			RAISE EXCEPTION 'Can not delete row with id =  % .', OLD.id;
		ELSE
        	RETURN OLD;
        END IF;

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.id = 1 AND NEW.id != 1 OR OLD.id = 2 AND NEW.id != 2 OR OLD.id = 3 AND NEW.id != 3 THEN
			RAISE EXCEPTION 'Can not update id column in row with id =  % .', OLD.id;
		ELSE
        	RETURN NEW;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION rd_check_user_role() RETURNS TRIGGER AS $$
BEGIN

	IF TG_OP = 'INSERT' THEN
		IF (SELECT id FROM rd_user_role WHERE user_id = NEW.user_id AND role_id = 1) IS NOT NULL AND NEW.role_id = 2 THEN
			RAISE EXCEPTION 'Can not insert row, because user with id =  % is parent. Parent can not be a student.', NEW.user_id;
		END IF;

		IF (SELECT id FROM rd_user_role WHERE user_id = NEW.user_id AND role_id = 2) IS NOT NULL AND NEW.role_id = 1 THEN
			RAISE EXCEPTION 'Can not insert row, because user with id =  % is student. Student can not be a parent.', NEW.user_id;
		END IF;

		RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'Can not update rows in this table.';

    ELSIF TG_OP = 'DELETE' THEN
    	IF (OLD.role_id = 1 OR OLD.role_id = 2) AND (SELECT id FROM rd_user WHERE id = OLD.user_id) IS NOT NULL THEN
			RAISE EXCEPTION 'Can not delete row, because it is main role to user with id = %.', OLD.user_id;
		END IF;
		RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION rd_check_parent_student() RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'Can not update rows in this table.';

    ELSIF TG_OP = 'INSERT' THEN

    	IF (SELECT id FROM rd_user_role WHERE user_id = NEW.parent_id AND role_id = 1) IS NULL THEN
        	RAISE EXCEPTION 'Can not insert row, because user with id =  % is not parent.', NEW.parent_id;
        END IF;

    	IF (SELECT id FROM rd_user_role WHERE user_id = NEW.student_id AND role_id = 2) IS NULL THEN
        	RAISE EXCEPTION 'Can not insert row, because user with id =  % is not student.', NEW.student_id;
    	END IF;

    	IF (SELECT id FROM rd_parent_student WHERE parent_id = NEW.parent_id AND student_id = NEW.student_id) IS NOT NULL THEN
        	RAISE EXCEPTION 'Can not insert row because this combination parent-student is already exist.';
    	END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION rd_check_reading_task() RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'UPDATE' THEN
    	IF OLD.id != NEW.id THEN
			RAISE EXCEPTION 'Can not update id column in this table.';
    	END IF;

        IF OLD.parent_id != NEW.parent_id OR OLD.student_id != NEW.student_id OR OLD.writing_id != NEW.writing_id THEN
            RAISE EXCEPTION 'Can not update fields: parent_id, student_id, writing_id.';
        END IF;

    ELSIF TG_OP = 'INSERT' THEN
        IF (SELECT id FROM rd_parent_student WHERE parent_id = NEW.parent_id AND student_id = NEW.student_id) IS NULL THEN
            RAISE EXCEPTION 'Can not insert row, because user with id =  % is not parent to user with id = %.', NEW.parent_id, NEW.student_id;
        END IF;

        IF (SELECT id FROM rd_reading_task WHERE parent_id = NEW.parent_id AND student_id = NEW.student_id AND writing_id = NEW.writing_id) IS NOT NULL THEN
            RAISE EXCEPTION 'Can not insert row, because this combination parent-student-writing is already exist.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION rd_check_reading_session() RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'Can not update rows in this table.';

    ELSIF TG_OP = 'INSERT' THEN
        IF (SELECT id FROM rd_user_role WHERE user_id = NEW.student_id AND role_id = 2) IS NULL THEN
        	RAISE EXCEPTION 'Can not insert row, because user with id =  % is not student.', NEW.student_id;
    	END IF;

    	IF (SELECT id FROM rd_reading_task WHERE id = NEW.reading_task_id) IS NULL THEN
    		RAISE EXCEPTION 'Can not insert row, because reading_task with id =  % does not exist.', NEW.reading_task_id;
    	END IF;

    	IF (SELECT id FROM rd_reading_task WHERE student_id = NEW.student_id AND id = NEW.reading_task_id) IS NULL THEN
    		RAISE EXCEPTION 'Can not insert row, because reading_task with id =  % does not belong to the student with id = %.', NEW.reading_task_id, NEW.student_id;
    	END IF;

    	IF NEW.reading_end < NEW.reading_start THEN 
			RAISE EXCEPTION 'Can not insert row, because reading_end < reading_start';
    	END if;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION rd_check_report() RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'UPDATE' THEN
        IF OLD.student_id != NEW.student_id OR OLD.reading_task_id != NEW.reading_task_id THEN
            RAISE EXCEPTION 'Can not update fields: student_id, reading_task_id.';
        END IF;

    ELSIF TG_OP = 'INSERT' THEN
        IF (SELECT id FROM rd_user_role WHERE user_id = NEW.student_id AND role_id = 2) IS NULL THEN
        	RAISE EXCEPTION 'Can not insert row, because user with id =  % is not student.', NEW.student_id;
    	END IF;

    	IF (SELECT id FROM rd_reading_task WHERE id = NEW.reading_task_id) IS NULL THEN
    		RAISE EXCEPTION 'Can not insert row, because reading_task with id =  % does not exist.', NEW.reading_task_id;
    	END IF;

    	IF (SELECT id FROM rd_reading_task WHERE student_id = NEW.student_id AND id = NEW.reading_task_id) IS NULL THEN
    		RAISE EXCEPTION 'Can not insert row, because reading_task with id =  % does not belong to the student with id = %.', NEW.reading_task_id, NEW.student_id;
    	END IF;

    	IF NEW.edit_date < NEW.creation_date THEN 
			RAISE EXCEPTION 'Can not insert row, because edit_date < creation_date';
    	END if;

    	IF (SELECT id FROM rd_report WHERE student_id = NEW.student_id AND reading_task_id = NEW.reading_task_id) IS NOT NULL THEN
            RAISE EXCEPTION 'Can not insert row, because this combination student-reading_task is already exist.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

