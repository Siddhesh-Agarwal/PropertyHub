import {
  date,
  doublePrecision,
  integer,
  pgEnum,
  pgTable,
  serial,
  text,
} from "drizzle-orm/pg-core";

export const ownershipOptions = pgEnum("OwnershipType", [
  "Owned",
  "Rented",
  "Managed",
]);
export const propertyOptions = pgEnum("PropertyType", [
  "Villa",
  "Apartment",
  "Shop",
]);
export const furnishingOptions = pgEnum("FurnishingType", [
  "Furnished",
  "Unfurnished",
]);
export const usageOptions = pgEnum("UsageType", ["Residential", "Commercial"]);
export const userStatusOptions = pgEnum("StatusType", [
  "Invited",
  "Active",
  "Inactive",
]);
export const contractStatusOptions = pgEnum("ContractStatusType", [
  "Active",
  "Expired",
  "Pending",
  "Cancelled",
]);

export const property = pgTable("property", {
  id: serial("id").primaryKey(),
  address: text("address").notNull(),
  size: doublePrecision("size").notNull(),
  ownershipType: ownershipOptions("ownership_type").notNull(),
  propertyType: propertyOptions("property_type").notNull(),
  furnishingType: furnishingOptions("furnishing_type").notNull(),
  usageType: usageOptions("usage_type").notNull(),
  imageUrl: text("image_url"),
});

export const userGender = pgEnum("GenderType", ["male", "female"]);
export const userRole = pgEnum("RoleType", ["admin", "user"]);

export const user = pgTable("user", {
  id: serial("id").primaryKey(),
  email: text("email").unique().notNull(),
  name: text("name").notNull(),
  phoneNumber: text("phone").unique(),
  gender: userGender("gender"),
  qatarId: text("qatar_id").unique(),
  dateOfBirth: date("date_of_birth"),
  status: userStatusOptions("status").notNull(),
  role: userRole("role").notNull(),
});

export const contract = pgTable("contract", {
  id: serial("id").primaryKey(),
  propertyId: integer("property_id")
    .references(() => property.id)
    .notNull(),
  userId: integer("user_id")
    .references(() => user.id)
    .notNull(),
  startDate: date("start_date").notNull(),
  endDate: date("end_date").notNull(),
  contractUrl: text("contract_url"),
  status: contractStatusOptions("status").notNull(),
});

export const feedback = pgTable("feedback", {
  id: serial("id").primaryKey(),
  userId: integer("user_id")
    .references(() => user.id)
    .notNull(),
  propertyId: integer("property_id")
    .references(() => property.id)
    .notNull(),
  rating: integer("rating").notNull(),
  comment: text("comment"),
});

