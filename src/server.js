require('dotenv').config();
const express = require('express');
const session = require('express-session');

const authRoutes = require('./routes/auth');
const asignacionesRoutes = require('./routes/asignaciones');
const asistenciasRoutes = require('./routes/asistencias');

const app = express();

app.use(express.json({ limit: '10mb' }));

app.use(session({
  name: 'connect.sid',
  secret: process.env.SESSION_SECRET || 'secreto_provisional',
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    maxAge: 1000 * 60 * 60 * 8,
    sameSite: false,
  },
}));

app.use('/api', authRoutes);
app.use('/api/asignaciones', asignacionesRoutes);
app.use('/api/asistencias', asistenciasRoutes);

app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'API de asistencias activa' });
});

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Ruta no encontrada' });
});

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`API de asistencias corriendo en el puerto ${PORT}`);
});
