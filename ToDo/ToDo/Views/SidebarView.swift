//
//  SidebarView.swift
//  ToDo
//
//  Created by LQ on 2024/8/10.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    private var tags: [ItemTag] {
        modelData.tagList.sorted { $0.priority > $1.priority }
    }
    
    @Binding var selection: ToDoSection
    
    var body: some View {
        List(selection: $selection) {
            Section("Tasks") {
                ForEach(ToDoSection.allCases) { section in
                    Label(section.displayName, systemImage: section.iconName).tag(section)
                }
            }
            
            Section("Tags") {
                ForEach(tags) { tag in
                    HStack {
                        Image(systemName: "folder")
                        Text(tag.title)
                    }
                    .tag(ToDoSection.list(tag))
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                
            }, label: {
                Label("Add Tags", systemImage: "plus.circle")
            })
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .keyboardShortcut(KeyEquivalent("s"), modifiers: .command)
        }
    }
}
