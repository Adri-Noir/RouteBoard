using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace Alpinity.Domain.ServiceResponses;

public class LocationInformationResponse
{
    public string? Location { get; set; }

    [JsonPropertyName("type")]
    public string? Type { get; set; }

    [JsonPropertyName("features")]
    public List<Feature>? Features { get; set; }

    [JsonPropertyName("attribution")]
    public string? Attribution { get; set; }
}

public class Feature
{
    [JsonPropertyName("type")]
    public string? Type { get; set; }

    [JsonPropertyName("id")]
    public string? Id { get; set; }

    [JsonPropertyName("geometry")]
    public Geometry? Geometry { get; set; }

    [JsonPropertyName("properties")]
    public Properties? Properties { get; set; }
}

public class Geometry
{
    [JsonPropertyName("type")]
    public string? Type { get; set; }

    [JsonPropertyName("coordinates")]
    public double[]? Coordinates { get; set; }
}

public class Properties
{
    [JsonPropertyName("mapbox_id")]
    public string? MapboxId { get; set; }

    [JsonPropertyName("feature_type")]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public FeatureType FeatureType { get; set; }

    [JsonPropertyName("full_address")]
    public string? FullAddress { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("name_preferred")]
    public string? NamePreferred { get; set; }

    [JsonPropertyName("coordinates")]
    public Coordinates? Coordinates { get; set; }

    [JsonPropertyName("place_formatted")]
    public string? PlaceFormatted { get; set; }

    [JsonPropertyName("context")]
    public Context? Context { get; set; }

    [JsonPropertyName("bbox")]
    public double[]? BoundingBox { get; set; }
}

public class Coordinates
{
    [JsonPropertyName("longitude")]
    public double Longitude { get; set; }

    [JsonPropertyName("latitude")]
    public double Latitude { get; set; }

    [JsonPropertyName("accuracy")]
    public string? Accuracy { get; set; }

    [JsonPropertyName("routable_points")]
    public object? RoutablePoints { get; set; }
}

public class Context
{
    [JsonPropertyName("address")]
    public Address? Address { get; set; }

    [JsonPropertyName("street")]
    public ContextItem? Street { get; set; }

    [JsonPropertyName("postcode")]
    public ContextItem? Postcode { get; set; }

    [JsonPropertyName("place")]
    public ContextItem? Place { get; set; }

    [JsonPropertyName("district")]
    public ContextItem? District { get; set; }

    [JsonPropertyName("region")]
    public Region? Region { get; set; }

    [JsonPropertyName("country")]
    public Country? Country { get; set; }
}

public class Address
{
    [JsonPropertyName("mapbox_id")]
    public string? MapboxId { get; set; }

    [JsonPropertyName("address_number")]
    public string? AddressNumber { get; set; }

    [JsonPropertyName("street_name")]
    public string? StreetName { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }
}

public class ContextItem
{
    [JsonPropertyName("mapbox_id")]
    public string? MapboxId { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("wikidata_id")]
    public string? WikidataId { get; set; }
}

public class Region : ContextItem
{
    [JsonPropertyName("region_code")]
    public string? RegionCode { get; set; }

    [JsonPropertyName("region_code_full")]
    public string? RegionCodeFull { get; set; }
}

public class Country : ContextItem
{
    [JsonPropertyName("country_code")]
    public string? CountryCode { get; set; }

    [JsonPropertyName("country_code_alpha_3")]
    public string? CountryCodeAlpha3 { get; set; }
}

public enum FeatureType
{
    Country,
    Region,
    Postcode,
    District,
    Place,
    Locality,
    Neighborhood,
    Street,
    Address
}
