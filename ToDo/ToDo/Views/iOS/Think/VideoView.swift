import SwiftUI
import AVKit
import Photos
import PhotosUI

struct VideoView: View {
    var assetID: String
    var previewSize: CGSize
    var showCover: Bool = false
    
    var clickEvent: (() -> Void)? = nil
    @State private var thumbnailImage: UIImage?
    
    var playSize: CGFloat {
        previewSize.width * 0.2
    }

    var body: some View {
        ZStack {
            if let thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: previewSize.width, height: previewSize.height)
                    .overlay(Color.black.opacity(0.3))
                    .onTapGesture {
                        clickEvent?()
                    }
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: previewSize.width, height: previewSize.height)
                    .onTapGesture {
                        clickEvent?()
                    }
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
        guard let asset = assets.firstObject else { return }
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: previewSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            self.thumbnailImage = image
        }
    }
}
