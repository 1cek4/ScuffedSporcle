const mariadb = require('mariadb');

const pool = mariadb.createPool({
  host: process.env.DB_HOST ,
  user: process.env.DB_USER ,
  password: process.env.DB_PASSWORD ,
  database: process.env.DB_NAME ,
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3306,
  connectionLimit: 5
});

class User {
  constructor(id, username, password) {
    this.id = id;
    this.username = username;
    this.password = password;
  }

  static async createUser(username, password) {
    const conn = await pool.getConnection();
    try {
      const result = await conn.query(
        'INSERT INTO users (userName, password) VALUES (?, ?)',
        [username, password]
      );
      return result.insertId;
    } finally {
      conn.release();
    }
  }


  static async findUserById(id) {
    const conn = await pool.getConnection();
    try {
      const rows = await conn.query('SELECT * FROM users WHERE id = ?', [id]);
      return rows[0];
    } finally {
      conn.release();
    }
  }

  static async findUserByUsername(username) {
    const conn = await pool.getConnection();
    try {
      const rows = await conn.query(
        'SELECT * FROM users WHERE UserName = ?',
        [username]
      );
      return rows[0];
    } finally {
      conn.release();
    }
  }
}

module.exports = User;