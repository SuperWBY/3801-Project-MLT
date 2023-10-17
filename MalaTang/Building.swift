import Foundation

struct Building: Decodable, CustomStringConvertible {
    let name: String
    let summary: String
    private let source: String
    private let material: String
    
    var sourceString: String {
        return "Source: \(source)"
    }
    
    var materialString: String {
        return "Material: \(material)"
    }
    
    var description: String {
        return "\(name): \(summary), \(sourceString) and \(materialString)"
    }
}
