SELECT * FROM Server;

INSERT INTO Service (name, port) VALUES ('FTP', 21);

UPDATE Deployment SET status = 'Running' WHERE id = 3;

DELETE FROM Service WHERE id = 6;