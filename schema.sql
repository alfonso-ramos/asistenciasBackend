-- ========================================
-- Esquema PostgreSQL de SistemaAsistenciaEscolar
-- Adaptado de database.sql (MySQL -> PostgreSQL)
-- ========================================

DROP TABLE IF EXISTS Asistencias CASCADE;
DROP TABLE IF EXISTS Atenciones_Alumnos CASCADE;
DROP TABLE IF EXISTS Alumnos CASCADE;
DROP TABLE IF EXISTS Asignaciones CASCADE;
DROP TABLE IF EXISTS Horarios CASCADE;
DROP TABLE IF EXISTS Grupos CASCADE;
DROP TABLE IF EXISTS PlanEstudios CASCADE;
DROP TABLE IF EXISTS Materias CASCADE;
DROP TABLE IF EXISTS Semestres CASCADE;
DROP TABLE IF EXISTS Maestros CASCADE;
DROP TABLE IF EXISTS Carreras CASCADE;

-- NIVEL 1: CARRERA
CREATE TABLE Carreras (
    id_carrera SERIAL PRIMARY KEY,
    nombre_carrera VARCHAR(100) NOT NULL,
    codigo_carrera VARCHAR(10) NOT NULL UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- NIVEL 2: SEMESTRE
CREATE TABLE Semestres (
    id_semestre SERIAL PRIMARY KEY,
    id_carrera INT NOT NULL,
    numero_semestre INT NOT NULL CHECK (numero_semestre BETWEEN 1 AND 12),
    nombre_semestre VARCHAR(50),
    FOREIGN KEY (id_carrera) REFERENCES Carreras(id_carrera) ON DELETE CASCADE,
    UNIQUE (id_carrera, numero_semestre)
);

-- NIVEL 3: MATERIAS
CREATE TABLE Materias (
    id_materia SERIAL PRIMARY KEY,
    id_carrera INT NOT NULL,
    nombre_materia VARCHAR(100) NOT NULL,
    codigo_materia VARCHAR(10) NOT NULL UNIQUE,
    tipo_materia VARCHAR(20) NOT NULL DEFAULT 'disciplinaria'
        CHECK (tipo_materia IN ('disciplinaria', 'profesional', 'tecnica')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carrera) REFERENCES Carreras(id_carrera) ON DELETE CASCADE
);

-- TABLA INTERMEDIA: PLAN DE ESTUDIOS
CREATE TABLE PlanEstudios (
    id_plan SERIAL PRIMARY KEY,
    id_carrera INT NOT NULL,
    id_semestre INT NOT NULL,
    id_materia INT NOT NULL,
    FOREIGN KEY (id_carrera) REFERENCES Carreras(id_carrera) ON DELETE CASCADE,
    FOREIGN KEY (id_semestre) REFERENCES Semestres(id_semestre) ON DELETE CASCADE,
    FOREIGN KEY (id_materia) REFERENCES Materias(id_materia) ON DELETE CASCADE,
    UNIQUE (id_carrera, id_semestre, id_materia)
);

-- MAESTROS (Usuarios del sistema)
CREATE TABLE Maestros (
    id_maestro SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(20) NOT NULL CHECK (tipo_usuario IN ('maestro', 'prefecto', 'admin')),
    nombre_completo VARCHAR(150) NOT NULL,
    apellido_paterno VARCHAR(50),
    apellido_materno VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- HORARIOS (Bloques de 50 minutos)
CREATE TABLE Horarios (
    id_horario SERIAL PRIMARY KEY,
    dia_semana VARCHAR(20) NOT NULL
        CHECK (dia_semana IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes')),
    bloque INT NOT NULL CHECK (bloque BETWEEN 1 AND 8),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    UNIQUE (dia_semana, bloque)
);

-- NIVEL 4: GRUPOS
CREATE TABLE Grupos (
    id_grupo SERIAL PRIMARY KEY,
    id_carrera INT NOT NULL,
    id_semestre INT NOT NULL,
    nombre_grupo VARCHAR(10) NOT NULL,
    turno VARCHAR(20) DEFAULT 'Matutino',
    periodo VARCHAR(20) NOT NULL CHECK (periodo IN ('Enero-Junio', 'Agosto-Enero')),
    anio INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carrera) REFERENCES Carreras(id_carrera) ON DELETE CASCADE,
    FOREIGN KEY (id_semestre) REFERENCES Semestres(id_semestre) ON DELETE RESTRICT,
    UNIQUE (id_carrera, id_semestre, nombre_grupo, periodo, anio)
);

-- ASIGNACIONES (Grupo + Materia + Maestro + Horario)
CREATE TABLE Asignaciones (
    id_asignacion SERIAL PRIMARY KEY,
    id_grupo INT NOT NULL,
    id_materia INT NOT NULL,
    id_maestro INT NOT NULL,
    id_horario INT NOT NULL,
    FOREIGN KEY (id_grupo) REFERENCES Grupos(id_grupo) ON DELETE CASCADE,
    FOREIGN KEY (id_materia) REFERENCES Materias(id_materia) ON DELETE CASCADE,
    FOREIGN KEY (id_maestro) REFERENCES Maestros(id_maestro) ON DELETE RESTRICT,
    FOREIGN KEY (id_horario) REFERENCES Horarios(id_horario) ON DELETE RESTRICT,
    UNIQUE (id_grupo, id_horario),
    UNIQUE (id_maestro, id_horario)
);

-- NIVEL 5: ALUMNOS
CREATE TABLE Alumnos (
    id_alumno SERIAL PRIMARY KEY,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    nombre_alumno VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    id_carrera INT NOT NULL,
    id_semestre INT NOT NULL,
    id_grupo INT NOT NULL,
    foto_base64 TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carrera) REFERENCES Carreras(id_carrera) ON DELETE RESTRICT,
    FOREIGN KEY (id_semestre) REFERENCES Semestres(id_semestre) ON DELETE RESTRICT,
    FOREIGN KEY (id_grupo) REFERENCES Grupos(id_grupo) ON DELETE RESTRICT
);

-- NIVEL 6: ASISTENCIAS
CREATE TABLE Asistencias (
    id_asistencia SERIAL PRIMARY KEY,
    id_alumno INT NOT NULL,
    id_asignacion INT NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('asistencia', 'falta', 'justificante')),
    hora_registro TIME DEFAULT CURRENT_TIME,
    observaciones TEXT,
    FOREIGN KEY (id_alumno) REFERENCES Alumnos(id_alumno) ON DELETE CASCADE,
    FOREIGN KEY (id_asignacion) REFERENCES Asignaciones(id_asignacion) ON DELETE CASCADE,
    UNIQUE (id_alumno, id_asignacion, fecha)
);

-- ATENCIONES (prefecto atiende caso de alumno)
CREATE TABLE Atenciones_Alumnos (
    id_atencion SERIAL PRIMARY KEY,
    id_alumno INT NOT NULL,
    id_prefecto INT NOT NULL,
    fecha_atencion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas TEXT,
    FOREIGN KEY (id_alumno) REFERENCES Alumnos(id_alumno) ON DELETE CASCADE,
    FOREIGN KEY (id_prefecto) REFERENCES Maestros(id_maestro) ON DELETE CASCADE
);

CREATE INDEX idx_alumno ON Alumnos(id_grupo);
CREATE INDEX idx_asistencia_alumno ON Asistencias(id_alumno);
CREATE INDEX idx_asistencia_asignacion ON Asistencias(id_asignacion);
CREATE INDEX idx_asistencia_fecha ON Asistencias(fecha);
