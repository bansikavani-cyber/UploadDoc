using UploadDoc.Core.Application.Models;

namespace UploadDoc.Core.Application.Interfaces;

public interface IFileStorage
{
    Task<FileLocation> UploadAsync(Stream content, string fileName, string contentType, CancellationToken ct);
    Task<string> GetReadUrlAsync(string blobName, TimeSpan ttl, CancellationToken ct);
}
