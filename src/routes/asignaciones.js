const express = require('express');
const pool = require('../db');
const requireAuth = require('../middleware/auth');

const router = express.Router();

router.get('/', requireAuth, async (req, res) => {
  try {
    const id_maestro = parseInt(req.query.id_maestro, 10);
    if (!id_maestro) {
      return res.status(400).json({ success: false, message: 'id_maestro es requerido' });
    }

    const result = await pool.query(
      `SELECT
         a.id_asignacion,
         a.id_maestro,
         m.nombre_completo AS nombre_maestro,
         mat.id_materia,
         mat.nombre_materia,
         mat.codigo_materia,
         g.id_grupo,
         g.nombre_grupo,
         s.id_semestre,
         s.numero_semestre,
         s.nombre_semestre,
         c.id_carrera,
         c.nombre_carrera,
         h.dia_semana,
         h.hora_inicio,
         h.hora_fin
       FROM Asignaciones a
       JOIN Maestros m  ON m.id_maestro  = a.id_maestro
       JOIN Materias mat ON mat.id_materia = a.id_materia
       JOIN Grupos g   ON g.id_grupo   = a.id_grupo
       JOIN Semestres s ON s.id_semestre = g.id_semestre
       JOIN Carreras c ON c.id_carrera = g.id_carrera
       JOIN Horarios h ON h.id_horario = a.id_horario
       WHERE a.id_maestro = $1 AND g.activo = TRUE
       ORDER BY h.dia_semana, h.hora_inicio`,
      [id_maestro]
    );

    return res.json(result.rows);
  } catch (err) {
    console.error('Error en asignaciones:', err.message);
    return res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

module.exports = router;
