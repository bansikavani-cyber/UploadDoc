using MediatR;
using Microsoft.AspNetCore.Http;
using UploadDoc.Core.Domain;

namespace UploadDoc.Core.Application.Files.Commands;

public record UploadFileCommand(IFormFile File, string? UploadedBy) : IRequest<FileMetadata>;