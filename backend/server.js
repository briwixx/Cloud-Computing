import express from "express";
import sql from "mssql";

const app = express();
app.use(express.json());

const connectionString = process.env.DB_CONNECTION_STRING;

let poolPromise;

// Connexion SQL moderne
async function getPool() {
  if (!poolPromise) {
    poolPromise = sql.connect(connectionString);
  }
  return poolPromise;
}

app.get("/", (req, res) => {
  res.send("Backend Node.js (Linux + Node 20) is running 🚀");
});

app.get("/api/ping", (req, res) => {
  res.json({ message: "pong" });
});

// Incrément du compteur
app.post("/api/visit", async (req, res) => {
  try {
    const pool = await getPool();

    await pool.request().query(`
      UPDATE VisitCount
      SET Count = Count + 1
      WHERE Id = 1;
    `);

    const result = await pool.request().query(`
      SELECT Count FROM VisitCount WHERE Id = 1;
    `);

    res.json({ count: result.recordset[0].Count });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Backend running on port ${port}`));
