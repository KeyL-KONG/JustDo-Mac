//
//  PersonalTagView.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import SwiftUI

struct PersonalTagView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @Binding var selectItemID: String
    @State var personalTagList: [PersonalTag] = []
    
    var body: some View {
        VStack {
            ForEach(personalTagList, id: \.self.id) { tag in
                tagView(tag: tag).tag(tag.id)
            }
            Spacer()
        }
        .padding()
        .onReceive(modelData.$personalTagList, perform: { _ in
            updateTagList()
        })
        .onAppear {
            updateTagList()
            if let firstTag = personalTagList.first {
                selectItemID = firstTag.id
            }
        }
        .toolbar {
            Button {
                addNewTag()
            } label: {
                Label("Add New Tag", systemImage: "plus")
            }
        }
    }
    
    func addNewTag() {
        let tag = PersonalTag()
        tag.tag = "新建品格"
        modelData.updatePersonalTag(tag)
    }
    
    func tagView(tag: PersonalTag) -> some View {
        HStack {
            Text(tag.tag)
            Spacer()
        }.contentShape(Rectangle())
        .onTapGesture {
            self.selectItemID = tag.id
        }
        .padding(5)
        .background {
            if tag.id == selectItemID {
                ZStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0.5))
                        .cornerRadius(5)
                }
            }
        }
    }
    
    func updateTagList() {
        self.personalTagList = modelData.personalTagList
    }
}
