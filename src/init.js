require('dotenv').config();
const fs = require('fs');
const path = require('path');
const pool = require('./db');

async function init() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const check = await client.query(
      `SELECT COUNT(*)::int AS n FROM information_schema.tables
       WHERE table_schema = 'public' AND table_name = 'carreras'`
    );

    if (check.rows[0].n > 0) {
      const hasSeed = await client.query('SELECT COUNT(*)::int AS n FROM carreras');
      if (hasSeed.rows[0].n > 0) {
        await client.query('COMMIT');
        console.log('Base de datos ya inicializada, omitiendo seed.');
        return;
      }
    }

    const schema = fs.readFileSync(path.join(__dirname, '..', 'schema.sql'), 'utf8');
    await client.query(schema);

    const seed = fs.readFileSync(path.join(__dirname, '..', 'seed.sql'), 'utf8');
    await client.query(seed);

    await client.query('COMMIT');
    console.log('Esquema y seed aplicados correctamente.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error inicializando la base de datos:', err.message);
    process.exitCode = 1;
  } finally {
    client.release();
    await pool.end();
  }
}

init();
