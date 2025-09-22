import z from "zod";

export const getUserSchema = z.object({
  id: z.coerce.number(),
});

export const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.email(),
  role: z.enum(["admin", "user"]),
});

export const userSchema = z.object({
  name: z.string().min(2).max(100),
  phoneNumber: z.string().min(8).max(8),
  email: z.email(),
  qatarId: z.string().min(11).max(11),
  dateOfBirth: z.coerce.date(),
  gender: z.enum(["male", "female"]),
});

export const propertySchema = z.object({
  address: z.string().min(5).max(100),
  size: z.number().min(1),
  ownershipType: z.enum(["Owned", "Rented", "Managed"]),
  propertyType: z.enum(["Villa", "Apartment", "Shop"]),
  furnishingType: z.enum(["Furnished", "Unfurnished"]),
  usageType: z.enum(["Residential", "Commercial"]),
  imageUrl: z.url().optional(),
});

export const getPropertyByIdSchema = z.object({
  propertyId: z.coerce.number(),
});

export const feedbackSchema = z.object({
  userId: z.coerce.number(),
  rating: z.int().min(1).max(5),
  comment: z.string().min(1).max(500),
});

export const contractSchema = z.object({
  propertyId: z.coerce.number(),
  userId: z.coerce.number(),
  startDate: z.coerce.date(),
  endDate: z.coerce.date(),
  contract: z.file(),
  status: z.enum(["Pending", "Active", "Expired", "Cancelled"]),
});

export const getContractByUserSchema = z.object({
  userId: z.coerce.number(),
});
