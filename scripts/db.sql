
CREATE TABLE IF NOT EXISTS todo (
    "id" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL, 
    "todo_text" VARCHAR(255) NOT NULL, 
    "tracking_id" VARCHAR(50) NOT NULL,
    "created_date_time" TIMESTAMP DEFAULT NOW()::date,
    "completed_date_time" TIMESTAMP DEFAULT NULL
);

INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Create Stark Enterprises','2011-12-30 15:27:25-07', '00000000-0000-0000-0000-000000000001') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Invent the first Iron Man Suit','2012-03-08 13:53:25-07', '00000000-0000-0000-0000-000000000002') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Become a Hero','2013-01-08 15:14:25-07', '00000000-0000-0000-0000-000000000003') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Help build S.H.I.E.L.D.','2013-12-03 12:59:25-07', '00000000-0000-0000-0000-000000000004') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Form the Avengers','2015-02-23 11:09:25-07', '00000000-0000-0000-0000-000000000005') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Put Hawkeye on the right path','2017-03-22 14:51:25-07', '00000000-0000-0000-0000-000000000006') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Make Stark Industries a massive success','2018-04-16 12:05:25-07', '00000000-0000-0000-0000-000000000007') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Keep escaping death in the most Tony Stark way possible','2019-04-11 14:08:25-07', '00000000-0000-0000-0000-000000000008') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", tracking_id) VALUES ('Learn Spring boot','2019-11-21 10:44:00-07', '00000000-0000-0000-0000-000000000009') ON CONFLICT DO NOTHING;
INSERT INTO todo ("todo_text", "created_date_time", trackingId) VALUES ('Deploy a multi tier Spring boot app into Azure','2022-04-22 19:10:25-07', '00000000-0000-0000-0000-000000000010') ON CONFLICT DO NOTHING;

