

import Foundation

struct Building: Decodable, CustomStringConvertible {
    let name: String
    let summary: String
    private let food: String
    private let floors: Int
    
    var foodString: String {
        return "Food: \(food)"
    }
    
    var floorString: String {
        return "Floors: \(floors)"
    }
    
    var description: String {
        return "\(name): \(summary), \(foodString) and \(floorString)"
    }
}
