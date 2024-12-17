//
//  SearchResultView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 01.11.2024..
//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession


final class InsecureURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Trust the server certificate regardless of its validity
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}


struct SearchResultView: View {
    @Binding var searchText: String
    @State var results: [Components.Schemas.SearchResultItemDto] = []
    
    let client: Client;
    
    init(searchText: Binding<String>) {
        _searchText = searchText
        
        // Set up the URLSession with the insecure delegate for local development
        let session = URLSession(configuration: .default, delegate: InsecureURLSessionDelegate(), delegateQueue: nil)
        client = Client(serverURL: URL(string: "https://localhost:7244")!, transport: URLSessionTransport(configuration: .init(session: session)))
    }
    
    func search(value: String) async {
        do {
            let result = try await client.post_sol_api_sol_Search(Operations.post_sol_api_sol_Search.Input(body: .json(Components.Schemas.SearchQueryCommand(query: value))))
            
            switch result {
                
            case let .ok(okResponse):
                switch okResponse.body {
                case .json(let value):
                    results = value.items ?? [];
                case .plainText(_):
                    results = [];
                case .text_json(_):
                    results = [];
                }
                
            case .undocumented(statusCode: _, _):
                results = [];
            }
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        VStack {
            Text("Search results for: \(searchText)")
                .foregroundStyle(.black)
                .onChange(of: searchText) { value in
                    Task {
                        await search(value: value)
                    }
                }
            
            
            if results.isEmpty {
                Text("No results found")
                    .foregroundStyle(.red)
            } else {
                // Safely unwrap `results.items` with optional binding
                List(results, id: \.self.id) { result in
                    Text(result.name ?? "")
                }
            }
            
        }
    }
}
