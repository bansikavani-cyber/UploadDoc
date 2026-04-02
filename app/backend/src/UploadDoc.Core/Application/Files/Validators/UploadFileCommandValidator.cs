using FluentValidation;
using UploadDoc.Core.Application.Files.Commands;

namespace UploadDoc.Core.Application.Files.Validators;

public class UploadFileCommandValidator : AbstractValidator<UploadFileCommand>
{
    public UploadFileCommandValidator()
    {
        RuleFor(x => x.File).NotNull();
        RuleFor(x => x.File.Length).GreaterThan(0);
    }
}