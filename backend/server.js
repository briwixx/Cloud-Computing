const express = require("express");
const sql = require("mssql");

const app = express();
app.use(express.json());

const connectionString = process.env.DB_CONNECTION_STRING;

// Connexion SQL réutilisable
let pool;
async function getPool() {
  if (!pool) {
    pool = await sql.connect(connectionString);
  }
  return pool;
}

// Test simple
app.get("/", (req, res) => {
  res.send("Backend Node.js is running");
});

// Ping
app.get("/api/ping", (req, res) => {
  res.json({ message: "pong" });
});

// Handler commun pour le compteur
async function handleVisit(req, res) {
  try {
    const pool = await getPool();

    // Incrément
    await pool.request().query(`
      UPDATE VisitCount
      SET Count = Count + 1
      WHERE Id = 1;
    `);

    // Lecture
    const result = await pool.request().query(`
      SELECT Count
      FROM VisitCount
      WHERE Id = 1;
    `);

    const count = result.recordset[0].Count;
    res.json({ count });
  } catch (err) {
    console.error("Error in /api/visit:", err);
    res.status(500).json({ error: "Internal server error" });
  }
}

// On supporte GET et POST pour /api/visit
app.get("/api/visit", handleVisit);
app.post("/api/visit", handleVisit);

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Backend running on port ${port}`);
});
