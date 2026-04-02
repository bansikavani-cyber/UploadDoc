import { useEffect, useMemo, useRef, useState } from 'react';
import { FileMetadata } from './types';
import { getDownloadUrl, listFiles, uploadFile } from './api';

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleString();
}

export default function App() {
  const [files, setFiles] = useState<FileMetadata[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const uploadInput = useRef<HTMLInputElement | null>(null);
  const uploadedByRef = useRef<HTMLInputElement | null>(null);

  const filtered = useMemo(() => {
    const term = search.trim().toLowerCase();
    if (!term) return files;
    return files.filter((f) => f.fileName.toLowerCase().includes(term));
  }, [files, search]);

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        const data = await listFiles();
        setFiles(data);
      } catch (e) {
        setError('Could not load files');
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  async function handleUpload() {
    const file = uploadInput.current?.files?.[0];
    if (!file) return setError('Choose a file first');
    setError(null);
    setMessage(null);
    setUploading(true);
    try {
      const meta = await uploadFile(file, uploadedByRef.current?.value || undefined);
      setFiles((prev) => [meta, ...prev]);
      setMessage('Uploaded successfully');
      if (uploadInput.current) uploadInput.current.value = '';
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setUploading(false);
    }
  }

  async function handleDownload(id: string) {
    setError(null);
    try {
      const url = await getDownloadUrl(id, 60);
      window.open(url, '_blank');
    } catch (e) {
      setError((e as Error).message);
    }
  }

  async function handleRefresh() {
    setError(null);
    setMessage(null);
    setLoading(true);
    try {
      const data = await listFiles();
      setFiles(data);
    } catch (e) {
      setError('Could not refresh files');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ maxWidth: 1100, margin: '0 auto', display: 'grid', gap: 24 }}>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ margin: 0 }}>UploadDoc</h1>
          <p className="muted" style={{ margin: '4px 0 0' }}>
            Upload, search, and download documents.
          </p>
        </div>
        <button onClick={handleRefresh} disabled={loading}>
          Refresh
        </button>
      </header>

      <section className="card" style={{ display: 'grid', gap: 12 }}>
        <h2 style={{ margin: 0, fontSize: 18 }}>Upload a file</h2>
        <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
          <input ref={uploadInput} className="input" type="file" />
          <input ref={uploadedByRef} className="input" placeholder="Uploaded by (optional)" />
          <button onClick={handleUpload} disabled={uploading}>
            {uploading ? 'Uploading…' : 'Upload'}
          </button>
        </div>
        <small className="muted">
          Uploads call `POST /api/files` and store metadata; downloads fetch a signed URL for the blob.
        </small>
      </section>

      <section className="card" style={{ display: 'grid', gap: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2 style={{ margin: 0, fontSize: 18 }}>Files</h2>
          <input
            className="input"
            style={{ maxWidth: 240 }}
            placeholder="Search by name"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        {loading ? (
          <p className="muted">Loading files…</p>
        ) : filtered.length === 0 ? (
          <p className="muted">No files yet.</p>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Size</th>
                  <th>Type</th>
                  <th>Uploaded</th>
                  <th>By</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((file) => (
                  <tr key={file.id}>
                    <td>{file.fileName}</td>
                    <td className="muted">{formatSize(file.size)}</td>
                    <td className="muted">{file.contentType}</td>
                    <td className="muted">{formatDate(file.uploadedUtc)}</td>
                    <td className="muted">{file.uploadedBy ?? '—'}</td>
                    <td>
                      <button onClick={() => handleDownload(file.id)}>Download</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {(error || message) && (
        <div className="card" style={{ borderColor: error ? '#ef4444' : '#10b981' }}>
          <strong style={{ color: error ? '#b91c1c' : '#047857' }}>{error ?? message}</strong>
        </div>
      )}
    </div>
  );
}
