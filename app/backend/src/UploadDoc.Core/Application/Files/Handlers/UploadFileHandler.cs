using MediatR;
using UploadDoc.Core.Application.Files.Commands;
using UploadDoc.Core.Application.Interfaces;
using UploadDoc.Core.Domain;

namespace UploadDoc.Core.Application.Files.Handlers;

public class UploadFileHandler : IRequestHandler<UploadFileCommand, FileMetadata>
{
    private readonly IFileStorage _storage;
    private readonly IFileMetadataRepository _repo;

    public UploadFileHandler(IFileStorage storage, IFileMetadataRepository repo)
    {
        _storage = storage;
        _repo = repo;
    }

    public async Task<FileMetadata> Handle(UploadFileCommand request, CancellationToken ct)
    {
        var blobName = $"{Guid.NewGuid()}{Path.GetExtension(request.File.FileName)}";
        await using var stream = request.File.OpenReadStream();
        var loc = await _storage.UploadAsync(stream, blobName, request.File.ContentType, ct);

        var meta = new FileMetadata
        {
            Id = loc.BlobName,
            FileName = request.File.FileName,
            ContentType = request.File.ContentType,
            Size = request.File.Length,
            BlobUrl = loc.Uri.ToString(),
            UploadedUtc = DateTime.UtcNow,
            UploadedBy = request.UploadedBy
        };

        await _repo.AddAsync(meta, ct);
        return meta;
    }
}