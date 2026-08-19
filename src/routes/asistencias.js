const express = require('express');
const pool = require('../db');
const requireAuth = require('../middleware/auth');

const router = express.Router();

const ESTADOS_VALIDOS = ['asistencia', 'falta', 'justificante'];

router.get('/lista-alumnos', requireAuth, async (req, res) => {
  try {
    const id_asignacion = parseInt(req.query.id_asignacion, 10);
    if (!id_asignacion) {
      return res.status(400).json({ success: false, message: 'id_asignacion es requerido' });
    }

    const asigResult = await pool.query(
      `SELECT a.id_asignacion, mat.nombre_materia, g.nombre_grupo, h.dia_semana, h.hora_inicio
       FROM Asignaciones a
       JOIN Materias mat ON mat.id_materia = a.id_materia
       JOIN Grupos g   ON g.id_grupo   = a.id_grupo
       JOIN Horarios h ON h.id_horario = a.id_horario
       WHERE a.id_asignacion = $1`,
      [id_asignacion]
    );

    if (asigResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Asignación no encontrada' });
    }

    const asignacion = asigResult.rows[0];

    const alumnosResult = await pool.query(
      `SELECT id_alumno, matricula,
              concat_ws(' ', apellido_paterno, apellido_materno, nombre_alumno) AS nombre_completo,
              foto_base64
       FROM Alumnos
       WHERE id_grupo = (SELECT id_grupo FROM Asignaciones WHERE id_asignacion = $1)
         AND activo = TRUE
       ORDER BY apellido_paterno, apellido_materno, nombre_alumno`,
      [id_asignacion]
    );

    return res.json({ asignacion, alumnos: alumnosResult.rows });
  } catch (err) {
    console.error('Error en lista-alumnos:', err.message);
    return res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

router.post('/registrar', requireAuth, async (req, res) => {
  const client = await pool.connect();
  try {
    const { id_asignacion, fecha, asistencias } = req.body;

    if (!id_asignacion || !fecha || !Array.isArray(asistencias) || asistencias.length === 0) {
      return res.status(400).json({ success: false, message: 'Datos incompletos' });
    }

    await client.query('BEGIN');

    const existing = await client.query(
      `SELECT COUNT(*)::int AS total FROM Asistencias
       WHERE id_asignacion = $1 AND fecha = $2`,
      [id_asignacion, fecha]
    );
    const actualizadas = existing.rows[0].total > 0;

    for (const item of asistencias) {
      const { id_alumno, estado, observaciones } = item;
      if (!ESTADOS_VALIDOS.includes(estado)) {
        throw new Error(`Estado inválido: ${estado}`);
      }
      await client.query(
        `INSERT INTO Asistencias (id_alumno, id_asignacion, fecha, estado, observaciones)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (id_alumno, id_asignacion, fecha)
         DO UPDATE SET estado = EXCLUDED.estado, observaciones = EXCLUDED.observaciones`,
        [id_alumno, id_asignacion, fecha, estado, observaciones ?? null]
      );
    }

    await client.query('COMMIT');
    return res.status(201).json({
      success: true,
      message: 'Asistencias registradas exitosamente',
      data: {
        registradas: asistencias.length,
        fecha,
        actualizadas,
      },
    });
  } catch (err) {
    await client.query('ROLLBACK');
    if (err.message && err.message.startsWith('Estado inválido')) {
      return res.status(400).json({ success: false, message: err.message });
    }
    console.error('Error en registrar:', err.message);
    return res.status(500).json({ success: false, message: 'Error interno del servidor' });
  } finally {
    client.release();
  }
});

module.exports = router;
