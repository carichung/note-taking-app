-- Create the 'notes' table if it doesn't already exist
CREATE TABLE notes (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO notes (title, content) VALUES ('Note 1', 'Test note 1');
INSERT INTO notes (title, content) VALUES ('Note 2', 'Test note 2');
INSERT INTO notes (title, content) VALUES ('Note 3', 'Test note 3');
INSERT INTO notes (title, content) VALUES ('Note 4', 'Test note 3');
INSERT INTO notes (title, content) VALUES ('Note 3', 'Test note 6')