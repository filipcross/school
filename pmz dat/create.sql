CREATE TABLE Server (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ip_address VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE Service (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    port INT NOT NULL
);

CREATE TABLE Deployment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_id INT NOT NULL,
    service_id INT NOT NULL,
    deployed_at DATETIME NOT NULL,
    status ENUM('Installed', 'Started', 'Running', 'Stopped', 'Failed') NOT NULL,
    FOREIGN KEY (server_id) REFERENCES Server(id),
    FOREIGN KEY (service_id) REFERENCES Service(id)
);