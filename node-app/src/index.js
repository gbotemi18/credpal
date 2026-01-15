const express = require("express");
const { Pool } = require("pg");

const PORT = Number(process.env.PORT || 3000);
const DATABASE_URL = process.env.DATABASE_URL || "";

function createDbPool() {
  if (!DATABASE_URL) return null;
  return new Pool({
    connectionString: DATABASE_URL,
    max: Number(process.env.PG_POOL_MAX || 5),
    idleTimeoutMillis: 10_000,
    connectionTimeoutMillis: 5_000
  });
}

async function ensureSchema(pool) {
  if (!pool) return;
  await pool.query(`
    CREATE TABLE IF NOT EXISTS processed_jobs (
      id BIGSERIAL PRIMARY KEY,
      input_text TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
}

function createApp({ pool }) {
  const app = express();
  app.disable("x-powered-by");
  app.use(express.json({ limit: "1mb" }));

  app.get("/", (_req, res) => {
    res.status(200).json({
      service: "credpal-devops-assessment",
      version: "1.0.0",
      endpoints: {
        "GET /health": "Health check endpoint",
        "GET /status": "Service status with uptime",
        "POST /process": "Process input (expects {input: string} in body)"
      }
    });
  });

  app.get("/health", async (_req, res) => {
    let dbOk = null;
    if (pool) {
      try {
        await pool.query("SELECT 1");
        dbOk = true;
      } catch (_e) {
        dbOk = false;
      }
    }
    res.status(200).json({ ok: true, dbOk });
  });

  app.get("/status", async (_req, res) => {
    const startedAt = Number(process.env.APP_STARTED_AT || Date.now());
    let dbOk = null;
    if (pool) {
      try {
        await pool.query("SELECT 1");
        dbOk = true;
      } catch (_e) {
        dbOk = false;
      }
    }
    res.status(200).json({
      service: "credpal-devops-assessment",
      uptimeSec: Math.floor((Date.now() - startedAt) / 1000),
      dbOk
    });
  });

  app.post("/process", async (req, res) => {
    const input = req.body?.input;
    if (typeof input !== "string" || input.trim().length === 0) {
      return res.status(400).json({ error: "body.input (string) is required" });
    }

    const normalized = input.trim();
    const output = normalized.toUpperCase();

    if (pool) {
      try {
        await pool.query("INSERT INTO processed_jobs (input_text) VALUES ($1)", [
          normalized
        ]);
      } catch (e) {
        return res.status(503).json({ error: "db unavailable", details: e.message });
      }
    }

    return res.status(200).json({ input: normalized, output });
  });

  // 404 handler for unmatched routes
  app.use((_req, res) => {
    res.status(404).json({ error: "Not Found", message: "Endpoint not found" });
  });

  // Error handler
  // eslint-disable-next-line no-unused-vars
  app.use((err, _req, res, _next) => {
    console.error("Unhandled error:", err);
    res.status(500).json({ error: "internal error" });
  });

  return app;
}

async function main() {
  process.env.APP_STARTED_AT = process.env.APP_STARTED_AT || String(Date.now());
  const pool = createDbPool();

  if (pool) {
    const maxAttempts = Number(process.env.DB_CONNECT_ATTEMPTS || 10);
    const delayMs = Number(process.env.DB_CONNECT_DELAY_MS || 1000);
    for (let i = 1; i <= maxAttempts; i++) {
      try {
        await pool.query("SELECT 1");
        await ensureSchema(pool);
        break;
      } catch (e) {
        if (i === maxAttempts) {
          console.error("DB not ready after attempts:", e.message);
        } else {
          await new Promise((r) => setTimeout(r, delayMs));
        }
      }
    }
  }

  const app = createApp({ pool });
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`listening on :${PORT}`);
  });
}

if (require.main === module) {
  main().catch((e) => {
    console.error(e);
    process.exit(1);
  });
}

module.exports = { createApp };
