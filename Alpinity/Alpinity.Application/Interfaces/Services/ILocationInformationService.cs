using System;
using Alpinity.Domain.ServiceResponses;

namespace Alpinity.Application.Interfaces.Services;

public interface ILocationInformationService
{
    Task<LocationInformationResponse> GetLocationInformationFromCoordinates(double latitude, double longitude);
    string? GetLocationNameFromLocationInformation(LocationInformationResponse? locationInformation);
}
