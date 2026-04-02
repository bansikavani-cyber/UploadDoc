using MediatR;
using UploadDoc.Core.Domain;

namespace UploadDoc.Core.Application.Files.Queries;

public record ListFilesQuery() : IRequest<IReadOnlyList<FileMetadata>>;