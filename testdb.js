const mysql = require('mysql2');
const connection = mysql.createConnection('mysql://root@localhost/FDB?charset=utf8mb4');
connection.query('SELECT * FROM fdb_clothes LIMIT 5', (err, results) => {
    if (err) { console.error('Error:', err.message); }
    else { console.log('Rows:', results); }
    connection.end();
});
