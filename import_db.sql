CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  parent_reply INTEGER,


  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)

);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
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
  (SELECT id FROM users WHERE lname = "Einstein")),
  ('Space-time dilation', "This isn't really a question, but I think you're crazy Einstein.",
  (SELECT id FROM users WHERE lname = "Godel")),
  ('Excused lateness', "Is it okay for me to be absent on Monday? I think I'll be hungover. Tuesday I is just not coming.",
  (SELECT id FROM users WHERE lname = "Buckley")),
  ('SQL <3', "Isn't SQL great?",
  (SELECT id FROM users WHERE lname = "Buckley"));

--FOLLOW QUESTIONS
INSERT INTO
  question_followers (question_id, user_id)
VALUES
  ( (SELECT id FROM questions WHERE title = 'Does this work?'),
    (SELECT id FROM users WHERE lname = "Buckley") ),
  ((SELECT id FROM questions WHERE title = 'Space-time dilation'),
    (SELECT id FROM users WHERE lname = "Einstein") ),
  ( (SELECT id FROM questions WHERE title = 'Does this work?'),
    (SELECT id FROM users WHERE lname = "Narine") ),
  ((SELECT id FROM questions WHERE title = 'Space-time dilation'),
    (SELECT id FROM users WHERE lname = "Raval") ),
  ((SELECT id FROM questions WHERE title = 'Space-time dilation'),
    (SELECT id FROM users WHERE lname = "Narine") ),
  ((SELECT id FROM questions WHERE title = 'Excused lateness'),
    (SELECT id FROM users WHERE lname = "Duek") ),
  ((SELECT id FROM questions WHERE title = 'SQL <3'),
    (SELECT id FROM users WHERE lname = "Narine") )
    ;

--REPLIES
INSERT INTO
  replies (body, parent_reply, question_id, user_id)
VALUES
  ("I always said: Imagination is more important than knowledge.",
    NULL,
  (SELECT id FROM questions WHERE title = 'Space-time dilation'),
  (SELECT id FROM users WHERE lname = "Einstein")
  );

  INSERT INTO
    replies (body, parent_reply, question_id, user_id)
  VALUES
  ("You keep saying that...",
    (SELECT id FROM replies WHERE body = "I always said: Imagination is more important than knowledge."),
    (SELECT id FROM questions WHERE title = 'Space-time dilation'),
    (SELECT id FROM users WHERE lname = "Godel") );

--LIKES
INSERT INTO
  question_likes (question_id, user_id)
VALUES
  ( (SELECT id FROM questions WHERE title = 'Excused lateness'),
    (SELECT id FROM users WHERE lname = "Narine") ),
  ( (SELECT id FROM questions WHERE title = 'Does this work?'),
    (SELECT id FROM users WHERE lname = "Buckley") ),

  ( (SELECT id FROM questions WHERE title = 'Does this work?'),
    (SELECT id FROM users WHERE lname = "Tamboer") );