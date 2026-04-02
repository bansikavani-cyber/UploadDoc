React + Vite frontend for UploadDoc.

## Quick start

```bash
cd app/frontend
pnpm install # or npm / yarn
cp .env.example .env # point VITE_API_BASE_URL at the backend (leave empty for same origin)
pnpm dev
```

## Features
- Upload a document (POST /api/files).
- List & client-side search.
- Download via signed URL (GET /api/files/{id}/url?minutes=60).

Styling is simple CSS for now; Tailwind can be added later if desired.
