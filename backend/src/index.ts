import { zValidator } from "@hono/zod-validator";
import { and, eq, gt, lt, or } from "drizzle-orm";
import { drizzle } from "drizzle-orm/d1";
import { Hono } from "hono";
import { trimTrailingSlash } from "hono/trailing-slash";
import {
  contractTable,
  feedbackTable,
  propertyTable,
  userTable,
} from "./db/schema";
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

// User details
app.get("/user", async (c) => {
  const res = await db.select().from(userTable);
  return c.json(res);
});

app.get("/user/:id", zValidator("param", getUserSchema), async (c) => {
  const { id } = c.req.valid("param");
  const [user] = await db.select().from(userTable).where(eq(userTable.id, id));
  if (user) {
    return c.json(user);
  }
  return c.json({ error: "ID not found" }, 401);
});

app.post("/user", zValidator("form", createUserSchema), async (c) => {
  const form = c.req.valid("form");
  const [user] = await db
    .insert(userTable)
    .values({
      email: form.email,
      name: form.name,
      role: form.role,
      status: "Invited",
    })
    .returning();
  return c.json(user);
});

app.put(
  "/user/:id",
  zValidator("param", getUserSchema),
  zValidator("form", userSchema),
  async (c) => {
    const param = c.req.valid("param");
    const form = c.req.valid("form");
    const [user] = await db
      .update(userTable)
      .set({
        dateOfBirth: form.dateOfBirth.toISOString(),
        email: form.email,
        gender: form.gender,
        name: form.name,
        phoneNumber: form.phoneNumber,
        qatarId: form.qatarId,
        status: "Active",
      })
      .where(eq(userTable.id, param.id))
      .returning();
    if (user) {
      return c.json(user);
    }
    return c.json({ error: "Can't find user with given user ID" }, 404);
  },
);

app.delete("/user/:id", zValidator("param", getUserSchema), async (c) => {
  const param = c.req.valid("param");
  const user = await db
    .update(userTable)
    .set({ status: "Inactive" })
    .where(eq(userTable.id, param.id))
    .returning();
  if (user) {
    return c.json({ message: "Deleted the account" });
  }
  return c.json({ message: "Failed to delete the account" }, 500);
});

// Property Details
app.get("/property", async (c) => {
  const properties = await db.select().from(propertyTable);
  return c.json(properties);
});

app.get(
  "/property/:propertyId",
  zValidator("param", getPropertyByIdSchema),
  async (c) => {
    const param = c.req.valid("param");
    const [property] = await db
      .select()
      .from(propertyTable)
      .where(eq(propertyTable.id, param.propertyId));
    if (!property) {
      return c.json({ error: "Property not found" }, 404);
    }
    return c.json(property);
  },
);

app.post("/property", zValidator("form", propertySchema), async (c) => {
  const form = c.req.valid("form");
  const [property] = await db
    .insert(propertyTable)
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
  if (property) {
    return c.json(property);
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
    const [property] = await db
      .update(propertyTable)
      .set({
        address: form.address,
        size: form.size,
        ownershipType: form.ownershipType,
        propertyType: form.propertyType,
        furnishingType: form.furnishingType,
        usageType: form.usageType,
        imageUrl: form.imageUrl,
      })
      .where(eq(propertyTable.id, param.propertyId))
      .returning();
    if (property) {
      return c.json(property);
    }
    return c.json({ error: "Unable to update property details" }, 500);
  },
);

app.delete(
  "/property/:propertyId",
  zValidator("param", getPropertyByIdSchema),
  async (c) => {
    const param = c.req.valid("param");
    const [property] = await db
      .delete(propertyTable)
      .where(eq(propertyTable.id, param.propertyId))
      .returning();
    if (property) {
      return c.json(property);
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
    const feedbacks = await db
      .select()
      .from(feedbackTable)
      .where(eq(feedbackTable.propertyId, param.propertyId));
    return c.json(feedbacks);
  },
);

app.post(
  "/property/:propertyId/feedback",
  zValidator("param", getPropertyByIdSchema),
  zValidator("form", feedbackSchema),
  async (c) => {
    const param = c.req.valid("param");
    const form = c.req.valid("form");
    const [feedback] = await db
      .select()
      .from(feedbackTable)
      .where(
        and(
          eq(feedbackTable.propertyId, param.propertyId),
          eq(feedbackTable.userId, form.userId),
        ),
      );
    if (!feedback) {
      return c.json({ error: "Feedback already exists" }, 400);
    }
    const insertRes = await db
      .insert(feedbackTable)
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
    const [feedback] = await db
      .select()
      .from(feedbackTable)
      .where(
        and(
          eq(feedbackTable.propertyId, param.propertyId),
          eq(feedbackTable.userId, form.userId),
        ),
      );
    if (feedback === undefined) {
      return c.json({ error: "Feedback does not exist" }, 404);
    }
    const [updatedFeedback] = await db
      .update(feedbackTable)
      .set({
        rating: form.rating,
        comment: form.comment,
      })
      .where(
        and(
          eq(feedbackTable.propertyId, param.propertyId),
          eq(feedbackTable.userId, form.userId),
        ),
      )
      .returning();
    return c.json(updatedFeedback);
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
      .from(contractTable)
      .where(eq(contractTable.propertyId, param.propertyId));
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
      .from(contractTable)
      .where(eq(contractTable.userId, param.userId));
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
    const [contract] = await db
      .select()
      .from(contractTable)
      .where(
        and(
          // Find contracts for the same property but with overlapping dates
          eq(contractTable.propertyId, param.propertyId),
          or(
            gt(contractTable.endDate, form.startDate.toISOString()),
            lt(contractTable.startDate, form.endDate.toISOString()),
          ),
        ),
      );
    if (contract) {
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
