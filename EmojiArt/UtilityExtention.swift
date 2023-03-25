//
//  UtilityExtention.swift
//  EmojiArt
//
//  Created by Seyyed Ali Tabatabaei on 3/24/23.
//

import Foundation


extension Collection where Element : Identifiable {
    func indext(matched element: Element) -> Self.Index?{
        return firstIndex(where: {$0.id == element.id})
    }
}
