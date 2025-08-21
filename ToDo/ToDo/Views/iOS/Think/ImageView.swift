//
//  ImageView.swift
//  Summary
//
//  Created by LQ on 2024/11/2.
//

import SwiftUI
//import SDWebImageSwiftUI
import PhotosUI
import AVKit

struct ImageView: View {
    
    var assetID: String?
    var imageSize: CGFloat
    var scaleToFill: Bool = true
#if os(iOS)
    @State var image: UIImage?
#endif
    
#if os(macOS)
    @State var image: NSImage?
#endif
    
    var body: some View {
        VStack(content: {
            if let image {
                if scaleToFill {
#if os(iOS)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
#endif
#if os(macOS)
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
#endif
                } else {
                    
#if os(iOS)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
#endif
#if os(macOS)
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
#endif
                }
                
            } else {
                Rectangle().foregroundColor(.gray)
            }
        })
        .background(content: {
            Rectangle().foregroundColor(.gray).opacity(0.01)
        })
        .padding(.zero)
        .onAppear(perform: {
            if let assetID {
                loadImage(with: assetID)
            }
        })
    }
    
    func loadImage(with identifier: String) {
        Task {
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else {
                return
            }
            
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: .max, height: .max), contentMode: .aspectFit, options: options) { image, _ in
                self.image = image
            }
        }
    }
}
