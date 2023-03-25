//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Seyyed Ali Tabatabaei on 3/24/23.
//

import SwiftUI


@main
struct EmojiArtApp: App {
    let viewModel = EmojiArtViewModel()
    var body: some Scene {
        WindowGroup {
            EmojiArtView(viewModel: viewModel)
        }
    }
}
