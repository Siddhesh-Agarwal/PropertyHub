import { env } from "cloudflare:workers";
import { v4 } from "uuid";
import type { ContractStatusType } from "./db/schema";

export function getStatus(startDate: Date): ContractStatusType {
  const now = new Date();
  if (startDate > now) {
    return "Pending";
  } else if (startDate < now) {
    return "Active";
  } else {
    return "Expired";
  }
}

export async function uploadFile(
  file: File,
  userId: string,
  propertyId: string,
): Promise<string> {
  const fileName = `${userId}-${propertyId}-${v4()}.pdf`;
  const fileBuffer = await file.arrayBuffer();
  env.R2.put(fileName, fileBuffer, {
    httpMetadata: {
      contentType: file.type,
      contentEncoding: "base64",
      contentDisposition: `attachment; filename="${fileName}"`,
    },
    customMetadata: {
      userId,
      propertyId,
      createdAt: new Date().toISOString(),
    },
  });
  return `${env.R2_BASE_URL}/${fileName}`;
}
