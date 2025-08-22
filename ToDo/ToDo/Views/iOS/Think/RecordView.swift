//
//  RecordView.swift
//  Summary
//
//  Created by LQ on 2024/10/19.
//

import SwiftUI
//import SDWebImageSwiftUI
import PhotosUI
import AVKit

struct RecordView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var showingEditRecordView: Bool = false
    static var selectEditRecordItem: RecordItem? = nil
    static var selectAssetID: String? = nil
    @State var showingImageView: Bool = false
    @State var showingVideoView: Bool = false
    @State var selectionIndex: Int = 0
    @State var toggleToRefresh: Bool = false
    
    @State var recordItems: [RecordItem] = []
    var body: some View {
        NavigationView(content: {
            VStack(alignment: .leading, content: {
//                HStack(alignment: .top) {
//                    Text("记录").font(.title.bold()).foregroundStyle(.blue)
//                    Spacer()
//                }.padding(.leading, 15)
//                
//                if toggleToRefresh {
//                    Text("")
//                }
                
                
                List {
                    ForEach(recordItems, id: \.self.id) { item in
                        RecordItemView(item: item, contentClick: {
                            Self.selectEditRecordItem = item
                            self.showingEditRecordView.toggle()
                        }, imageClick: { selectionIndex, isImage, assetID in
                            
                            Self.selectEditRecordItem = item
                            Self.selectAssetID = assetID
                            self.selectionIndex = selectionIndex
                            if isImage {
                                self.showingImageView.toggle()
                            } else {
                                self.showingVideoView.toggle()
                            }
                        })
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                    }.onDelete(perform: { indexSet in
                        for index in indexSet.makeIterator() {
                            let item = recordItems[index]
                            modelData.deleteRecordModel(item)
                        }
                    })
                }
                .padding(.zero)
                    .listStyle(.plain)
//                    .refreshable {
//                        modelData.loadFromServer {
//                            self.toggleToRefresh.toggle()
//                        }
//                    }
            })
            .padding(.zero)
        })
        .padding(.zero)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                Self.selectEditRecordItem = nil
                showingEditRecordView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            })
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
        })
        .onAppear(perform: {
            self.recordItems = modelData.recordList.sorted { $0.displayTime.timeIntervalSince1970 > $1.displayTime.timeIntervalSince1970
            }
        })
        .sheet(isPresented: $showingEditRecordView, content: {
            if let item = Self.selectEditRecordItem {
                RecordEditView(showingEditView: $showingEditRecordView, recordItem: item)
                    .environmentObject(modelData)
            } else {
                RecordEditView(showingEditView: $showingEditRecordView)
                    .environmentObject(modelData)
            }
        })
#if os(iOS)
        .fullScreenCover(isPresented: $showingImageView, content: {
            if let item = Self.selectEditRecordItem {
                ImageCarousel(selection: self.selectionIndex, isFullScreenModalPresented: $showingImageView, images: item.imageList)
            }
        })
        .fullScreenCover(isPresented: $showingVideoView, content: {
            VideoPlayerView(isFullScreenModalPresented: $showingVideoView, assetID: Self.selectAssetID)
        })
        #endif

    }
}


