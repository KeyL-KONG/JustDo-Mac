//
//  ImageCarousel.swift
//  Summary
//
//  Created by LQ on 2024/11/2.
//

import SwiftUI

struct ImageCarousel: View {
    
    @State var selection = 0
    
    @Binding var isFullScreenModalPresented: Bool
    
    var images: [String] = []
    
    var body: some View {
        
        ZStack(content: {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.bottom)
            
            TabView(selection: $selection,
                    content:  {
                ForEach(0..<images.count, id: \.self) { index in
                    ImageView(assetID: images[index], imageSize: 0, scaleToFill: false)
                }
            })
#if os(iOS)
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            #endif
            
            closeButton()
        })
        
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

#Preview {
    ImageCarousel(isFullScreenModalPresented: .constant(true), images: ["lake-boat","swim-water","mounatins", "town"])
}
