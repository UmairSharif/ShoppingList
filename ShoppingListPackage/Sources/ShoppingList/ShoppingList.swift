//
//  ShoppingList.swift
//  ShoppingListPackage
//

public struct ShoppingListInfo {
    public let version: String

    public init(version: String = "0.1.0") {
        self.version = version
    }
}

public enum ShoppingListAPI {
    public static func makeInfo() -> ShoppingListInfo {
        ShoppingListInfo()
    }
}


