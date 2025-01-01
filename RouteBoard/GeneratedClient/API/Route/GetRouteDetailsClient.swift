import OpenAPIURLSession

public typealias RouteDetails = Components.Schemas.RouteDetailedDto;

public struct GetRouteDetailsClient {
    private let client: Client = ClientPicker.getClient()

    public init() {
    }

    public func getRouteDetails(routeId: String) async -> RouteDetails? {
        do {
            let result = try await client.get_sol_api_sol_Route(Operations.get_sol_api_sol_Route.Input(query: Operations.get_sol_api_sol_Route.Input.Query(routeId: routeId)))

            switch result {
            case let .ok(okResponse):
                switch okResponse.body {
                case .json(let value):
                    return value
                }

            case .undocumented(statusCode: _, _):
                return nil
            }
        } catch {
            print(error)
        }

        return nil
    }
}
