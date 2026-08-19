const express = require('express');
const pool = require('../db');

const router = express.Router();

router.post('/login', async (req, res) => {
  try {
    const { usuario, contrasena } = req.body;
    if (!usuario || !contrasena) {
      return res.status(401).json({ success: false, message: 'Credenciales incorrectas' });
    }

    const result = await pool.query(
      `SELECT id_maestro, nombre_completo, nombre_usuario, tipo_usuario
       FROM Maestros
       WHERE nombre_usuario = $1 AND contrasena = $2 AND activo = TRUE`,
      [usuario, contrasena]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Credenciales incorrectas' });
    }

    const m = result.rows[0];
    const user = {
      id: m.id_maestro,
      nombre: m.nombre_completo,
      usuario: m.nombre_usuario,
      tipoUsuario: m.tipo_usuario,
    };

    req.session.user = user;
    return res.json({ success: true, user });
  } catch (err) {
    console.error('Error en login:', err.message);
    return res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

router.get('/session', (req, res) => {
  if (req.session && req.session.user) {
    return res.json({ success: true, user: req.session.user });
  }
  return res.status(401).json({ success: false, message: 'No hay sesión activa' });
});

router.post('/logout', (req, res) => {
  req.session.destroy(() => {
    res.clearCookie('connect.sid');
    return res.json({ success: true, message: 'Sesión cerrada correctamente' });
  });
});

module.exports = router;
