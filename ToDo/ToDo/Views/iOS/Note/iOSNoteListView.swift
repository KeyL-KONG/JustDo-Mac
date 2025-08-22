//
//  iOSNoteListView.swift
//  ToDo
//
//  Created by LQ on 2025/8/17.
//
#if os(iOS)

import SwiftUI

struct iOSNoteListView: View {
    @EnvironmentObject var modelData: ModelData
    @State var selection: TimeTab = .week
    var timeTabs: [TimeTab] = [.week, .month, .all]
    
    @State var noteItemList: [NoteModel] = []
    
    var body: some View {
        ZStack {
            itemListView()
        }
        .onChange(of: modelData.updateDataIndex, { oldValue, newValue in
            self.updateNoteItems()
        })
        .onChange(of: modelData.updateNoteIndex, { oldValue, newValue in
            self.updateNoteItems()
        })
        .onAppear {
            self.updateNoteItems()
        }
    }
}

extension iOSNoteListView {
    
    func updateNoteItems() {
        noteItemList = modelData.noteList.sorted(by: { ($0.updateAt?.timeIntervalSince1970 ?? 0) > ($1.updateAt?.timeIntervalSince1970 ?? 0)
        })
    }
}

extension iOSNoteListView {
    
    func itemListView() -> some View {
        List {
            ForEach(noteItemList, id: \.self.id) { note in
                NavigationLink {
                    iOSNoteDetailView(item: note)
                        .environmentObject(modelData)
                } label: {
                    noteItemView(note: note)
                }
            }
        }
    }
    
    func noteItemView(note: NoteModel) -> some View {
        VStack(alignment: .leading) {
            Text(note.title).lineLimit(1).truncationMode(.tail)
        }
    }
    
}

#endif
