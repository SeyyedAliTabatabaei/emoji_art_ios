//
//  ContentView.swift
//  EmojiArt
//
//  Created by Seyyed Ali Tabatabaei on 3/24/23.
//

import SwiftUI

struct EmojiArtView: View {
    
    @ObservedObject var viewModel : EmojiArtViewModel
    let defultEmojifontSize : CGFloat = 40
    
    
    var body: some View {
        VStack(spacing : 0) {
            emojiArtBody
            pallete
        }
    }
    
    var emojiArtBody : some View{
        GeometryReader{ geometry in
            ZStack{
                Color.white.overlay(
                    OptionalImage(uiImage: viewModel.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                )
                .gesture(doubleTapToZoom(in : geometry.size))
                if viewModel.backgroundImageFetchStatus == .fetching{
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(viewModel.emojis){emoji in
                        Text(emoji.text )
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for : emoji , in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText , .url , .image], isTargeted: nil){ provides , location in
                return drop(provides: provides, at: location, in: geometry)
                
            }
            .gesture(penGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    private func drop(provides : [NSItemProvider] , at location : CGPoint , in geometry : GeometryProxy) -> Bool{
        
        var found = provides.loadObjects(ofType: URL.self){ url in
            viewModel.setBackground(.url(url.imageURL))
        }
        
        if !found{
            found = provides.loadObjects(ofType: UIImage.self){ image in
                if let data = image.jpegData(compressionQuality: 1.0){
                    viewModel.setBackground(.imageData(data))
                }
            }
        }
        
        if !found{
            found = provides.loadFirstObject(ofType: String.self){ string in
                if let emoji = string.first , emoji.isEmoji{
                    viewModel.addEmoji(text: String(emoji), at: convertToEmojiCoordinates(location, in: geometry), size: defultEmojifontSize / zoomScale)
                }
            }
        }
        
        return found
    }
    
    private func fontSize(for emoji : EmojiArtModel.Emoji) -> CGFloat{
        CGFloat(emoji.size)
    }
    
    @State private var steadyStatePenOffset : CGSize = CGSize.zero
    @GestureState private var gesturePenOffset : CGSize = CGSize.zero
    
    private var penOffset : CGSize {
        (steadyStatePenOffset + gesturePenOffset) * zoomScale
    }
    
    private func penGesture() -> some Gesture{
        DragGesture()
            .updating($gesturePenOffset){ latestDragGestureValue , gesturePrnOffset , _ in
                gesturePrnOffset = latestDragGestureValue.translation / zoomScale
                
            }
            .onEnded{ finalDragGestureValue in
                steadyStatePenOffset = steadyStatePenOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    @State private var steadyStateZoomScale : CGFloat = 1
    @GestureState private var gestureZoomScale : CGFloat = 1
    
    private var zoomScale : CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture{
        MagnificationGesture()
            .updating($gestureZoomScale){latestGestureScale ,  gestureZoomScale , transaction in
                gestureZoomScale = latestGestureScale
                
            }
            .onEnded{ gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapToZoom(in size : CGSize) -> some Gesture{
        TapGesture(count: 2)
            .onEnded{
                withAnimation{
                    zoomToFit(viewModel.backgroundImage, in: size)
                }
            }
    }
    private func zoomToFit(_ image : UIImage? , in size : CGSize){
        if let image = image , image.size.width > 0 , image.size.height > 0 , size.width > 0 ,size.height > 0{
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePenOffset = .zero
            steadyStateZoomScale = min(hZoom,  vZoom)
        }
    }
    
    private func position(for emoji : EmojiArtModel.Emoji , in geometry : GeometryProxy) -> CGPoint{
        convertFromEmojiCoordinates((emoji.x , emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location : CGPoint , in geometry : GeometryProxy) ->
    (x : Int , y : Int){
        let center = geometry.frame(in : .local).center
        let location = CGPoint(
            x: (location.x - penOffset.width - center.x) / zoomScale,
            y: (location.y - penOffset.height - center.y) / zoomScale
        )
        return (Int(location.x) , Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location : (x : Int , y : Int) , in geometry : GeometryProxy) ->
    CGPoint{
        let center = geometry.frame(in : .local).center
         return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + penOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + penOffset.height
         )
    }
    
    var pallete : some View{
        ScrollingEmojisView(emojies: testEmojis)
            .font(.system(size: defultEmojifontSize))
    }
    let testEmojis = "🏍️😀🏎️🚲🚑🛻🚙🚎🚓😙😝😜🤓😈🤠🤡💋🦷👁️"
}


struct ScrollingEmojisView : View{
    let emojies : String
    var body: some View{
        ScrollView(.horizontal){
            HStack{
                ForEach(emojies.map { String($0) } , id: \.self ){ emoji in
                    Text(emoji)
                        .onDrag{ NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtView(viewModel: EmojiArtViewModel())
    }
}
