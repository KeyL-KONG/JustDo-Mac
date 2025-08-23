//
//  iOSReadReviewView.swift
//  ToDo
//
//  Created by LQ on 2025/8/18.
//
#if os(iOS)

import SwiftUI

struct iOSReadReviewView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State var unReviewItems: [ReadModel] = []
    @State var isLoading: Bool = false
    @State var currentIndex = 0
    
    @StateObject var timer = CommonTimerModel()
    
    @State var startTime: Date? = nil
    @State var showTimelineView: Bool = false
    private static var selectedTimeItem: TaskTimeItem? = nil
    @State var showEidtReadView: Bool = false
    @State var showMarkText: Bool = false
    @State var mark: String = ""
    @Binding var showErrorAlert: Bool
    
    // 添加拖拽偏移状态
    @State private var dragOffset: CGSize = .zero
    
    var currentReadItem: ReadModel? {
        guard currentIndex >= 0 && currentIndex < unReviewItems.count else { return nil }
        return unReviewItems[currentIndex]
    }
    
    var body: some View {
        ZStack {
            VStack {
                if unReviewItems.isEmpty {
                    Text("empty").font(.largeTitle)
                } else if let currentReadItem, let noteUrl = URL(string: currentReadItem.url) {
                    UniversalWebViewContainer(urlString: currentReadItem.url, title: currentReadItem.title)
                        .id(currentReadItem.id)
                        // 添加拖拽手势识别
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    // 计算滑动距离和速度
                                    let dragThreshold: CGFloat = 50
                                    let velocityThreshold: Double = 500
                                    
                                    // 判断是否满足滑动条件
                                    if abs(value.translation.width) > dragThreshold &&
                                        abs(value.predictedEndTranslation.width) > dragThreshold &&
                                        abs(value.velocity.width) > velocityThreshold {
                                        
                                        // 向右滑动，切换到上一个
                                        if value.translation.width > 0 {
                                            updateIndex(step: -1)
                                        }
                                        // 向左滑动，切换到下一个
                                        else {
                                            updateIndex(step: 1)
                                        }
                                    }
                                    
                                    // 重置拖拽偏移
                                    dragOffset = .zero
                                }
                        )
                    
                    HStack {
                        
                        if timer.isTiming  {
                            Button("记录阅读") {
                                self.updateReadTime()
                                timer.stopTimer()
                            }.buttonStyle(ScoreButtonStyle(color: .blue))
                        } else {
                            Button("开始阅读") {
                                startTime = Date()
                                timer.startTimer(item: currentReadItem)
                            }.buttonStyle(ScoreButtonStyle(color: .blue))
                        }
                        
                        Button("笔记") {
                            self.mark = currentReadItem.note ?? ""
                            self.showMarkText.toggle()
                        }.buttonStyle(ScoreButtonStyle(color: .purple))
                        
                        Button("编辑") {
                            self.showEidtReadView.toggle()
                        }.buttonStyle(ScoreButtonStyle(color: .brown))
                
                }
                Spacer()
            }
        }
        .overlay(alignment: .topTrailing, content: {
            HStack(content: {
                
                
                Spacer()
                
                Button {
                    updateItems()
                } label: {
                    Text("刷新").foregroundStyle(.blue)
                }
                
                Button {
                    if let currentReadItem {
                        modelData.deleteReadModel(currentReadItem)
                        updateItems()
                    }
                } label: {
                    Text("删除").foregroundStyle(.red)
                }

                if timer.timeSeconds > 0 {
                    Text(timer.timeSeconds.timeStr).foregroundStyle(.yellow)
                }
                
                Text("\(currentIndex+1) / \(self.unReviewItems.count)").bold().foregroundStyle(.blue)
            })
            .offset(x: -20, y: -40)
        })
        .sheet(isPresented: $showEidtReadView) {
            if let currentReadItem {
                iOSReadEditView(readItem: currentReadItem, showSheetView: $showEidtReadView, showErrorAlert: $showErrorAlert)
                    .environmentObject(modelData)
            }
        }
        .sheet(isPresented: $showTimelineView, content: {
            if let item = Self.selectedTimeItem {
                EditTimeLineRowView(showSheetView: $showTimelineView, item: item)
                    .environmentObject(modelData)
                    .presentationDetents([.height(450)])
            }
        })
        .sheet(isPresented: $showMarkText, onDismiss: {
            
        }, content: {
            iOSEditTextView(text: $mark, disappearCallback: {
                if let currentReadItem {
                    currentReadItem.note = mark
                    modelData.updateReadModel(currentReadItem)
                }
            })
                .presentationDetents([.height(100)])
                .environmentObject(modelData)
        })
        .onChange(of: modelData.updateDataIndex, { oldValue, newValue in
            if unReviewItems.isEmpty {
                updateItems()
            }
            
        })
//        .onChange(of: modelData.updateNoteIndex, { oldValue, newValue in
//            updateItems()
//        })
        .onAppear {
            if unReviewItems.isEmpty {
                updateItems()
            }
//            startTime = Date()
//            if let currentReadItem {
//                timer.startTimer(item: currentReadItem)
//            }
        }
        .onDisappear {
            timer.stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//            if !timer.isTiming {
//                updateItems()
//            }
        }
    }
    
}

extension iOSReadReviewView {
    
    func updateIndex(step: Int) {
        self.currentIndex = max(self.currentIndex + step, 0) % self.unReviewItems.count
        
        startTime = Date()
        timer.stopTimer()
        if let currentReadItem {
            timer.startTimer(item: currentReadItem)
        }
    }
    
    func updateItems() {
        self.unReviewItems = modelData.readList.filter({ read in
            if read.title.isEmpty { return true }
            if read.tags.isEmpty { return true }
            return false
        }).shuffled()
        currentIndex = 0
    }
    
    func updateReadTime(content: String = "") {
        guard let startTime, let currentReadItem else { return }
        let timeInterval = TimeInterval(timer.timeSeconds)
        let endTime = startTime.addingTimeInterval(timeInterval)
        let timeItem = TaskTimeItem(startTime: startTime, endTime: endTime, content: "")
        timeItem.eventId = currentReadItem.id
        Self.selectedTimeItem = timeItem
        self.showTimelineView.toggle()
    }
    
}
#endif
