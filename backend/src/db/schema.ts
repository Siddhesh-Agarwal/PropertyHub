import { integer, real, sqliteTable, text } from "drizzle-orm/sqlite-core";

// Enum value constants
export const OWNERSHIP_TYPES = ["Owned", "Rented", "Managed"] as const;
export const PROPERTY_TYPES = ["Villa", "Apartment", "Shop"] as const;
export const FURNISHING_TYPES = ["Furnished", "Unfurnished"] as const;
export const USAGE_TYPES = ["Residential", "Commercial"] as const;
export const USER_STATUS_TYPES = ["Invited", "Active", "Inactive"] as const;
export const CONTRACT_STATUS_TYPES = [
  "Active",
  "Expired",
  "Pending",
  "Cancelled",
] as const;
export const GENDER_TYPES = ["male", "female"] as const;
export const ROLE_TYPES = ["admin", "user"] as const;

// Type exports for TypeScript
export type OwnershipType = (typeof OWNERSHIP_TYPES)[number];
export type PropertyType = (typeof PROPERTY_TYPES)[number];
export type FurnishingType = (typeof FURNISHING_TYPES)[number];
export type UsageType = (typeof USAGE_TYPES)[number];
export type UserStatusType = (typeof USER_STATUS_TYPES)[number];
export type ContractStatusType = (typeof CONTRACT_STATUS_TYPES)[number];
export type GenderType = (typeof GENDER_TYPES)[number];
export type RoleType = (typeof ROLE_TYPES)[number];

export const propertyTable = sqliteTable("property", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  address: text("address").notNull(),
  size: real("size").notNull(),
  ownershipType: text("ownership_type", {
    enum: OWNERSHIP_TYPES,
  }).notNull(),
  propertyType: text("property_type", {
    enum: PROPERTY_TYPES,
  }).notNull(),
  furnishingType: text("furnishing_type", {
    enum: FURNISHING_TYPES,
  }).notNull(),
  usageType: text("usage_type", {
    enum: USAGE_TYPES,
  }).notNull(),
  imageUrl: text("image_url"),
});

export const userTable = sqliteTable("user", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  email: text("email").unique().notNull(),
  name: text("name").notNull(),
  phoneNumber: text("phone").unique(),
  gender: text("gender", { enum: GENDER_TYPES }),
  qatarId: text("qatar_id").unique(),
  dateOfBirth: text("date_of_birth"),
  status: text("status", {
    enum: USER_STATUS_TYPES,
  }).notNull(),
  role: text("role", { enum: ROLE_TYPES }).notNull(),
});

export const contractTable = sqliteTable("contract", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  propertyId: integer("property_id")
    .references(() => propertyTable.id)
    .notNull(),
  userId: integer("user_id")
    .references(() => userTable.id)
    .notNull(),
  startDate: text("start_date").notNull(),
  endDate: text("end_date").notNull(),
  contractUrl: text("contract_url"),
  status: text("status", {
    enum: CONTRACT_STATUS_TYPES,
  }).notNull(),
});

export const feedbackTable = sqliteTable("feedback", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  userId: integer("user_id")
    .references(() => userTable.id)
    .notNull(),
  propertyId: integer("property_id")
    .references(() => propertyTable.id)
    .notNull(),
  rating: integer("rating").notNull(),
  comment: text("comment"),
});
