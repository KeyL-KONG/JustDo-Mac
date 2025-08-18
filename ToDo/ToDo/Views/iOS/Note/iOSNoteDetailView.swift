//
//  iOSNoteDetailView.swift
//  ToDo
//
//  Created by LQ on 2025/8/18.
//

import SwiftUI

struct iOSNoteDetailView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var item: NoteModel
    @State var isEdit: Bool = false
    @State var tabBarVisible: Bool = false
    @State var content: String = ""
    @StateObject var timer = CommonTimerModel()
    @State var startTime: Date? = nil
    @State var showTimelineView: Bool = false
    private static var selectedTimeItem: TaskTimeItem? = nil
    @State var showEditNoteView = false
    
    var body: some View {
        VStack {
            if isEdit {
                TextEditor(text: $content)
                    .background(Color.init(hex: "117a65").opacity(0.1))
                    .cornerRadius(10)
                    .scrollContentBackground(.hidden)
            } else {
                if item.content.count > 0 {
                    ScrollView {
                        MarkdownWebView(item.content, itemId: item.id)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
            
            HStack {
                
                if timer.isTiming  {
                    Button("记录时间") {
                        self.updateReadTime()
                        timer.stopTimer()
                    }.buttonStyle(ScoreButtonStyle(color: .blue))
                } else {
                    Button("开始复习") {
                        startTime = Date()
                        timer.startTimer(item: item)
                    }.buttonStyle(ScoreButtonStyle(color: .blue))
                }
                
                
                Button("更多") {
                    showEditNoteView.toggle()
                }.buttonStyle(ScoreButtonStyle(color: .green))
                
                
            }.padding(.top)
        }
        .sheet(isPresented: $showTimelineView, content: {
            if let item = Self.selectedTimeItem {
                EditTimeLineRowView(showSheetView: $showTimelineView, item: item)
                    .environmentObject(modelData)
                    .presentationDetents([.height(450)])
            }
        })
        .padding()
        .navigationBarItems(trailing:
            HStack(content: {
                if timer.timeSeconds > 0 {
                    Text(timer.timeSeconds.timeStr)
                }
                Spacer()
                
                let title = isEdit ? "保存" : "编辑"
                Button(title, action: {
                    if isEdit {
                        self.updateNote()
                    }
                    self.isEdit = !self.isEdit
                })
                
            })
        )
        .toolbar((tabBarVisible ? .visible : .hidden), for: .tabBar)
        .onAppear {
            startTime = Date()
            timer.startTimer(item: item)
            tabBarVisible = false
            content = item.content
        }
        .onDisappear {
            tabBarVisible = true
        }
    }
}

extension iOSNoteDetailView {
    
    func updateNote() {
        item.content = content
        modelData.updateNote(item)
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
