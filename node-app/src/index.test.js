const request = require("supertest");
const { createApp } = require("./index");

describe("CredPal DevOps assessment app", () => {
  test("GET /health returns ok", async () => {
    const app = createApp({ pool: null });
    const res = await request(app).get("/health").expect(200);
    expect(res.body).toHaveProperty("ok", true);
  });

  test("GET /status returns service + uptime", async () => {
    process.env.APP_STARTED_AT = String(Date.now() - 1500);
    const app = createApp({ pool: null });
    const res = await request(app).get("/status").expect(200);
    expect(res.body).toHaveProperty("service");
    expect(res.body).toHaveProperty("uptimeSec");
  });

  test("POST /process validates input", async () => {
    const app = createApp({ pool: null });
    await request(app).post("/process").send({}).expect(400);
  });

  test("POST /process uppercases input", async () => {
    const app = createApp({ pool: null });
    const res = await request(app)
      .post("/process")
      .send({ input: "hello" })
      .expect(200);
    expect(res.body).toEqual({ input: "hello", output: "HELLO" });
  });
});
