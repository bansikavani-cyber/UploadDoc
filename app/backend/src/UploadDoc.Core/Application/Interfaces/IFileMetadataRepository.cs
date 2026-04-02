using UploadDoc.Core.Domain;

namespace UploadDoc.Core.Application.Interfaces;

public interface IFileMetadataRepository
{
    Task AddAsync(FileMetadata meta, CancellationToken ct);
    Task<IReadOnlyList<FileMetadata>> ListAsync(CancellationToken ct);
    Task<FileMetadata?> GetAsync(string id, CancellationToken ct);
}