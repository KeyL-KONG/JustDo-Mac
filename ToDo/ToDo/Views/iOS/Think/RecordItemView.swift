//
//  RecordItemView.swift
//  Summary
//
//  Created by LQ on 2024/11/2.
//

import SwiftUI
import PhotosUI

struct RecordItemView: View {
    
    var item: RecordItem
    var contentClick: () -> ()
    var imageClick: (Int, Bool, String) -> ()
    
    let avatarSize = 40.0
    @State var imageSize = 80.0
    @State var selectPicture: PhotosPickerItem?
    @State var showPhotoPicker: Bool = false
    @State var isPresentPicture: Bool = false
    @EnvironmentObject var modelData: ModelData
    
    @State var selectAssetID: String?
    var selectionIndex: Int {
        var selection = 0
        if let selectAssetID, let index = item.imageList.firstIndex(of: selectAssetID) {
            selection = index
        }
        return selection
    }
    
    struct EvaluateDisplayItem: Identifiable {
        var id: String {
            content
        }
        
        let content: String
        let color: Color
    }
    
//    var evaluateList: [EvaluateDisplayItem] {
//        let count = min(item.evaluateIds.count, item.evaluateValues.count)
//        guard count > 0 else { return [] }
//        var list = [EvaluateDisplayItem]()
//        for index in  0 ..< count {
//            if let evaluateItem = modelData.evaluateItems.first(where: { $0.id == item.evaluateIds[index]
//            }) {
//                let val = item.evaluateValues[index]
//                let content = "\(evaluateItem.content) \(val > 0 ? "+":"")\(val)"
//                list.append(EvaluateDisplayItem.init(content: content, color: evaluateItem.displayColor))
//            }
//        }
//        return list
//    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            HStack(alignment: .top, content: {
//                if let avatar = modelData.userItem?.avatar {
//                    ImageView(assetID: avatar, imageSize: avatarSize)
//                        .frame(width: avatarSize, height: avatarSize)
//                        .cornerRadius(avatarSize / 2.0)
//                        .onTapGesture {
//                            showPhotoPicker.toggle()
//                        }
//                } else {
                    Circle().foregroundColor(.gray)
                        .frame(width: avatarSize, height: avatarSize)
                        .onTapGesture {
                            showPhotoPicker.toggle()
                        }
                //}
                
                VStack(alignment: .leading, spacing: 5, content: {
                    Text(item.content)
                    
                    if item.mediaList.count > 0 {
                        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                            GridRow {
                                ForEach(0..<min(3, item.mediaList.count), id: \.self) { index in
                                    if index < item.mediaList.count {
                                        let assetID = item.mediaList[index]
                                        itemMediaView(assetID: assetID)
                                    }
                                }
                            }
                            if item.mediaList.count > 3 {
                                GridRow {
                                    ForEach(3..<min(6, item.mediaList.count), id: \.self) { index in
                                        if index < item.mediaList.count {
                                            let assetID = item.mediaList[index]
                                            itemMediaView(assetID: assetID)
                                        }
                                    }
                                }
                                
                            }
                            if item.imageList.count > 6 {
                                GridRow {
                                    ForEach(6..<min(9, item.mediaList.count), id: \.self) { index in
                                        if index < item.mediaList.count {
                                            let assetID = item.mediaList[index]
                                            itemMediaView(assetID: assetID)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    HStack {
//                        if evaluateList.count > 0 {
//                            ForEach(evaluateList) { item in
//                                Text(item.content)
//                                    .font(.system(size: 12))
//                                    .bold()
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(item.color)
//                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                            }
//                        }
                        Spacer()
                        Text(item.displayTime.simpleDateStr).font(.system(size: 12)).foregroundColor(.gray.opacity(0.5))
                    }
                }).padding(.trailing, 15)
                    .padding(.leading, 5)
                
                Spacer()
            })
        
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.1)).padding(.top, 10)
        })
        .contentShape(Rectangle())
        .onTapGesture {
            contentClick()
        }
        .padding(0)
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectPicture, matching: .images, photoLibrary: .shared())
//#if os(iOS)
//        .onChange(of: selectPicture) { oldValue, newValue in
//            if let assetID = selectPicture?.itemIdentifier {
//                let userItem: UserItem = modelData.userItem ?? UserItem()
//                userItem.avatar = assetID
//                modelData.updateUserItem(userItem)
//            }
//        }
//        #endif
    
    }
    
    
    func itemMediaView(assetID: String) -> some View {
        if item.isImage(assetID: assetID) {
            return AnyView(
                ImageView(assetID: assetID, imageSize: imageSize)
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(10.0)
                    .onTapGesture {
                        self.selectAssetID = assetID
                        self.imageClick(selectionIndex, true, assetID)
                    }
            )
        } else {
            return AnyView(
                VideoView(assetID: assetID, previewSize: CGSize(width: imageSize, height: imageSize)) {
                    self.selectAssetID = assetID
                    self.imageClick(selectionIndex, false, assetID)
                }
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(10.0)
            )
        }
        
    }
    
}

