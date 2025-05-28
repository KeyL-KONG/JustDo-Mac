//
//  NoteListView.swift
//  ToDo
//
//  Created by LQ on 2025/5/28.
//

import SwiftUI

struct NoteListView: View {
    
    @Binding var selectItemID: String
    @EnvironmentObject var modelData: ModelData
    
    @State var noteList: [NoteModel] = []
    
    var body: some View {
        VStack {
            List(selection: $selectItemID) {
                ForEach(noteList, id: \.self.id) { note in
                    noteItemView(note).id(note.id)
                        .contextMenu {
                            Button {
                                modelData.deleteNote(note)
                            } label: {
                                Text("删除").foregroundStyle(.red)
                            }
                        }
                }
            }
        }
        .padding()
        .onReceive(modelData.$noteList, perform: { _ in
            updateNotes()
        })
        .onAppear {
            updateNotes()
        }
    }
    
    
    func noteItemView(_ item: NoteModel) -> some View {
        HStack {
            Text(item.title)
            Spacer()
            if let updateTime = item.updateAt {
                Text(updateTime.simpleDateStr).foregroundStyle(.gray)
            }
        }
    }
    
    func updateNotes() {
        self.noteList = modelData.noteList.sorted(by: {
            ($0.updateAt?.timeIntervalSince1970 ?? 0) > ($1.updateAt?.timeIntervalSince1970 ?? 0)
        })
    }
    
}
