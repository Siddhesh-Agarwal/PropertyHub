import z from "zod";
import {
  CONTRACT_STATUS_TYPES,
  FURNISHING_TYPES,
  GENDER_TYPES,
  OWNERSHIP_TYPES,
  PROPERTY_TYPES,
  ROLE_TYPES,
  USAGE_TYPES,
} from "./db/schema";

export const getUserSchema = z.object({
  id: z.coerce.number(),
});

export const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.email(),
  role: z.enum(ROLE_TYPES),
});

export const userSchema = z.object({
  name: z.string().min(2).max(100),
  phoneNumber: z.string().min(8).max(8),
  email: z.email(),
  qatarId: z.string().min(11).max(11),
  dateOfBirth: z.coerce.date(),
  gender: z.enum(GENDER_TYPES),
});

export const propertySchema = z.object({
  address: z.string().min(5).max(100),
  size: z.number().min(1),
  ownershipType: z.enum(OWNERSHIP_TYPES),
  propertyType: z.enum(PROPERTY_TYPES),
  furnishingType: z.enum(FURNISHING_TYPES),
  usageType: z.enum(USAGE_TYPES),
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
  status: z.enum(CONTRACT_STATUS_TYPES),
});

export const getContractByUserSchema = z.object({
  userId: z.coerce.number(),
});
