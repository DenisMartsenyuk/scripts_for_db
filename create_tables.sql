CREATE TABLE rd_permission
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(256) NOT NULL UNIQUE
);

CREATE TABLE rd_role
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(256) NOT NULL UNIQUE
);

CREATE TABLE rd_role_permission
(
    id            SERIAL PRIMARY KEY,
    role_id       INTEGER REFERENCES rd_role ON DELETE CASCADE ON UPDATE CASCADE       NOT NULL,
    permission_id INTEGER REFERENCES rd_permission ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE rd_user
(
    id          SERIAL PRIMARY KEY,
    login       VARCHAR(256) NOT NULL UNIQUE,
    password    VARCHAR(256) NOT NULL,
    name        VARCHAR(256) NOT NULL,
    surname     VARCHAR(256) NOT NULL,
    middle_name VARCHAR(256),
    email       VARCHAR(256) NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);


CREATE TABLE rd_user_role
(
    id      SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES rd_user ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    role_id INTEGER REFERENCES rd_role ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE rd_parent_student
(
    id         SERIAL PRIMARY KEY,
    parent_id  INTEGER REFERENCES rd_user ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    student_id INTEGER REFERENCES rd_user ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE rd_author
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(256) NOT NULL,
    surname     VARCHAR(256) NOT NULL,
    middle_name VARCHAR(256)
);

CREATE TABLE rd_writing
(
    id        SERIAL PRIMARY KEY,
    author_id INTEGER REFERENCES rd_author ON DELETE RESTRICT ON UPDATE CASCADE,
    name      VARCHAR(256) NOT NULL
);

CREATE TABLE rd_reading_task
(
    id         SERIAL PRIMARY KEY,
    parent_id  INTEGER REFERENCES rd_user ON DELETE CASCADE ON UPDATE CASCADE    NOT NULL,
    student_id INTEGER REFERENCES rd_user ON DELETE CASCADE ON UPDATE CASCADE    NOT NULL,
    writing_id INTEGER REFERENCES rd_writing ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    deadline   timestamp with time zone,
    completed  BOOLEAN                                                           NOT NULL
);


CREATE TABLE rd_reading_session
(
    id              SERIAL PRIMARY KEY,
    student_id      INTEGER REFERENCES rd_user ON DELETE CASCADE ON UPDATE CASCADE         NOT NULL,
    reading_task_id INTEGER REFERENCES rd_reading_task ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    reading_start   timestamp with time zone                                               NOT NULL,
    reading_end     timestamp with time zone                                               NOT NULL
);


CREATE TABLE rd_report
(
    id              SERIAL PRIMARY KEY,
    student_id      INTEGER REFERENCES rd_user ON DELETE CASCADE ON UPDATE CASCADE         NOT NULL,
    reading_task_id INTEGER REFERENCES rd_reading_task ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    characters      TEXT,
    plot            TEXT,
    review          TEXT,
    creation_date   timestamp with time zone                                               NOT NULL,
    edit_date       timestamp with time zone                                               NOT NULL
);

CREATE TABLE rd_report_file
(
    id            SERIAL PRIMARY KEY,
    path          VARCHAR(256)             NOT NULL,
    creation_date timestamp with time zone NOT NULL
);