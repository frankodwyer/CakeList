//
//  Cake.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.

import Foundation

struct Cake: Decodable {
    let title: String
    let description: String
    let imageURL: URL

    enum CodingKeys: String, CodingKey {
        case description = "desc"
        case title
        case imageURL = "image"
    }
}

extension Cake {
    static func from(data: Data) -> [Cake]? {
        let decoder = JSONDecoder()
        let result: [Cake]?
        do {
            result = try decoder.decode([Cake].self, from: data)
        } catch {
            print("Failed to decode JSON")
            result = nil
        }
        return result
    }
}
