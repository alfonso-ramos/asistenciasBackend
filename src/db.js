const { Pool } = require('pg');
const parseConnectionString = require('pg-connection-string').parse;

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('ERROR: Falta la variable DATABASE_URL.');
  console.error('  Ejemplo: DATABASE_URL=postgres://usuario:contrasena@localhost:5432/asistencia');
  process.exit(1);
}

let parsed;
try {
  parsed = parseConnectionString(connectionString);
} catch (err) {
  console.error('ERROR: DATABASE_URL no es valida:', err.message);
  console.error('  Recibida:', connectionString);
  process.exit(1);
}

if (typeof parsed.password !== 'string' || parsed.password === '') {
  console.error('ERROR: DATABASE_URL no incluye contrasena.');
  console.error('  Formato correcto: postgres://usuario:CONTRASENA@host:5432/nombre_bd');
  console.error('  Recibida:', connectionString);
  process.exit(1);
}

const config = { connectionString };

if (process.env.NODE_ENV === 'production') {
  config.ssl = { rejectUnauthorized: false };
}

module.exports = new Pool(config);