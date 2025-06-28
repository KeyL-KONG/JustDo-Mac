//
//  PersonalEditTagView.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import SwiftUI
#if os(macOS)
struct PersonalEditTagView: View {
    
    @FocusState var focusedField: FocusedField?
    enum FocusedField {
        case title
    }
    
    @State private var goodColor = Color.blue
    @State private var badColor = Color.red
    @State var tag: PersonalTag
    @State var tagTitle: String = ""
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        VStack {
            List {
                Section {
                    TextField("品格", text: $tagTitle)
                        .focused($focusedField, equals: .title)
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 1)
                        }
                    ColorPicker("设置正向颜色", selection: $goodColor, supportsOpacity: false)
                    ColorPicker("设置负向颜色", selection: $badColor, supportsOpacity: false)
                }
            }
            Spacer()
        }
        .onAppear {
            self.tagTitle = tag.tag
            self.focusedField = .title
            self.goodColor = tag.goodColor
            self.badColor = tag.badColor
        }
        .toolbar(content: {
            Spacer()
            Button("保存") {
                saveTag()
            }.foregroundColor(.blue)
        })
    }
    
    
    func saveTag() {
        tag.tag = tagTitle
        tag.goodColorHex = goodColor.toHexString()
        tag.badColorHex = badColor.toHexString()
        modelData.updatePersonalTag(tag)
    }
}
#endif
