CREATE TABLE IF NOT EXISTS todo (
    "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL, 
    "todo_text" VARCHAR(255) NOT NULL, 
    "created_date_time" TIMESTAMP DEFAULT NOW()::date,
    "completed_date_time" TIMESTAMP DEFAULT NULL
);

INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Create Stark Enterprises II','2011-12-30 15:27:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Invent the first Iron Man Suit','2012-03-08 13:53:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Become a Hero','2013-01-08 15:14:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Help build S.H.I.E.L.D.','2013-12-03 12:59:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Form the Avengers','2015-02-23 11:09:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Put Hawkeye on the right path','2017-03-22 14:51:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Make Stark Industries a massive success','2018-04-16 12:05:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Keep escaping death in the most Tony Stark way possible','2019-04-11 14:08:25-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Learn Spring boot','2019-11-21 10:44:00-07') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time") VALUES ('Deploy a multi tier Spring boot app into Azure','2022-04-22 19:10:25-07') ON CONFLICT DO NOTHING;

I