-- ========================================
-- DATOS DE PRUEBA basados en appAsistencia.md
-- ========================================

-- Carrera
INSERT INTO Carreras (id_carrera, nombre_carrera, codigo_carrera) VALUES
(2, 'INFORMATICA', 'INFO');

-- Semestre 5
INSERT INTO Semestres (id_semestre, id_carrera, numero_semestre, nombre_semestre) VALUES
(15, 2, 5, 'Quinto Semestre');

-- Materia
INSERT INTO Materias (id_materia, id_carrera, nombre_materia, codigo_materia, tipo_materia) VALUES
(95, 2, 'Programación con sistemas gestores de base de datos', 'PSGB20', 'profesional');

-- Plan de estudios
INSERT INTO PlanEstudios (id_carrera, id_semestre, id_materia) VALUES
(2, 15, 95);

-- Maestro de pruebas: rcuadras / rcuadras
INSERT INTO Maestros (id_maestro, nombre_usuario, contrasena, tipo_usuario, nombre_completo, activo) VALUES
(26, 'rcuadras', 'rcuadras', 'maestro', 'RAMÓN PATRICIO VELÁZQUEZ CUADRAS', TRUE);

-- Horarios usados por las asignaciones de la documentación
INSERT INTO Horarios (id_horario, dia_semana, bloque, hora_inicio, hora_fin) VALUES
(1, 'Martes',    1, '07:00:00', '07:50:00'),
(2, 'Martes',    2, '07:50:00', '08:40:00'),
(3, 'Martes',    3, '08:40:00', '09:30:00'),
(4, 'Miércoles', 4, '10:00:00', '10:50:00'),
(5, 'Jueves',    1, '07:00:00', '07:50:00'),
(6, 'Jueves',    2, '07:50:00', '08:40:00'),
(7, 'Jueves',    3, '08:40:00', '09:30:00'),
(8, 'Viernes',   1, '07:00:00', '07:50:00'),
(9, 'Viernes',   2, '07:50:00', '08:40:00'),
(10, 'Viernes',  3, '08:40:00', '09:30:00');

-- Grupos
INSERT INTO Grupos (id_grupo, id_carrera, id_semestre, nombre_grupo, turno, periodo, anio) VALUES
(8, 2, 15, '507 INFO23', 'Matutino', 'Agosto-Enero', 2025),
(9, 2, 15, '508 INFO23', 'Matutino', 'Agosto-Enero', 2025);

-- Asignaciones de rcuadras (10 de la documentación)
INSERT INTO Asignaciones (id_asignacion, id_grupo, id_materia, id_maestro, id_horario) VALUES
(87,  8, 95, 26, 5),
(88,  8, 95, 26, 6),
(83,  8, 95, 26, 4),
(94,  8, 95, 26, 8),
(75,  8, 95, 26, 3),
(108, 9, 95, 26, 1),
(109, 9, 95, 26, 2),
(130, 9, 95, 26, 9),
(124, 9, 95, 26, 7),
(131, 9, 95, 26, 10);

-- Alumnos de ejemplo
INSERT INTO Alumnos (id_alumno, matricula, nombre_alumno, apellido_paterno, apellido_materno, id_carrera, id_semestre, id_grupo, foto_base64) VALUES
(1, '20260001', 'Juan Carlos', 'García',     'López',      2, 15, 8, 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8Af/9k='),
(2, '20260002', 'María',      'Hernández',  'Pérez',      2, 15, 8, NULL),
(3, '20260003', 'Pedro',      'Martínez',   'Rodríguez',  2, 15, 8, NULL),
(4, '20260004', 'Ana',        'Sánchez',    'González',   2, 15, 8, NULL),
(5, '20260005', 'Luis',       'Fernández',  'Ramírez',    2, 15, 9, NULL),
(6, '20260006', 'Sofía',      'Torres',     'Flores',     2, 15, 9, NULL),
(7, '20260007', 'Diego',      'Morales',    'Vargas',     2, 15, 9, NULL),
(8, '20260008', 'Valentina',  'Castro',     'Jiménez',    2, 15, 9, NULL);

-- Reiniciar secuencias para respetar los IDs explícitos
SELECT setval(pg_get_serial_sequence('carreras', 'id_carrera'), (SELECT COALESCE(MAX(id_carrera), 1) FROM carreras));
SELECT setval(pg_get_serial_sequence('semestres', 'id_semestre'), (SELECT COALESCE(MAX(id_semestre), 1) FROM semestres));
SELECT setval(pg_get_serial_sequence('materias', 'id_materia'), (SELECT COALESCE(MAX(id_materia), 1) FROM materias));
SELECT setval(pg_get_serial_sequence('planestudios', 'id_plan'), (SELECT COALESCE(MAX(id_plan), 1) FROM planestudios));
SELECT setval(pg_get_serial_sequence('maestros', 'id_maestro'), (SELECT COALESCE(MAX(id_maestro), 1) FROM maestros));
SELECT setval(pg_get_serial_sequence('horarios', 'id_horario'), (SELECT COALESCE(MAX(id_horario), 1) FROM horarios));
SELECT setval(pg_get_serial_sequence('grupos', 'id_grupo'), (SELECT COALESCE(MAX(id_grupo), 1) FROM grupos));
SELECT setval(pg_get_serial_sequence('asignaciones', 'id_asignacion'), (SELECT COALESCE(MAX(id_asignacion), 1) FROM asignaciones));
SELECT setval(pg_get_serial_sequence('alumnos', 'id_alumno'), (SELECT COALESCE(MAX(id_alumno), 1) FROM alumnos));
SELECT setval(pg_get_serial_sequence('asistencias', 'id_asistencia'), (SELECT COALESCE(MAX(id_asistencia), 1) FROM asistencias));
