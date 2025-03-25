const bcrypt = require('bcryptjs');
const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '106554',
    database: 'comfort_zone'
});

db.connect((err) => {
    if (err) {
        console.error('Connection failed:', err);
        process.exit(1);
    }
    console.log('Connected to MySQL!');

    const adminEmail = 'sauravpanjiyar0309@gmail.com';
    const plainPassword = 'Saurav@3210';
    const hashedPassword = bcrypt.hashSync(plainPassword, 10);

    db.query(
        'INSERT INTO users (email, password) VALUES (?, ?) ON DUPLICATE KEY UPDATE password = ?',
        [adminEmail, hashedPassword, hashedPassword],
        (error, results) => {
            if (error) {
                console.error('Error:', error);
            } else {
                console.log('Admin inserted or password updated!');
            }
            db.end();
        }
    );
});