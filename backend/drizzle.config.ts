import { defineConfig } from "drizzle-kit";

const DB_URL = process.env.DATABASE_URL;
if (!DB_URL) {
  throw new Error("DATABASE_URL environment variable is not set");
}

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dbCredentials: {
    url: DB_URL,
  },
});
