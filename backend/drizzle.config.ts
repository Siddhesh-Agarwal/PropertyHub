import { env } from "cloudflare:workers";
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "sqlite",
  driver: "d1-http",
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dbCredentials: {
    accountId: env.D1_ACCOUNT_ID,
    databaseId: env.D1_DATABASE_ID,
    token: env.D1_TOKEN,
  },
});
