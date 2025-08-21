//
//  EditTagview.swift
//  Summary
//
//  Created by LQ on 2024/7/21.
//

import SwiftUI

struct EditTagView: View {
    
    enum FocusedField {
        case title
    }
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showSheetView: Bool
    @State var title: String = ""
    @State private var color = Color.blue
    @FocusState private var focusedField: FocusedField?
    var selectedTag: SummaryTag?
    
    var body: some View {
        NavigationView {
            VStack {
#if os(iOS)
                Text("")
                    .navigationBarTitle(Text("设置标签"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        self.showSheetView = false
                    }, label: {
                        Text("取消").bold()
                    }), trailing: Button(action: {
                        self.saveTag()
                        self.showSheetView = false
                    }, label: {
                        Text("保存").bold()
                    }))
#endif
                List {
                    Section {
                        TextField("标题", text: $title, axis: .vertical)
                            .focused($focusedField, equals: .title)
                            .lineLimit(1)
                        ColorPicker("设置颜色", selection: $color, supportsOpacity: false)
                    }
                }
#if os(iOS)
                .listStyle(.insetGrouped)
                #endif
                    .padding(.top, -40)
            }
        }.onAppear {
            title = selectedTag?.content ?? ""
            color = selectedTag?.titleColor ?? .blue
            focusedField = .title
        }.padding(.zero)
    }
    
    func saveTag() {
        if let selectedTag {
            selectedTag.hexColor = color.toHexString()
            selectedTag.content = title
            modelData.updateSummaryTag(selectedTag)
        } else {
            let tag = SummaryTag()
            tag.generateId = UUID().uuidString
            tag.content = title
            tag.hexColor = color.toHexString()
            modelData.updateSummaryTag(tag)
        }
        
    }
}

#Preview {
    EditTagView(showSheetView: .constant(true))
}
