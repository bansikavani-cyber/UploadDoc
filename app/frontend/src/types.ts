export type FileMetadata = {
  id: string;
  fileName: string;
  contentType: string;
  size: number;
  blobUrl: string;
  uploadedUtc: string;
  uploadedBy?: string | null;
};
