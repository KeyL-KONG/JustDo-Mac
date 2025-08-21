//
//  VideoPlayerView.swift
//  Summary
//
//  Created by LQ on 2025/7/5.
//

import SwiftUI
import AVKit
import Photos
import PhotosUI

struct VideoPlayerView: View {
    
    @Binding var isFullScreenModalPresented: Bool
    
    var assetID: String?
    
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    
    var body: some View {
        ZStack(content: {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.bottom)
            
            VideoPlayer(player: player)
            
            closeButton()
        })
        .onAppear {
            self.loadVideo()
        }
    }
    
    func closeButton() -> some View {
        VStack(content: {
            HStack(content: {
                Spacer()
                Button(action: {
                       isFullScreenModalPresented = false
                   }) {
                       Image(systemName: "xmark.circle.fill")
                           .foregroundColor(.white) // 设置按钮颜色
                           .opacity(0.8) // 设置透明度
                           .font(.title)
                           .padding() // 添加内边距
                           .padding(5) // 外边距，调整按钮位置
                   }
            })
            Spacer()
        })

    }
    
}

extension VideoPlayerView {
    
    private func loadVideo() {
        guard let assetID = self.assetID else { return }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
        guard let asset = assets.firstObject else { return }
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
            guard let avAsset else {
                print("视频加载失败:", info?[PHImageErrorKey] ?? "未知错误")
                return
            }
            
            DispatchQueue.main.async {
                self.playerItem = AVPlayerItem(asset: avAsset)
                self.player = AVPlayer(playerItem: self.playerItem)
                self.player?.play()
            }
        }
    }
    
}
