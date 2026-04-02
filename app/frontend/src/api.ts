import { FileMetadata } from './types';

const API_BASE = (import.meta.env.VITE_API_BASE_URL as string | undefined) ?? '';

const withBase = (path: string) => `${API_BASE}${path}`;

export async function listFiles(): Promise<FileMetadata[]> {
  const res = await fetch(withBase('/api/files'));
  if (!res.ok) throw new Error('Failed to list files');
  return res.json();
}

export async function uploadFile(file: File, uploadedBy?: string): Promise<FileMetadata> {
  const form = new FormData();
  form.append('file', file);
  if (uploadedBy) form.append('uploadedBy', uploadedBy);

  const res = await fetch(withBase('/api/files'), {
    method: 'POST',
    body: form
  });
  if (!res.ok) throw new Error('Upload failed');
  return res.json();
}

export async function getDownloadUrl(id: string, minutes = 60): Promise<string> {
  const res = await fetch(withBase(`/api/files/${encodeURIComponent(id)}/url?minutes=${minutes}`));
  if (!res.ok) throw new Error('Failed to get download URL');
  return res.text();
}
