import Testing
import Foundation
@testable import ShoppingList

struct RemoteDataSourceTests {
    
    @Test("Successful getAllItems request")
    func testGetAllItemsSuccess() async throws {
        let mockSession = MockURLSession()
        let items = [
            ShoppingItem(name: "Item 1"),
            ShoppingItem(name: "Item 2")
        ]
        
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        let responseData = try encoder.encode(items)
        mockSession.mockResponse = (responseData, HTTPURLResponse(
            url: URL(string: "https://api.example.com/shopping/items")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!)
        
        let remoteDataSource = MockRemoteDataSource(
            baseURL: "https://api.example.com/shopping",
            urlSession: mockSession
        )
        
        let result = try await remoteDataSource.getAllItems()
        
        #expect(result.count == 2)
        #expect(result[0].name == "Item 1")
        #expect(result[1].name == "Item 2")
    }
    
    @Test("Failed getAllItems request with HTTP error")
    func testGetAllItemsHTTPError() async throws {
        let mockSession = MockURLSession()
        mockSession.mockResponse = (Data(), HTTPURLResponse(
            url: URL(string: "https://api.example.com/shopping/items")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!)
        
        let remoteDataSource = MockRemoteDataSource(
            baseURL: "https://api.example.com/shopping",
            urlSession: mockSession
        )
        
        await #expect(throws: ShoppingListError.self) {
            try await remoteDataSource.getAllItems()
        }
    }
    
    @Test("Successful createItem request")
    func testCreateItemSuccess() async throws {
        let mockSession = MockURLSession()
        let item = ShoppingItem(name: "New Item")
        
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        let responseData = try encoder.encode(item)
        mockSession.mockResponse = (responseData, HTTPURLResponse(
            url: URL(string: "https://api.example.com/shopping/items")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!)
        
        let remoteDataSource = MockRemoteDataSource(
            baseURL: "https://api.example.com/shopping",
            urlSession: mockSession
        )
        
        let result = try await remoteDataSource.createItem(item)
        
        #expect(result.name == "New Item")
        #expect(result.id == item.id)
    }
    
    @Test("Successful updateItem request")
    func testUpdateItemSuccess() async throws {
        let mockSession = MockURLSession()
        let item = ShoppingItem(name: "Updated Item")
        
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        let responseData = try encoder.encode(item)
        mockSession.mockResponse = (responseData, HTTPURLResponse(
            url: URL(string: "https://api.example.com/shopping/items/\(item.id.uuidString)")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!)
        
        let remoteDataSource = MockRemoteDataSource(
            baseURL: "https://api.example.com/shopping",
            urlSession: mockSession
        )
        
        let result = try await remoteDataSource.updateItem(item)
        
        #expect(result.name == "Updated Item")
        #expect(result.id == item.id)
    }
    
    @Test("Successful deleteItem request")
    func testDeleteItemSuccess() async throws {
        let mockSession = MockURLSession()
        let itemId = UUID()
        
        mockSession.mockResponse = (Data(), HTTPURLResponse(
            url: URL(string: "https://api.example.com/shopping/items/\(itemId.uuidString)")!,
            statusCode: 204,
            httpVersion: nil,
            headerFields: nil
        )!)
        
        let remoteDataSource = MockRemoteDataSource(
            baseURL: "https://api.example.com/shopping",
            urlSession: mockSession
        )
        
        // Should not throw
        try await remoteDataSource.deleteItem(by: itemId)
    }
    
    @Test("Invalid response type throws network error")
    func testInvalidResponseType() async throws {
        let mockSession = MockURLSession()
        mockSession.mockResponse = (Data(), URLResponse())
        
        let remoteDataSource = MockRemoteDataSource(
            baseURL: "https://api.example.com/shopping",
            urlSession: mockSession
        )
        
        await #expect(throws: ShoppingListError.self) {
            try await remoteDataSource.getAllItems()
        }
    }
}

class MockURLSession: URLSession {
    var mockResponse: (Data, URLResponse)?
    var mockError: Error?
    
    override func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse else {
            throw URLError(.unknown)
        }
        
        return response
    }
    
    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse else {
            throw URLError(.unknown)
        }
        
        return response
    }
}