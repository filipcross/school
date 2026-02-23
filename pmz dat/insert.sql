INSERT INTO Server (name, ip_address) VALUES
('Server1', '192.168.0.1'),
('Server2', '192.168.0.2'),
('Server3', '192.168.0.3'),
('Server4', '192.168.0.4'),
('Server5', '192.168.0.5');

INSERT INTO Service (name, port) VALUES
('Web', 80),
('Database', 3306),
('DNS', 53),
('VPN', 1194),
('Mail', 25);

INSERT INTO Deployment (server_id, service_id, deployed_at, status) VALUES
(1, 1, NOW(), 'Running'),
(1, 2, NOW(), 'Running'),
(2, 3, NOW(), 'Stopped'),
(3, 4, NOW(), 'Running'),
(4, 5, NOW(), 'Failed');