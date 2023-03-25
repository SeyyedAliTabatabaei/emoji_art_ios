//
//  EmojiArtViewModel.swift
//  EmojiArt
//
//  Created by Seyyed Ali Tabatabaei on 3/24/23.
//

import Foundation
import UIKit

class EmojiArtViewModel : ObservableObject{
    
    @Published private(set) var emojiArt : EmojiArtModel {
        didSet{
            autosave()
            if emojiArt.background != oldValue.background{
                fetchBackgroundImageDataIfNecessery()
            }
        }
    }
    
    private struct Autosave{
        static let filename = "Autosave.emojiart"
        static var url : URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
    }
    
    private func autosave(){
        if let url = Autosave.url{
            save(to: url)
        }
    }
    
    
    @Published var backgroundImage : UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus{
        case idle
        case fetching
    }
    
    private func save(to url : URL){
        do{
            let data : Data = try emojiArt.json()
            try data.write(to : url)
        }catch {
            print("EmojiArtViewModel.save(to:) eeror = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url , let autosavedEmojiArt = try? EmojiArtModel(url: url){
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageDataIfNecessery()
        }else{
            self.emojiArt = EmojiArtModel()
        }
    }
    
    var emojis : [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background : EmojiArtModel.Background { emojiArt.background }
    
    private func fetchBackgroundImageDataIfNecessery(){
        backgroundImage = nil
        switch emojiArt.background{
            case .url(let url) :
                // fetch url
            backgroundImageFetchStatus = .fetching
                DispatchQueue.global(qos: .userInitiated).async {
                    let imageData = try? Data(contentsOf: url)
                    DispatchQueue.main.async { [weak self] in
                        if self?.emojiArt.background == EmojiArtModel.Background.url(url){
                            self?.backgroundImageFetchStatus = .idle
                            if imageData != nil {
                                self?.backgroundImage = UIImage(data: imageData!)
                            }
                        }
                    }
                }
            case .imageData(let data) :
                backgroundImage = UIImage(data: data)
            case .blank :
                break
        }
    }
    
    //MARK: - Intent(s)
    
    func setBackground(_ background : EmojiArtModel.Background){
        emojiArt.background = background
    }
    
    func addEmoji(text : String , at location : (x : Int , y : Int) , size : CGFloat){
        emojiArt.addEmoji(text, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji : EmojiArtModel.Emoji , by offset : CGSize){
        if let index = emojiArt.emojis.indext(matched: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji : EmojiArtModel.Emoji , by scale: CGFloat){
        if let index = emojiArt.emojis.indext(matched: emoji) {
            emojiArt.emojis[index].size  = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}




