//
//  RecordEditView.swift
//  Summary
//
//  Created by LQ on 2024/10/27.
//

import SwiftUI
import PhotosUI

struct RecordEditView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showingEditView: Bool
    @State var contentTitle: String = ""
    @State var imageList: [String] = []
    @State var recordItem: RecordItem? = nil
    
    @State var selectPictures: [PhotosPickerItem] = []
    @State var debugString: String?
    
    @State var imageSize: CGFloat = 150.0
    
    @State var showingImageView: Bool = false
    @State var showPhotoPicker: Bool = false
    
    @State var videoList: [String] = []
    @State var showVideoPicker: Bool = false
    @State var showingVideoView: Bool = false
    @State var selectVideos: [PhotosPickerItem] = []
    
    static var selectedVideoAssetID: String?
    
    @State var selectAssetID: String?
    var selectionIndex: Int {
        var selection = 0
        if let selectAssetID, let index = imageList.firstIndex(of: selectAssetID) {
            selection = index
        }
        return selection
    }
    
    @FocusState private var focusedField: FocusedField?
    enum FocusedField {
        case content
    }
    
    @State var recordTime: Date = .now
    
    @State var selectEvaluate: String = ""
    @State var evaluateValue: Int = 1
    var evaluateValues: [Int] = [-5, -3, -1, 1, 3, 5]
    
//    var evaluateList: [String] {
//         ["无"] + modelData.evaluateItems.compactMap { $0.content }
//    }
    
    
    var body: some View {
        
        NavigationView(content: {
            VStack(content: {
#if os(iOS)
                Text("")
                    .navigationBarTitle(Text("记录"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        self.showingEditView = false
                    }, label: {
                        Text("取消").bold()
                    }), trailing: Button(action: {
                        self.showingEditView = false
                        self.updateItem()
                    }, label: {
                        Text("保存").bold()
                    }))
#endif
                
//                if let debugString {
//                    Text(debugString)
//                }
                
                List {
                    
                    //Section {
                        ZStack(alignment: .topLeading) {
//                            Color.blue
//                                .opacity(0.3)
//                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                            TextEditor(text: $contentTitle)
                                .frame(minHeight: 60, alignment: .leading)
                                .cornerRadius(6.0)
                                .multilineTextAlignment(.leading)
                                //.padding(9)
                                .focused($focusedField, equals: .content)
                        }
                        .frame(height: 100)
                        //.padding(.init(top: -10, leading: -10, bottom: -10, trailing: -10))
                    //}
                    
                    Section(header: HStack(content: {
                        Text("图片")
                        Spacer()
                        Image(systemName: "photo")
                            .onTapGesture {
                                showPhotoPicker.toggle()
                            }
                    })) {
                        if imageList.count > 0 {
                            
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 10, content: {
                                    ForEach(imageList, id: \.self) { assetID in
                                        ZStack {
                                            ImageView(assetID: assetID, imageSize: 60)
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(5)
                                                .onTapGesture {
                                                    self.selectAssetID = assetID
                                                    self.showingImageView.toggle()
                                                }
                                            
                                            closeButton(assetID: assetID)
                                        }
                                        
                                    }
                                })
                            }
                        } else {
                            Image(systemName: "photo")
                                .frame(width: 60, height: 60)
                                .onTapGesture {
                                    showPhotoPicker.toggle()
                                }
                        }
                    }
                    
                    Section(header: HStack(content: {
                        Text("视频")
                        Spacer()
                        Image(systemName: "person.crop.square.badge.video")
                            .onTapGesture {
                                showVideoPicker.toggle()
                            }
                    })) {
                        if videoList.count > 0 {
                            
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 10, content: {
                                    ForEach(videoList, id: \.self) { assetID in
                                        ZStack {
                                            
                                            VideoView(assetID: assetID, previewSize: CGSizeMake(60, 60), showCover: true) {
                                                Self.selectedVideoAssetID = assetID
                                                self.showingVideoView.toggle()
                                            }
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(5)
                                                                
                                            closeButton(assetID: assetID)
                                        }
                                        
                                    }
                                })
                            }
                        } else {
                            Image(systemName: "person.crop.square.badge.video")
                                .frame(width: 60, height: 60)
                                .onTapGesture {
                                    showVideoPicker.toggle()
                                }
                        }
                    }
                    
//                    Section {
//                        Picker("选择标签", selection: $selectEvaluate) {
//                            ForEach(evaluateList, id: \.self) { tag in
//                                Text(tag).tag(tag)
//                            }
//                        }
//                        if selectEvaluate.count > 0, selectEvaluate != "无" {
//                            Picker(selectEvaluate, selection: $evaluateValue) {
//                                ForEach(evaluateValues, id: \.self) { val in
//                                    Text("\(selectEvaluate) \(val > 0 ? "+": "")\(val)")
//                                }
//                            }
//                        }
//                    }
                    
                    Section {
                        DatePicker("设置时间", selection: $recordTime, displayedComponents: [.date, .hourAndMinute])
                    }
                
                }
