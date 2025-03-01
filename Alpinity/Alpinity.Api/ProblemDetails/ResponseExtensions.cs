using ApiExceptions.Exceptions;

namespace Alpinity.Api.ProblemDetails;
using ApiExceptions.Exceptions;
using FluentValidation;
using Hellang.Middleware.ProblemDetails;

public static class ResponseExtensions
{
    public static void AddCustomProblemDetailsResponses(
        this IServiceCollection services,
        IWebHostEnvironment env) =>
        services.AddProblemDetails(options =>
        {
            options.Map<EntityNotFoundException>(exception => new CustomProblemDetailsResponse
            {
                Status = StatusCodes.Status404NotFound,
                Errors = new ErrorInfoDto[] {new() {StatusCode = 404, Message = exception.Message}}
            });

            options.Map<ForbiddenAccessException>(exception => new CustomProblemDetailsResponse
            {
                Status = StatusCodes.Status403Forbidden,
                Errors = new ErrorInfoDto[] {new() {StatusCode = 403, Message = exception.Message}}
            });

            options.Map<ValidationException>(exception => new CustomProblemDetailsResponse
            {
                Status = StatusCodes.Status400BadRequest,
                Errors = exception.Errors
                    .Select(error => new ErrorInfoDto 
                    { 
                        StatusCode = 400, 
                        Message = error.ErrorMessage 
                    })
                    .ToArray()
            });

            options.Map<UnAuthorizedAccessException>(exception => new CustomProblemDetailsResponse
            {
                Status = StatusCodes.Status401Unauthorized,
                Errors = new ErrorInfoDto[] {new() {StatusCode = 401, Message = exception.Message}}
            });

            options.Map<ApiExceptions.Exceptions.EntityAlreadyExistsException>(exception =>
                new CustomProblemDetailsResponse
                {
                    Status = StatusCodes.Status409Conflict,
                    Errors = new ErrorInfoDto[] {new() {StatusCode = 409, Message = exception.Message}}
                });
            if (!env.IsDevelopment())
            {
                options.IncludeExceptionDetails = (_, _) => false;
            }
        });
}