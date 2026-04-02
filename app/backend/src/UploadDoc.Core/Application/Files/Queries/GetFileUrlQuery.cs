using MediatR;

namespace UploadDoc.Core.Application.Files.Queries;

public record GetFileUrlQuery(string Id, int Minutes) : IRequest<string>;