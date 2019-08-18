

PRAGMA foreign_keys = ON;


CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    author_id INTEGER NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    question_id INTEGER,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    subject_question_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    parent_reply_id INTEGER,
    

    FOREIGN KEY (subject_question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
    FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
    users (fname, lname)
VALUES
    ("dom", "laurin"),
    ("anthony", "garino");

INSERT INTO
    questions (title, body, author_id)
VALUES
    ("Is this working?", "I think it is working, indeed.", 1),
    ("Who let the dogs out?", "I think it was Julie", 2);

INSERT INTO
    question_follows (user_id, question_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 2);

INSERT INTO
    replies (body, subject_question_id, author_id, parent_reply_id)
VALUES
    ("Are you sure it's working?", 1, 2, null),
    ("Idk what to reply, but I gotta reply to your reply, otherwise the a/A gods are gonna be unhappy", 1, 1, 1),
    ("There are a/A gods in pry?", 1, 2, 2),
    ("Yes, they reside in the pryopolis on the SQL mountain", 1, 1, 3);

INSERT INTO
    question_likes (question_id, user_id)
VALUES
    (1, 1),
    (1, 2);