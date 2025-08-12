import Foundation

public protocol RemoteDataSource {
    func getAllItems() async throws -> [ShoppingItem]
    func createItem(_ item: ShoppingItem) async throws -> ShoppingItem
    func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem
    func deleteItem(by id: UUID) async throws
}

public class MockRemoteDataSource: RemoteDataSource {
    private let baseURL: String
    private let urlSession: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(baseURL: String, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    public func getAllItems() async throws -> [ShoppingItem] {
        let url = URL(string: "\(baseURL)/items")!
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShoppingListError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ShoppingListError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        do {
            return try decoder.decode([ShoppingItem].self, from: data)
        } catch {
            throw ShoppingListError.networkError("Failed to decode response: \(error.localizedDescription)")
        }
    }
    
    public func createItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        let url = URL(string: "\(baseURL)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(item)
        } catch {
            throw ShoppingListError.networkError("Failed to encode item: \(error.localizedDescription)")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShoppingListError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 201 else {
            throw ShoppingListError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        do {
            return try decoder.decode(ShoppingItem.self, from: data)
        } catch {
            throw ShoppingListError.networkError("Failed to decode response: \(error.localizedDescription)")
        }
    }
    
    public func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        let url = URL(string: "\(baseURL)/items/\(item.id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(item)
        } catch {
            throw ShoppingListError.networkError("Failed to encode item: \(error.localizedDescription)")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShoppingListError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ShoppingListError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        do {
            return try decoder.decode(ShoppingItem.self, from: data)
        } catch {
            throw ShoppingListError.networkError("Failed to decode response: \(error.localizedDescription)")
        }
    }
    
    public func deleteItem(by id: UUID) async throws {
        let url = URL(string: "\(baseURL)/items/\(id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ShoppingListError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 204 else {
            throw ShoppingListError.networkError("HTTP \(httpResponse.statusCode)")
        }
    }
}