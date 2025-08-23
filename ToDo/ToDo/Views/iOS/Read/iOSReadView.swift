//
//  iOSReadView.swift
//  ToDo
//
//  Created by LQ on 2025/8/18.
//
#if os(iOS)
import SwiftUI

struct iOSReadView: View {
    @EnvironmentObject var modelData: ModelData
    
    @State private var showingSheet = false
    static var selectedReadItem: ReadModel?
    static var pastedURL: String = ""
    
    @State private var selectionIndex = 0
    @State var showErrorAlert: Bool = false
    let tabs = ["整理", "列表"]
    
    var body: some View {
        ZStack {
            iOSScrollTabViewWithGesture(tabs: tabs, selection: $selectionIndex) {
                if selectionIndex == 0 {
                    iOSReadReviewView(showErrorAlert: $showErrorAlert)
                        .environmentObject(modelData)
                } else {
                    iOSReadTimeView(showErrorAlert: $showErrorAlert)
                        .environmentObject(modelData)
                }
            }
        }
        .onAppear(perform: {
            checkPasteContent()
        })
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                Self.selectedReadItem = nil
                showingSheet.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            })
            .padding(15)
            .offset(y: -50)
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            checkPasteContent()
        }
        .sheet(isPresented: $showingSheet) {
            if let selectedReadItem = Self.selectedReadItem {
                iOSReadEditView(readItem: selectedReadItem, showSheetView: $showingSheet, showErrorAlert: $showErrorAlert)
                    .environmentObject(modelData)
            } else {
                iOSReadEditView(showSheetView: $showingSheet, urlText: Self.pastedURL, showErrorAlert: $showErrorAlert)
                    .environmentObject(modelData)
            }
        }
        .alert("服务器错误", isPresented: $showErrorAlert) {
            Button("取消") {
                showErrorAlert = false
            }
            Button("重试") {
                if let retryItem = modelData.updateErrorReadItem {
                    modelData.updateReadModel(retryItem)
                }
            }
        } message: {
            Text("保存数据时发生错误，请稍后重试")
        }
    }
}

extension iOSReadView {
    
    private func checkPasteContent() {
        guard let content = UIPasteboard.general.string, let url = content.extractURL else { return }
        print("paste content: \(url)")
        UIPasteboard.general.string = nil
        Self.pastedURL = url
        Self.selectedReadItem = nil
        showingSheet.toggle()
    }
    
}

#endif
