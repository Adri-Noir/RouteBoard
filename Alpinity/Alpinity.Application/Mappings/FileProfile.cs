using Alpinity.Application.Request;
using AutoMapper;
using Microsoft.AspNetCore.Http;

namespace Alpinity.Application.Mappings;

public class FileProfile : Profile
{
    public FileProfile()
    {
        CreateMap<IFormFile, FileRequest>()
            .ConstructUsing((formFile, context) =>
            {
                var content = formFile.OpenReadStream();
                return new FileRequest(formFile.FileName, formFile.ContentType, content);
            });
    }
}