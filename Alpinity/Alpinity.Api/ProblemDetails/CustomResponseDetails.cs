namespace Alpinity.Api.ProblemDetails;

internal class CustomProblemDetailsResponse : Microsoft.AspNetCore.Mvc.ProblemDetails
{
    public ErrorInfoDto[] Errors { get; set; } = null!;
}
