using MediatR;
using UploadDoc.Core.Domain;

namespace UploadDoc.Core.Application.Files.Commands;

public record UploadFileCommand(
    Stream FileStream,
    string FileName,
    string? UploadedBy
) : IRequest<FileMetadata>;