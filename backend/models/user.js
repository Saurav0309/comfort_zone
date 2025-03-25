const mysql = require('mysql2');

const db = mysql.createConnection({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE
});

const User = {
  find: (callback) => {
    db.query('SELECT * FROM users', (err, results) => {
      if (err) {
        callback(err, null);
      } else {
        callback(null, results);
      }
    });
  },
  findById: (id, callback) => {
    db.query('SELECT * FROM users WHERE id = ?', [id], (err, results) => {
      if (err) {
        callback(err, null);
      } else {
        callback(null, results[0]);
      }
    });
  },
  update: (id, updates, callback) => {
    db.query('UPDATE users SET ? WHERE id = ?', [updates, id], (err, results) => {
      if (err) {
        callback(err, null);
      } else {
        callback(null, results);
      }
    });
  },
  delete: (id, callback) => {
    db.query('DELETE FROM users WHERE id = ?', [id], (err, results) => {
      if (err) {
        callback(err, null);
      } else {
        callback(null, results);
      }
    });
  },
};

module.exports = User;