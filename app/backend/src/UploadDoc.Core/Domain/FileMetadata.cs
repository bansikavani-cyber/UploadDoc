namespace UploadDoc.Core.Domain;

public class FileMetadata
{
    public string Id { get; set; } = default!;
    public string FileName { get; set; } = default!;
    public string ContentType { get; set; } = default!;
    public long Size { get; set; }
    public string BlobUrl { get; set; } = default!;
    public DateTime UploadedUtc { get; set; }
    public string? UploadedBy { get; set; }
}