#if os(iOS)
                .listSectionSpacing(10)
                #endif
            })
        })
        .photosPicker(isPresented: $showVideoPicker, selection: $selectVideos, maxSelectionCount: 9, matching: .videos, photoLibrary: .shared())
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectPictures, maxSelectionCount: 9, matching: .images, photoLibrary: .shared())
#if os(iOS)
        .onChange(of: selectPictures, { oldValue, newValue in
            self.appendDebugString("select picktures")
            selectPictures.forEach { item in
                if let assetID = item.itemIdentifier {
                    if !self.imageList.contains(where: { $0 == assetID }) {
                        self.imageList.append(assetID)
                    }
                    self.appendDebugString("select photo: \(assetID)")
                }
                self.appendDebugString("foreach item")
            }
        })
        .onChange(of: selectVideos, { oldValue, newValue in
            selectVideos.forEach { item in
                if let assetID = item.itemIdentifier {
                    if !self.videoList.contains(where: { $0 == assetID }) {
                        self.videoList.append(assetID)
                    }
                }
            }
        })
        #endif
        .onAppear(perform: {
            Self.selectedVideoAssetID = nil
            if let recordItem {
                self.contentTitle = recordItem.content
                self.imageList = recordItem.imageList
                self.videoList = recordItem.videoList
                self.recordTime = recordItem.displayTime
//                if let evaluateId = recordItem.evaluateIds.first, let item = modelData.evaluateItems.first(where: { $0.id == evaluateId }) {
//                    self.selectEvaluate = item.content
//                    self.evaluateValue = recordItem.evaluateValues.first ?? 1
//                }
                self.focusedField = .content
            }
        })
#if os(iOS)
        .fullScreenCover(isPresented: $showingImageView, content: {
            ImageCarousel(selection: self.selectionIndex, isFullScreenModalPresented: $showingImageView, images: self.imageList)
        })
        .fullScreenCover(isPresented: $showingVideoView, content: {
            VideoPlayerView(isFullScreenModalPresented: $showingVideoView, assetID: Self.selectedVideoAssetID)
        })
        #endif
    }
    
    func closeButton(assetID: String) -> some View {
        VStack(content: {
            HStack(content: {
                Spacer()
                Button(action: {
                    self.videoList.removeAll { $0 == assetID }
                    self.imageList.removeAll { $0 == assetID }
                    self.selectPictures.removeAll { item in
                        item.itemIdentifier == assetID
                    }
                    self.selectVideos.removeAll { item in
                        item.itemIdentifier == assetID
                    }
                    self.updateItem()
                   }) {
                       Image(systemName: "xmark.circle.fill")
                           .foregroundColor(.red) // 设置按钮颜色
                           .font(.system(size: 15))
                           .offset(x: 5)
                   }
            })
            Spacer()
        })

    }
    
    func updateItem() {
        let item = self.recordItem ?? RecordItem()
        item.content = contentTitle
        item.imageList = imageList
        item.videoList = videoList
        item.recordTime = recordTime
//        if let evaluteItem = modelData.evaluateItems.first(where: { $0.content == selectEvaluate }), !item.evaluateIds.contains(evaluteItem.id) {
//            item.evaluateIds.append(evaluteItem.id)
//            item.evaluateValues.append(evaluateValue)
//        }
        if selectEvaluate == "无" {
            item.evaluateIds.removeAll()
            item.evaluateValues.removeAll()
        }
        modelData.updateRecordModel(item)
    }
    
    
    func appendDebugString(_ content: String) {
        if let debugString {
            self.debugString = debugString + "\n" + content
        } else {
            self.debugString = content
        }
    }
    
}

#Preview {
    RecordEditView(showingEditView: .constant(false), contentTitle: "测试内容", imageList: [], recordItem: nil, selectPictures: [], debugString: nil, imageSize: 20, showingImageView: false, showPhotoPicker: false, selectAssetID: nil)
}
