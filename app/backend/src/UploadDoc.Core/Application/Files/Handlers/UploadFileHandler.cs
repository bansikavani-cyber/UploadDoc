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
        var blobName = $"{Guid.NewGuid()}{Path.GetExtension(request.FileName)}";

        // Use the stream coming from the command
        await using var stream = request.FileStream;

        var loc = await _storage.UploadAsync(
            stream,
            blobName,
            null, // contentType can be passed separately if needed
            ct
        );

        var meta = new FileMetadata
        {
            Id = loc.BlobName,
            FileName = request.FileName,
            ContentType = null, // optionally include in command if needed
            Size = stream.Length, // may not always be available depending on stream type
            BlobUrl = loc.Uri.ToString(),
            UploadedUtc = DateTime.UtcNow,
            UploadedBy = request.UploadedBy
        };

        await _repo.AddAsync(meta, ct);
        return meta;
    }
}