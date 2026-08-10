const mysql = require('mysql2');
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'fdbcore_original'
});
connection.query('SHOW TABLES LIKE \"murphy_%\"', function(err, results) {
  if (err) throw err;
  console.log(results);
  process.exit();
});
