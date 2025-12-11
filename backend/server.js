const express = require("express");
const sql = require("mssql");
const cors = require("cors");

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Connection string récupérée depuis Azure App Service (app_settings)
const connectionString = process.env.DB_CONNECTION_STRING;

// Connexion SQL réutilisable
let pool;
async function getPool() {
  if (!pool) {
    if (!connectionString) {
      throw new Error("DB_CONNECTION_STRING is not defined");
    }
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

// Port imposé par Azure, sinon 3000 en local
const port = process.env.PORT || 3000;

// IMPORTANT : pas besoin de préciser host, Node écoute sur 0.0.0.0 par défaut
app.listen(port, () => {
  console.log(`Backend running on port ${port}`);
});
