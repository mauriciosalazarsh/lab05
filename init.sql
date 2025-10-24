CREATE DATABASE IF NOT EXISTS universidad;
USE universidad;

CREATE TABLE estudiante (
    estudiante_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    fecha_nacimiento DATE NOT NULL,
    direccion VARCHAR(200),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE profesor (
    profesor_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    especialidad VARCHAR(100),
    titulo_academico VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE facultad (
    facultad_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    ubicacion VARCHAR(100),
    decano VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE carrera (
    carrera_id INT AUTO_INCREMENT PRIMARY KEY,
    facultad_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_semestres INT NOT NULL,
    titulo_otorgado VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_facultad FOREIGN KEY (facultad_id) REFERENCES facultad(facultad_id) ON DELETE RESTRICT,
    CONSTRAINT uk_carrera_nombre UNIQUE (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE curso (
    curso_id INT AUTO_INCREMENT PRIMARY KEY,
    carrera_id INT NOT NULL,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    creditos INT NOT NULL,
    nivel_semestre INT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_carrera FOREIGN KEY (carrera_id) REFERENCES carrera(carrera_id) ON DELETE RESTRICT,
    CONSTRAINT ck_creditos CHECK (creditos > 0),
    CONSTRAINT ck_nivel_semestre CHECK (nivel_semestre > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE prerrequisito (
    prerrequisito_id INT AUTO_INCREMENT PRIMARY KEY,
    curso_id INT NOT NULL,
    curso_req_id INT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_curso FOREIGN KEY (curso_id) REFERENCES curso(curso_id) ON DELETE CASCADE,
    CONSTRAINT fk_curso_req FOREIGN KEY (curso_req_id) REFERENCES curso(curso_id) ON DELETE CASCADE,
    CONSTRAINT uk_prerrequisito UNIQUE (curso_id, curso_req_id),
    CONSTRAINT ck_curso_diferente CHECK (curso_id != curso_req_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE seccion (
    seccion_id INT AUTO_INCREMENT PRIMARY KEY,
    curso_id INT NOT NULL,
    profesor_id INT NOT NULL,
    codigo VARCHAR(20) NOT NULL,
    capacidad_maxima INT NOT NULL,
    aula VARCHAR(50),
    horario VARCHAR(50),
    dias VARCHAR(50),
    periodo_academico VARCHAR(20) NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_seccion_curso FOREIGN KEY (curso_id) REFERENCES curso(curso_id) ON DELETE RESTRICT,
    CONSTRAINT fk_seccion_profesor FOREIGN KEY (profesor_id) REFERENCES profesor(profesor_id) ON DELETE RESTRICT,
    CONSTRAINT uk_seccion_periodo UNIQUE (curso_id, codigo, periodo_academico),
    CONSTRAINT ck_capacidad_maxima CHECK (capacidad_maxima > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE matricula (
    matricula_id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    seccion_id INT NOT NULL,
    fecha_matricula DATE NOT NULL DEFAULT (CURRENT_DATE),
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    costo DECIMAL(10, 2) NOT NULL,
    metodo_pago VARCHAR(50),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_matricula_estudiante FOREIGN KEY (estudiante_id) REFERENCES estudiante(estudiante_id) ON DELETE RESTRICT,
    CONSTRAINT fk_matricula_seccion FOREIGN KEY (seccion_id) REFERENCES seccion(seccion_id) ON DELETE RESTRICT,
    CONSTRAINT uk_matricula_seccion UNIQUE (estudiante_id, seccion_id),
    CONSTRAINT ck_estado CHECK (estado IN ('PENDIENTE', 'PAGADO', 'ANULADO', 'COMPLETADO')),
    CONSTRAINT ck_costo CHECK (costo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pago (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    matricula_id INT NOT NULL,
    fecha_pago DATE NOT NULL DEFAULT (CURRENT_DATE),
    monto DECIMAL(10, 2) NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    referencia VARCHAR(100),
    estado VARCHAR(20) NOT NULL DEFAULT 'PROCESADO',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pago_matricula FOREIGN KEY (matricula_id) REFERENCES matricula(matricula_id) ON DELETE RESTRICT,
    CONSTRAINT ck_monto CHECK (monto > 0),
    CONSTRAINT ck_estado_pago CHECK (estado IN ('PENDIENTE', 'PROCESADO', 'RECHAZADO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE calificacion (
    calificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    matricula_id INT NOT NULL,
    nota DECIMAL(5, 2),
    observacion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_calificacion_matricula FOREIGN KEY (matricula_id) REFERENCES matricula(matricula_id) ON DELETE RESTRICT,
    CONSTRAINT uk_calificacion_matricula UNIQUE (matricula_id),
    CONSTRAINT ck_nota CHECK (nota >= 0 AND nota <= 20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_estudiante_apellido ON estudiante(apellido);
CREATE INDEX idx_profesor_apellido ON profesor(apellido);
CREATE INDEX idx_curso_nombre ON curso(nombre);
CREATE INDEX idx_curso_codigo ON curso(codigo);
CREATE INDEX idx_matricula_estudiante ON matricula(estudiante_id);
CREATE INDEX idx_matricula_seccion ON matricula(seccion_id);
CREATE INDEX idx_seccion_curso ON seccion(curso_id);
CREATE INDEX idx_seccion_profesor ON seccion(profesor_id);
CREATE INDEX idx_seccion_periodo ON seccion(periodo_academico);
CREATE INDEX idx_carrera_facultad ON carrera(facultad_id);

INSERT INTO estudiante (nombre, apellido, dni, email, telefono, fecha_nacimiento, direccion) VALUES
('Juan', 'Pérez García', '12345678', 'juan.perez@universidad.edu', '987654321', '2002-05-15', 'Av. Principal 123, Lima'),
('María', 'López Rodríguez', '23456789', 'maria.lopez@universidad.edu', '987654322', '2001-08-22', 'Jr. Los Olivos 456, Lima'),
('Carlos', 'Ramírez Silva', '34567890', 'carlos.ramirez@universidad.edu', '987654323', '2003-02-10', 'Calle Las Flores 789, Callao'),
('Ana', 'Torres Mendoza', '45678901', 'ana.torres@universidad.edu', '987654324', '2002-11-30', 'Av. Universitaria 321, Lima'),
('Luis', 'Gonzales Vega', '56789012', 'luis.gonzales@universidad.edu', '987654325', '2001-07-18', 'Jr. Libertad 654, Lima'),
('Sofia', 'Martínez Cruz', '67890123', 'sofia.martinez@universidad.edu', '987654326', '2003-04-25', 'Av. Los Próceres 987, San Isidro'),
('Diego', 'Fernández Rojas', '78901234', 'diego.fernandez@universidad.edu', '987654327', '2002-09-12', 'Calle Real 147, Miraflores'),
('Laura', 'Sánchez Vargas', '89012345', 'laura.sanchez@universidad.edu', '987654328', '2001-12-05', 'Jr. San Martín 258, Lima'),
('Roberto', 'Castro Flores', '90123456', 'roberto.castro@universidad.edu', '987654329', '2003-01-20', 'Av. Javier Prado 369, San Borja'),
('Valentina', 'Herrera Díaz', '01234567', 'valentina.herrera@universidad.edu', '987654330', '2002-06-08', 'Calle Luna 741, Surco');

INSERT INTO profesor (nombre, apellido, dni, email, telefono, especialidad, titulo_academico) VALUES
('Alberto', 'Gutiérrez Ramos', '11111111', 'alberto.gutierrez@universidad.edu', '999111222', 'Ingeniería de Software', 'Doctor en Ciencias de la Computación'),
('Carmen', 'Ruiz Paredes', '22222222', 'carmen.ruiz@universidad.edu', '999222333', 'Base de Datos', 'Magister en Informática'),
('Fernando', 'Morales Campos', '33333333', 'fernando.morales@universidad.edu', '999333444', 'Redes y Comunicaciones', 'Doctor en Telecomunicaciones'),
('Patricia', 'Silva Montoya', '44444444', 'patricia.silva@universidad.edu', '999444555', 'Inteligencia Artificial', 'Doctor en Ciencias de la Computación'),
('Ricardo', 'Navarro Ortiz', '55555555', 'ricardo.navarro@universidad.edu', '999555666', 'Administración de Empresas', 'MBA - Magister en Administración'),
('Gabriela', 'Rojas Delgado', '66666666', 'gabriela.rojas@universidad.edu', '999666777', 'Contabilidad', 'Contador Público Colegiado'),
('Javier', 'Mendoza Salas', '77777777', 'javier.mendoza@universidad.edu', '999777888', 'Estructuras de Datos', 'Magister en Ciencias de la Computación'),
('Isabel', 'Cruz Zavala', '88888888', 'isabel.cruz@universidad.edu', '999888999', 'Matemáticas', 'Doctor en Matemáticas Aplicadas'),
('Miguel', 'Vega Torres', '99999999', 'miguel.vega@universidad.edu', '999999000', 'Física', 'Doctor en Física'),
('Elena', 'Paredes Luna', '10101010', 'elena.paredes@universidad.edu', '999000111', 'Programación', 'Magister en Ingeniería de Software');

INSERT INTO facultad (nombre, descripcion, ubicacion, decano) VALUES
('Facultad de Ingeniería', 'Facultad dedicada a las carreras de ingeniería y tecnología', 'Edificio A - Campus Principal', 'Dr. Jorge Ramírez'),
('Facultad de Ciencias Empresariales', 'Facultad enfocada en administración, contabilidad y negocios', 'Edificio B - Campus Principal', 'Dra. Martha Sánchez'),
('Facultad de Ciencias', 'Facultad de ciencias básicas y aplicadas', 'Edificio C - Campus Principal', 'Dr. Pedro Villanueva'),
('Facultad de Humanidades', 'Facultad de estudios humanísticos y sociales', 'Edificio D - Campus Norte', 'Dra. Rosa Mendoza');

INSERT INTO carrera (facultad_id, nombre, descripcion, duracion_semestres, titulo_otorgado) VALUES
(1, 'Ingeniería de Sistemas', 'Carrera enfocada en el desarrollo de software y sistemas informáticos', 10, 'Ingeniero de Sistemas'),
(1, 'Ingeniería Industrial', 'Carrera orientada a la optimización de procesos industriales', 10, 'Ingeniero Industrial'),
(1, 'Ingeniería Civil', 'Carrera dedicada al diseño y construcción de infraestructura', 10, 'Ingeniero Civil'),
(2, 'Administración de Empresas', 'Carrera enfocada en la gestión y dirección de organizaciones', 10, 'Licenciado en Administración'),
(2, 'Contabilidad', 'Carrera especializada en contabilidad y finanzas', 10, 'Contador Público'),
(3, 'Matemática', 'Carrera de estudios avanzados en matemáticas', 10, 'Licenciado en Matemática'),
(4, 'Psicología', 'Carrera del comportamiento humano y salud mental', 10, 'Licenciado en Psicología');

INSERT INTO curso (carrera_id, codigo, nombre, descripcion, creditos, nivel_semestre) VALUES
(1, 'IS101', 'Introducción a la Programación', 'Fundamentos de programación y lógica computacional', 4, 1),
(1, 'IS102', 'Matemática Básica', 'Álgebra y trigonometría para ingeniería', 4, 1),
(1, 'IS201', 'Programación Orientada a Objetos', 'Paradigma de programación orientada a objetos', 4, 2),
(1, 'IS202', 'Estructura de Datos', 'Estructuras de datos fundamentales y algoritmos', 4, 2),
(1, 'IS301', 'Base de Datos', 'Diseño e implementación de bases de datos', 4, 3),
(1, 'IS302', 'Desarrollo Web', 'Tecnologías para desarrollo de aplicaciones web', 4, 3),
(1, 'IS401', 'Ingeniería de Software', 'Metodologías y procesos de desarrollo de software', 4, 4),
(1, 'IS402', 'Inteligencia Artificial', 'Fundamentos de IA y machine learning', 4, 4),
(4, 'AD101', 'Fundamentos de Administración', 'Principios básicos de la administración', 3, 1),
(4, 'AD102', 'Contabilidad General', 'Introducción a la contabilidad financiera', 3, 1),
(4, 'AD201', 'Marketing', 'Estrategias de marketing y comportamiento del consumidor', 3, 2),
(4, 'AD301', 'Finanzas Corporativas', 'Gestión financiera empresarial', 4, 3),
(5, 'CO101', 'Contabilidad Básica', 'Fundamentos de contabilidad', 4, 1),
(5, 'CO201', 'Contabilidad de Costos', 'Sistemas de costeo y control de costos', 4, 2),
(5, 'CO301', 'Auditoría', 'Principios y técnicas de auditoría', 4, 3);

INSERT INTO prerrequisito (curso_id, curso_req_id) VALUES
(3, 1),
(4, 3),
(5, 4),
(6, 3),
(7, 5),
(8, 4),
(14, 13),
(15, 14);

INSERT INTO seccion (curso_id, profesor_id, codigo, capacidad_maxima, aula, horario, dias, periodo_academico, fecha_inicio, fecha_fin) VALUES
(1, 1, 'A', 30, 'LAB-101', '08:00-10:00', 'Lunes,Miércoles', '2025-1', '2025-03-10', '2025-07-15'),
(1, 10, 'B', 30, 'LAB-102', '10:00-12:00', 'Martes,Jueves', '2025-1', '2025-03-10', '2025-07-15'),
(2, 8, 'A', 35, 'AULA-201', '14:00-16:00', 'Lunes,Miércoles', '2025-1', '2025-03-10', '2025-07-15'),
(3, 1, 'A', 30, 'LAB-103', '08:00-10:00', 'Martes,Jueves', '2025-1', '2025-03-10', '2025-07-15'),
(4, 7, 'A', 30, 'LAB-104', '10:00-12:00', 'Lunes,Miércoles', '2025-1', '2025-03-10', '2025-07-15'),
(5, 2, 'A', 30, 'LAB-201', '14:00-16:00', 'Martes,Jueves', '2025-1', '2025-03-10', '2025-07-15'),
(6, 10, 'A', 25, 'LAB-202', '16:00-18:00', 'Lunes,Miércoles', '2025-1', '2025-03-10', '2025-07-15'),
(7, 1, 'A', 30, 'AULA-301', '08:00-10:00', 'Lunes,Miércoles,Viernes', '2025-1', '2025-03-10', '2025-07-15'),
(8, 4, 'A', 25, 'LAB-301', '14:00-16:00', 'Martes,Jueves', '2025-1', '2025-03-10', '2025-07-15'),
(9, 5, 'A', 40, 'AULA-101', '08:00-10:00', 'Lunes,Miércoles', '2025-1', '2025-03-10', '2025-07-15'),
(10, 6, 'A', 40, 'AULA-102', '10:00-12:00', 'Martes,Jueves', '2025-1', '2025-03-10', '2025-07-15'),
(11, 5, 'A', 35, 'AULA-103', '14:00-16:00', 'Lunes,Miércoles', '2025-1', '2025-03-10', '2025-07-15'),
(12, 5, 'A', 35, 'AULA-104', '16:00-18:00', 'Martes,Jueves', '2025-1', '2025-03-10', '2025-07-15'),
(13, 6, 'A', 35, 'AULA-105', '08:00-10:00', 'Lunes,Miércoles', '2025-1', '2025-03-10', '2025-07-15'),
(14, 6, 'A', 30, 'AULA-106', '10:00-12:00', 'Martes,Jueves', '2025-1', '2025-03-10', '2025-07-15');

INSERT INTO matricula (estudiante_id, seccion_id, fecha_matricula, estado, costo, metodo_pago) VALUES
(1, 1, '2025-02-15', 'PAGADO', 350.00, 'Tarjeta de crédito'),
(1, 3, '2025-02-15', 'PAGADO', 350.00, 'Tarjeta de crédito'),
(2, 2, '2025-02-16', 'PAGADO', 350.00, 'Transferencia bancaria'),
(2, 3, '2025-02-16', 'PAGADO', 350.00, 'Transferencia bancaria'),
(3, 1, '2025-02-17', 'PAGADO', 350.00, 'Efectivo'),
(3, 3, '2025-02-17', 'PAGADO', 350.00, 'Efectivo'),
(4, 4, '2025-02-18', 'PAGADO', 350.00, 'Tarjeta de débito'),
(4, 5, '2025-02-18', 'PAGADO', 350.00, 'Tarjeta de débito'),
(5, 4, '2025-02-19', 'PAGADO', 350.00, 'Transferencia bancaria'),
(5, 5, '2025-02-19', 'PAGADO', 350.00, 'Transferencia bancaria'),
(6, 6, '2025-02-20', 'PAGADO', 350.00, 'Tarjeta de crédito'),
(6, 7, '2025-02-20', 'PAGADO', 350.00, 'Tarjeta de crédito'),
(7, 6, '2025-02-21', 'COMPLETADO', 350.00, 'Efectivo'),
(7, 7, '2025-02-21', 'COMPLETADO', 350.00, 'Efectivo'),
(8, 8, '2025-02-22', 'PAGADO', 350.00, 'Transferencia bancaria'),
(8, 9, '2025-02-22', 'PAGADO', 350.00, 'Transferencia bancaria'),
(9, 10, '2025-02-23', 'PAGADO', 300.00, 'Tarjeta de crédito'),
(9, 11, '2025-02-23', 'PAGADO', 300.00, 'Tarjeta de crédito'),
(10, 10, '2025-02-24', 'PAGADO', 300.00, 'Efectivo'),
(10, 11, '2025-02-24', 'PAGADO', 300.00, 'Efectivo');

INSERT INTO pago (matricula_id, fecha_pago, monto, metodo_pago, referencia, estado) VALUES
(1, '2025-02-15', 350.00, 'Tarjeta de crédito', 'REF-TC-001', 'PROCESADO'),
(2, '2025-02-15', 350.00, 'Tarjeta de crédito', 'REF-TC-002', 'PROCESADO'),
(3, '2025-02-16', 350.00, 'Transferencia bancaria', 'REF-TB-001', 'PROCESADO'),
(4, '2025-02-16', 350.00, 'Transferencia bancaria', 'REF-TB-002', 'PROCESADO'),
(5, '2025-02-17', 350.00, 'Efectivo', 'REF-EF-001', 'PROCESADO'),
(6, '2025-02-17', 350.00, 'Efectivo', 'REF-EF-002', 'PROCESADO'),
(7, '2025-02-18', 350.00, 'Tarjeta de débito', 'REF-TD-001', 'PROCESADO'),
(8, '2025-02-18', 350.00, 'Tarjeta de débito', 'REF-TD-002', 'PROCESADO'),
(9, '2025-02-19', 350.00, 'Transferencia bancaria', 'REF-TB-003', 'PROCESADO'),
(10, '2025-02-19', 350.00, 'Transferencia bancaria', 'REF-TB-004', 'PROCESADO'),
(11, '2025-02-20', 350.00, 'Tarjeta de crédito', 'REF-TC-003', 'PROCESADO'),
(12, '2025-02-20', 350.00, 'Tarjeta de crédito', 'REF-TC-004', 'PROCESADO'),
(13, '2025-02-21', 350.00, 'Efectivo', 'REF-EF-003', 'PROCESADO'),
(14, '2025-02-21', 350.00, 'Efectivo', 'REF-EF-004', 'PROCESADO'),
(15, '2025-02-22', 350.00, 'Transferencia bancaria', 'REF-TB-005', 'PROCESADO'),
(16, '2025-02-22', 350.00, 'Transferencia bancaria', 'REF-TB-006', 'PROCESADO'),
(17, '2025-02-23', 300.00, 'Tarjeta de crédito', 'REF-TC-005', 'PROCESADO'),
(18, '2025-02-23', 300.00, 'Tarjeta de crédito', 'REF-TC-006', 'PROCESADO'),
(19, '2025-02-24', 300.00, 'Efectivo', 'REF-EF-005', 'PROCESADO'),
(20, '2025-02-24', 300.00, 'Efectivo', 'REF-EF-006', 'PROCESADO');

INSERT INTO calificacion (matricula_id, nota, observacion) VALUES
(1, 16.5, 'Excelente desempeño en el curso'),
(2, 14.0, 'Buen rendimiento académico'),
(3, 15.5, 'Muy buen estudiante, participativo'),
(4, 13.0, 'Rendimiento satisfactorio'),
(5, 17.0, 'Destacado en prácticas de laboratorio'),
(6, 12.5, 'Aprobado, necesita mejorar en teoría'),
(7, 18.0, 'Excelente alumno, uno de los mejores del curso'),
(8, 14.5, 'Buen desempeño general'),
(9, 16.0, 'Muy buen nivel académico'),
(10, 15.0, 'Buen estudiante, constante en su trabajo'),
(11, 13.5, 'Aprobado con rendimiento satisfactorio'),
(12, 17.5, 'Excelente trabajo en proyectos'),
(13, 19.0, 'Sobresaliente, mejor alumno del curso'),
(14, 16.5, 'Muy buen rendimiento y participación');
