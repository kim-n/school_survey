CREATE TABLE users (
  uid INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  qid INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(uid)
);

CREATE TABLE question_followers (
  follow_id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(qid),
  FOREIGN KEY (user_id) REFERENCES users(uid)
);

CREATE TABLE replies (
  reply_id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  parent_reply INTEGER,


  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(uid),
  FOREIGN KEY (question_id) REFERENCES questions(qid)

);

CREATE TABLE question_likes (
  like_id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(qid),
  FOREIGN KEY (user_id) REFERENCES users(uid)
);



-- USERS
INSERT INTO
  users (fname, lname)
VALUES
  ('Albert', 'Einstein'),
  ('Kurt', 'Godel'),
  ('Tim', 'Buckley'),
  ('Kimberly', 'Narine'),
  ('Sid', 'Raval'),
  ('Tommy', 'Duek'),
  ('Jonathan', 'Tamboer');

--QUESTIONS
INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Does this work?', "I really hope it does. Also I can have lots an lots of words here. Isn't that great?",
  (SELECT uid FROM users WHERE lname = "Einstein")),
    ('Space-time dilation', "This isn't really a question, but I think you're crazy Einstein.",
    (SELECT uid FROM users WHERE lname = "Godel")),
        ('Excused lateness', "Is it okay for me to be absent on Monday? I think I'll be hungover. Tuesday I is just not coming.",
        (SELECT uid FROM users WHERE lname = "Buckley"));

--FOLLOW QUESTIONS
INSERT INTO
  question_followers (question_id, user_id)
VALUES
  ( (SELECT qid FROM questions WHERE title = 'Does this work?'),
    (SELECT uid FROM users WHERE lname = "Buckley") ),
  ((SELECT qid FROM questions WHERE title = 'Space-time dilation'),
    (SELECT uid FROM users WHERE lname = "Einstein") );

--REPLIES
INSERT INTO
  replies (body, parent_reply, question_id, user_id)
VALUES
  ("I always said: Imagination is more important than knowledge.",
    NULL,
  (SELECT qid FROM questions WHERE title = 'Space-time dilation'),
  (SELECT uid FROM users WHERE lname = "Einstein")
  );

  INSERT INTO
    replies (body, parent_reply, question_id, user_id)
  VALUES
  ("You keep saying that...",
    (SELECT reply_id FROM replies WHERE body = "I always said: Imagination is more important than knowledge."),
    (SELECT qid FROM questions WHERE title = 'Space-time dilation'),
    (SELECT uid FROM users WHERE lname = "Godel") );

--LIKES
INSERT INTO
  question_likes (question_id, user_id)
VALUES
  ( (SELECT qid FROM questions WHERE title = 'Excused lateness'),
    (SELECT uid FROM users WHERE lname = "Narine") ),
  ( (SELECT qid FROM questions WHERE title = 'Does this work?'),
    (SELECT uid FROM users WHERE lname = "Buckley") ),

  ( (SELECT qid FROM questions WHERE title = 'Does this work?'),
    (SELECT uid FROM users WHERE lname = "Tamboer") );