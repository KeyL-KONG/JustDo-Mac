//
//  iOSReadItemDetailView.swift
//  ToDo
//
//  Created by LQ on 2025/8/16.
//

import SwiftUI

struct iOSReadItemDetailView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var item: ReadModel?
    @State var clickCallback: () -> ()
    @State var startTime: Date? = nil
    @State var tabBarVisible: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            if let item, let URL = URL(string: item.url) {
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
            
            HStack(alignment: .center) {
                Button("标记已读") {
                    self.updateReadTime()
                }
            }
        }
        .navigationBarItems(trailing:
            HStack(content: {
                Button("编辑", action: {
                   clickCallback()
                })
                Spacer()
                Button("跳转") {
                    if let item, let URL = URL(string: item.url) {
                        UIApplication.shared.open(URL)
                    } else {
                        print("jump error")
                    }
                }
            })
        )
        .toolbar((tabBarVisible ? .visible : .hidden), for: .tabBar)
        .onAppear {
            startTime = Date()
            tabBarVisible = false
        }
        .onDisappear {
            tabBarVisible = true
        }
        
        
    }
    
    func updateReadTime() {
        guard let item, let startTime else { return }
        let interval = LQDateInterval(start: startTime, end: Date())
        item.intervals.append(interval)
        modelData.updateReadModel(item)
    }
    
}
 
