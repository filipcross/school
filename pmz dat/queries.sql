SELECT s.name AS server, se.name AS service, d.status
FROM Deployment d
JOIN Server s ON d.server_id = s.id;

SELECT server_id, COUNT(*) AS pocet_sluzeb
FROM Deployment;

SELECT COUNT(*) FROM Deployment WHERE status = 'Running';

SELECT * FROM Deployment
WHERE status = 'Running';