const { Pool } = require('pg');
const parseConnectionString = require('pg-connection-string').parse;

function fail(message) {
  console.error('ERROR:', message);
  console.error('  Opcion A (individual): PGUSER + PGPASSWORD + PGHOST + PGPORT + PGDATABASE');
  console.error('  Opcion B (URL):        DATABASE_URL=postgres://usuario:contrasena@host:5432/nombre_bd');
  process.exit(1);
}

function buildConfig() {
  const { PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD, DATABASE_URL, PGSSLMODE, NODE_ENV } = process.env;

  let config;

  if (PGHOST && PGDATABASE && PGUSER && PGPASSWORD) {
    config = {
      host: PGHOST,
      port: PGPORT ? parseInt(PGPORT, 10) : 5432,
      database: PGDATABASE,
      user: PGUSER,
      password: PGPASSWORD,
    };
  } else if (DATABASE_URL) {
    let parsed;
    try {
      parsed = parseConnectionString(DATABASE_URL);
    } catch (err) {
      console.error('ERROR: DATABASE_URL no es valida:', err.message);
      console.error('  Recibida:', DATABASE_URL);
      process.exit(1);
    }
    if (typeof parsed.password !== 'string' || parsed.password === '') {
      console.error('ERROR: DATABASE_URL no incluye contrasena.');
      console.error('  Recibida:', DATABASE_URL);
      process.exit(1);
    }
    config = { connectionString: DATABASE_URL };
  } else {
    fail('Faltan las variables de conexion (PGHOST/PGDATABASE/PGUSER/PGPASSWORD o DATABASE_URL).');
  }

  const host = config.host || (config.connectionString ? parseConnectionString(config.connectionString).host : null);
  const isRemote = host && host !== 'localhost' && host !== '127.0.0.1';
  const sslDisabled = PGSSLMODE === 'disable';

  if ((NODE_ENV === 'production' || isRemote) && !sslDisabled) {
    config.ssl = { rejectUnauthorized: false };
  }

  return config;
}

module.exports = new Pool(buildConfig());