import { swaggerUI } from "@hono/swagger-ui";
import { zValidator } from "@hono/zod-validator";
import { and, eq, gt, lt, or } from "drizzle-orm";
import { drizzle } from "drizzle-orm/d1";
import { Hono } from "hono";
import { trimTrailingSlash } from "hono/trailing-slash";
import { contract, feedback, property, user } from "./db/schema";
import {
  contractSchema,
  createUserSchema,
  feedbackSchema,
  getContractByUserSchema,
  getPropertyByIdSchema,
  getUserSchema,
  propertySchema,
  userSchema,
} from "./schema";
import { getStatus, uploadFile } from "./utils";
import { env } from "cloudflare:workers";

const db = drizzle(env.D1);
const app = new Hono();
app.use(trimTrailingSlash());

// Swagger UI
const openApiDoc = {
  openapi: "3.0.0", // This is the required version field
  info: {
    title: "PropertyHub API",
    version: "1.0.0",
    description: "API documentation for PropertyHub API",
  },
};
app.get("/openapi-doc", (c) => c.json(openApiDoc));
app.get("/docs", swaggerUI({ url: "/openapi-doc" }));

// User details
app.get("/user", async (c) => {
  const res = await db.select().from(user);
  return c.json(res);
});

app.get("/user/:id", zValidator("param", getUserSchema), async (c) => {
  const { id } = c.req.valid("param");
  const res = await db.select().from(user).where(eq(user.id, id));
  if (res.length === 1 && res[0]) {
    return c.json(res[0]);
  }
  return c.json({ error: "ID not found" }, 401);
});

app.post("/user", zValidator("form", createUserSchema), async (c) => {
  const form = c.req.valid("form");
  const res = await db
    .insert(user)
    .values({
      email: form.email,
      name: form.name,
      role: form.role,
      status: "Invited",
    })
    .returning();
  return c.json(res[0]);
});

app.put(
  "/user/:id",
  zValidator("param", getUserSchema),
  zValidator("form", userSchema),
  async (c) => {
    const param = c.req.valid("param");
    const form = c.req.valid("form");
    const res = await db
      .update(user)
      .set({
        dateOfBirth: form.dateOfBirth.toISOString(),
        email: form.email,
        gender: form.gender,
        name: form.name,
        phoneNumber: form.phoneNumber,
        qatarId: form.qatarId,
        status: "Active",
      })
      .where(eq(user.id, param.id))
      .returning();
    if (res.length === 1 && res[0]) {
      return c.json(res[0]);
    }
    return c.json({ error: "Can't find user with given user ID" }, 404);
  },
);

app.delete("/user/:id", zValidator("param", getUserSchema), async (c) => {
  const param = c.req.valid("param");
  const res = await db
    .update(user)
    .set({ status: "Inactive" })
    .where(eq(user.id, param.id))
    .returning();
  if (res.length === 1) {
    return c.json({ message: "Deleted the account" });
  } else {
    return c.json({ message: "Failed to delete the account" }, 500);
  }
});

// Property Details
app.get("/property", async (c) => {
  const res = await db.select().from(property);
  return c.json(res);
});

app.get(
  "/property/:propertyId",
  zValidator("param", getPropertyByIdSchema),
  async (c) => {
    const param = c.req.valid("param");
    const res = await db
      .select()
      .from(property)
      .where(eq(property.id, param.propertyId));
    return c.json(res);
  },
);

app.post("/property", zValidator("form", propertySchema), async (c) => {
  const form = c.req.valid("form");
  const res = await db
    .insert(property)
    .values({
      address: form.address,
      size: form.size,
      ownershipType: form.ownershipType,
      propertyType: form.propertyType,
      furnishingType: form.furnishingType,
      usageType: form.usageType,
      imageUrl: form.imageUrl,
    })
    .returning();
  if (res.length === 1 && res[0]) {
    return c.json(res[0]);
  }
  return c.json({ error: "Unable to create property" }, 500);
});

app.put(
  "/property/:propertyId",
  zValidator("param", getPropertyByIdSchema),
  zValidator("form", propertySchema),
  async (c) => {
    const form = c.req.valid("form");
    const param = c.req.valid("param");
    const res = await db
      .update(property)
      .set({
        address: form.address,
        size: form.size,
        ownershipType: form.ownershipType,
        propertyType: form.propertyType,
        furnishingType: form.furnishingType,
        usageType: form.usageType,
        imageUrl: form.imageUrl,
      })
      .where(eq(property.id, param.propertyId))
      .returning();
    if (res.length === 1 && res[0]) {
      return c.json(res[0]);
    }
    return c.json({ error: "Unable to update property details" }, 500);
  },
);

