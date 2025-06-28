//
//  NoteListView.swift
//  ToDo
//
//  Created by LQ on 2025/5/28.
//

import SwiftUI
#if os(macOS)
struct NoteListView: View {
    
    @Binding var selectItemID: String
    @EnvironmentObject var modelData: ModelData
    
    @State var noteList: [NoteModel] = []
    
    var body: some View {
        //ScrollViewReader { proxy in
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
            //}
//            .onAppear(perform: {
//                updateNotes()
//                if selectItemID.count > 0 {
//                    DispatchQueue.main.async {
//                        proxy.scrollTo(selectItemID, anchor: .center)
//                    }
//                }
            //})
            .padding()
        }
        .onChange(of: modelData.updateNoteIndex, { oldValue, newValue in
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
            if item.tags.count > 0 {
                ForEach(item.tags, id: \.self) { tagId in
                    if let noteTag = modelData.noteTagList.first(where: {
                        $0.id == tagId
                    }) {
                        tagView(title: noteTag.content, color: .blue)
                    }
                }
            }
            
            if item.rate > 0 {
                RatingView(maxRating: 5, rating: .constant(Double(item.rate)), size: 10, spacing: 2, enable: false)
            }
            
            if let updateTime = item.updateAt {
                Text(updateTime.simpleDateStr).foregroundStyle(.gray).frame(width: 80)
            }
        }
        .padding(.vertical, 5)
    }
    
    func updateNotes() {
        self.noteList = modelData.noteList.sorted(by: {
            ($0.updateAt?.timeIntervalSince1970 ?? 0) > ($1.updateAt?.timeIntervalSince1970 ?? 0)
        })
        if !self.noteList.contains(where: { $0.id == selectItemID }) {
            selectItemID = self.noteList.first?.id ?? ""
        }
    }
    
    func tagView(title: String, color: Color) -> some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 11))
            .padding(EdgeInsets.init(top: 2, leading: 4, bottom: 2, trailing: 4))
            .background(color)
            .clipShape(Capsule())
    }
    
}
#endif
