//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Seyyed Ali Tabatabaei on 3/24/23.
//

import Foundation

struct EmojiArtModel : Codable {
    var background = Background.blank
    var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    init( ) { }
    init(json : Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url : URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    mutating func addEmoji(_ text : String , at location : (x : Int , y : Int) , size : Int){
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, x: location.x, y: location.y, size: size))
    }
    
    func json() throws -> Data{
        return try JSONEncoder().encode(self)
    }
    
    struct Emoji : Identifiable , Hashable , Codable{
        let id : Int
        let text : String
        var x : Int
        var y : Int
        var size : Int
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
}

extension Array where Element : Identifiable {
    func indext(matched element: Element) -> Int?{
        return firstIndex(where: {$0.id == element.id})
    }
}
