using FluentValidation;
using UploadDoc.Core.Application.Files.Commands;

namespace UploadDoc.Core.Application.Files.Validators;

public class UploadFileCommandValidator : AbstractValidator<UploadFileCommand>
{
    public UploadFileCommandValidator()
    {
        RuleFor(x => x.FileStream)
            .NotNull()
            .Must(stream => stream.CanRead)
            .WithMessage("File stream must be readable.");

        RuleFor(x => x.FileName)
            .NotEmpty()
            .WithMessage("File name is required.");
    }
}