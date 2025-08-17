//
//  iOSReadItemDetailView.swift
//  ToDo
//
//  Created by LQ on 2025/8/16.
//

import SwiftUI

struct iOSReadItemDetailView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var item: ReadModel
    @State var clickCallback: () -> ()
    @State var startTime: Date? = nil
    @State var tabBarVisible: Bool = false
    @State var isLoading: Bool = false
    @State var showMarkText: Bool = false
    @State var mark: String = ""
    @StateObject var timer = CommonTimerModel()
    
    @State var showTimelineView: Bool = false
    private static var selectedTimeItem: TaskTimeItem? = nil
    
    var body: some View {
        VStack {
            if let URL = URL(string: item.url) {
                UniversalWebView(urlString: item.url, isLoading: $isLoading)
//                if item.url.contains("douyin") {
//                    DouyinWebView(url: URL, isLoading: $isLoading)
//                } else {
//                    iOSWebView(url: URL) { note in
//                        if item.note.isEmpty {
//                            item.note = note
//                        } else {
//                            item.note += "\n\n- \(note)"
//                        }
//                        modelData.updateReadModel(item)
//                    }
//                }
            }
            Spacer()
            
            HStack {
                
                if timer.isTiming  {
                    Button("记录阅读") {
                        self.updateReadTime()
                        timer.stopTimer()
                    }.buttonStyle(ScoreButtonStyle(color: .blue))
                } else {
                    Button("开始阅读") {
                        startTime = Date()
                        timer.startTimer(item: item)
                    }.buttonStyle(ScoreButtonStyle(color: .blue))
                }
                
                
                Button("笔记") {
                    self.showMarkText.toggle()
                }.buttonStyle(ScoreButtonStyle(color: .green))
                
                
            }.padding()
        }
        .navigationBarItems(trailing:
            HStack(content: {
                if timer.timeSeconds > 0 {
                    Text(timer.timeSeconds.timeStr)
                }
                
                Spacer()
            
                Button("编辑", action: {
                   clickCallback()
                })
                
                Button("跳转") {
                    if let URL = URL(string: item.url) {
                        UIApplication.shared.open(URL)
                    } else {
                        print("jump error")
                    }
                }
            })
        )
        .toolbar((tabBarVisible ? .visible : .hidden), for: .tabBar)
        .sheet(isPresented: $showTimelineView, content: {
            if let item = Self.selectedTimeItem {
                EditTimeLineRowView(showSheetView: $showTimelineView, item: item)
                    .environmentObject(modelData)
                    .presentationDetents([.height(450)])
            }
        })
        .onAppear {
            startTime = Date()
            tabBarVisible = false
            mark = item.note
            timer.startTimer(item: item)
        }
        .onDisappear {
            tabBarVisible = true
            if item.note != mark {
                item.note = mark
                modelData.updateReadModel(item)
            }
            timer.stopTimer()
        }
        .sheet(isPresented: $showMarkText, onDismiss: {
            if item.note != mark {
                item.note = mark
                modelData.updateReadModel(item)
            }
        }, content: {
            iOSEditTextView(text: $mark)
                .presentationDetents([.height(100)])
                .environmentObject(modelData)
        })

    }
    
    func updateReadTime(content: String = "") {
        guard let startTime else { return }
        let timeInterval = TimeInterval(timer.timeSeconds)
        let endTime = startTime.addingTimeInterval(timeInterval)
        let timeItem = TaskTimeItem(startTime: startTime, endTime: endTime, content: "")
        timeItem.eventId = item.id
        Self.selectedTimeItem = timeItem
        self.showTimelineView.toggle()
    }
    
}
 
