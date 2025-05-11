//
//  PlanView.swift
//  ToDo
//
//  Created by LQ on 2025/5/12.
//

import SwiftUI

struct PlanView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State var mostImportranceItems: [EventItem] = []
    
    var body: some View {
        VStack(spacing: 0) {
            mostImportanceHeaderView()
            mostImportanceView()
            Spacer()
        }
        .onAppear {
            updateMostImportanceItems()
        }
    }
}


extension PlanView {
    
    func mostImportanceHeaderView() -> some View {
        HStack {
            Text("关键事项").bold().font(.system(size: 16))
                .foregroundStyle(Color.init(hex: "e74c3c"))
            Spacer()
        }.padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func mostImportanceView() -> some View {
        VStack(alignment: .leading) {
            ForEach(mostImportranceItems, id: \.self) { item in
                mostImportanceItemView(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background {
            ZStack {
                Rectangle()
                    .fill(Color.init(hex: "fadbd8").opacity(0.6))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
    }
    
    func mostImportanceItemView(item: EventItem) -> some View {
        HStack(alignment: .center) {
            Label("", systemImage: (item.isFinish ? "checkmark.square.fill" : "square"))
            
            Text(item.title)
            Spacer()
            
            if let tag = modelData.tagList.first(where: {  $0.id == item.tag }) {
                tagView(title: tag.title, color: tag.titleColor)
            }
        }
    }
    
    func updateMostImportanceItems() {
        mostImportranceItems = Array(modelData.itemList.filter({ $0.importance == .high && $0.actionType == .task
        }).sorted(by: {
            ($0.createTime?.timeIntervalSince1970 ?? 0) >= ($1.createTime?.timeIntervalSince1970 ?? 0)
        }).prefix(3))
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 8))
            .padding(EdgeInsets.init(top: 2, leading: 2, bottom: 2, trailing: 2))
            .background(color)
            .clipShape(Capsule())
    }
    
}