app.delete(
  "/property/:propertyId",
  zValidator("param", getPropertyByIdSchema),
  async (c) => {
    const param = c.req.valid("param");
    const res = await db
      .delete(property)
      .where(eq(property.id, param.propertyId));
    if (res.length === 1 && res[0]) {
      return c.json(res[0]);
    }
    return c.json({ error: "Unable to delete property" }, 500);
  },
);

// User Feedback
app.get(
  "/property/:propertyId/feedback",
  zValidator("param", getPropertyByIdSchema),
  async (c) => {
    const param = c.req.valid("param");
    const res = await db
      .select()
      .from(feedback)
      .where(eq(feedback.propertyId, param.propertyId));
    return c.json(res);
  },
);

app.post(
  "/property/:propertyId/feedback",
  zValidator("param", getPropertyByIdSchema),
  zValidator("form", feedbackSchema),
  async (c) => {
    const param = c.req.valid("param");
    const form = c.req.valid("form");
    const checkRes = await db
      .select()
      .from(feedback)
      .where(
        and(
          eq(feedback.propertyId, param.propertyId),
          eq(feedback.userId, form.userId),
        ),
      );
    if (checkRes.length > 0) {
      return c.json({ error: "Feedback already exists" }, 400);
    }
    const insertRes = await db
      .insert(feedback)
      .values({
        propertyId: param.propertyId,
        userId: form.userId,
        rating: form.rating,
        comment: form.comment,
      })
      .returning();
    return c.json(insertRes);
  },
);

app.put(
  "/property/:propertyId/feedback",
  zValidator("param", getPropertyByIdSchema),
  zValidator("form", feedbackSchema),
  async (c) => {
    const param = c.req.valid("param");
    const form = c.req.valid("form");
    const checkRes = await db
      .select()
      .from(feedback)
      .where(
        and(
          eq(feedback.propertyId, param.propertyId),
          eq(feedback.userId, form.userId),
        ),
      );
    if (checkRes.length !== 1) {
      return c.json({ error: "Feedback does not exist" }, 404);
    }
    const updateRes = await db
      .update(feedback)
      .set({
        rating: form.rating,
        comment: form.comment,
      })
      .where(
        and(
          eq(feedback.propertyId, param.propertyId),
          eq(feedback.userId, form.userId),
        ),
      )
      .returning();
    return c.json(updateRes);
  },
);

// Property contract
app.get(
  "/property/:propertyId/contract",
  zValidator("param", getPropertyByIdSchema),
  async (c) => {
    const param = c.req.valid("param");
    const res = await db
      .select()
      .from(contract)
      .where(eq(contract.propertyId, param.propertyId));
    return c.json(res);
  },
);

app.get(
  "/user/:userId/contract",
  zValidator("param", getContractByUserSchema),
  async (c) => {
    const param = c.req.valid("param");
    const res = await db
      .select()
      .from(contract)
      .where(eq(contract.userId, param.userId));
    return c.json(res);
  },
);

app.post(
  "/property/:propertyId/contract",
  zValidator("param", getPropertyByIdSchema),
  zValidator("form", contractSchema),
  async (c) => {
    const param = c.req.valid("param");
    const form = c.req.valid("form");
    const checkRes = await db
      .select()
      .from(contract)
      .where(
        and(
          // Find contracts for the same property but with overlapping dates
          eq(contract.propertyId, param.propertyId),
          or(
            gt(contract.endDate, form.startDate.toISOString()),
            lt(contract.startDate, form.endDate.toISOString()),
          ),
        ),
      );
    if (checkRes.length !== 0) {
      return c.json({ error: "Contract already exists" }, 409);
    }
    const body = await c.req.parseBody();
    const file = body.file;
    if (typeof file === "string") {
      return c.json({ error: "Invalid method to upload file" }, 400);
    }
    // Only PDF files are allowed
    if (!file.type.endsWith("pdf")) {
      return c.json({ error: "Invalid file type" }, 400);
    }
    if (!file.size) {
      return c.json({ error: "File cannot be empty" }, 400);
    }
    if (file.size > 10 * 1024 * 1024) {
      return c.json({ error: "File size exceeds limit" }, 400);
    }

    const contractUrl = await uploadFile(
      file,
      form.userId.toString(),
      param.propertyId.toString(),
    );

    const insertRes = await db
      .insert(contract)
      .values({
        propertyId: param.propertyId,
        userId: form.userId,
        contractUrl: contractUrl,
        startDate: form.startDate.toISOString(),
        endDate: form.endDate.toISOString(),
        status: getStatus(form.startDate),
      })
      .returning();
    return c.json(insertRes);
  },
);

export default app;
