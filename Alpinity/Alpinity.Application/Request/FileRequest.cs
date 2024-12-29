namespace Alpinity.Application.Request;

public record FileRequest(string FileName, string ContentType, Stream Content);
