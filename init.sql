CREATE DATABASE IF NOT EXISTS universidad;
USE universidad;

CREATE TABLE IF NOT EXISTS profesor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    especialidad VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO profesor (nombre, apellido, email, especialidad) VALUES
('Juan', 'Pérez', 'juan.perez@universidad.edu', 'Matemáticas'),
('María', 'García', 'maria.garcia@universidad.edu', 'Física'),
('Carlos', 'López', 'carlos.lopez@universidad.edu', 'Programación');
