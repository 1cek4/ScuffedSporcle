const mariadb = require('mariadb');

const pool = mariadb.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'abc123',
    database: process.env.DB_NAME || 'usersdb',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    connectionLimit: 5
});

const connectDB = async () => {
    try {
        const conn = await pool.getConnection();
        console.log('Connected to MariaDB');
        conn.release();
    } catch (err) {
        console.error('Error connecting to MariaDB:', err);
        throw err;
    }
};

module.exports = connectDB;