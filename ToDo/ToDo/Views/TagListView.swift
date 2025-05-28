//
//  TagListView.swift
//  Note
//
//  Created by ByteDance on 2023/8/24.
//

import SwiftUI

struct RemovableTagListView: View {
    
    @State public var showCloseButton: Bool
    @State public var tags: [String] = []
    @State public var addTagEvent: ((String)->())? = nil
    @State public var removeTagEvent: ((String)->())? = nil
    @State public var selectTagEvent: (([String])->())? = nil
    @EnvironmentObject public var modelData: ModelData
    
    @State private var presentAlert = false
    @State private var presentSelectAlert = false
    @State private var newTag: String = ""
    @FocusState private var focusedField: FocusedField?
    @State private var selectTag: String = ""
    
    var defaultTags: [String] {
        modelData.noteTagList.compactMap { $0.content }.filter { tag in
            return !tags.contains { $0 == tag }
        }
    }
    
    enum FocusedField {
        case editTag
    }
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(tags, id: \.self) { tag in
                HStack {
                    Text(tag)
                        .foregroundColor(.white)
                        
                    if showCloseButton {
                        Button(action: {
                            removeTag(tag)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue)
                .cornerRadius(20)
            }
            if showCloseButton {
                Button {
                    focusedField = .editTag
                    if modelData.tagList.isEmpty {
                        presentAlert = true
                    } else {
                        presentSelectAlert = true
                    }
                    
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
                .alert("添加标签", isPresented: $presentAlert) {
                    TextField("标签内容", text: $newTag)
                        .focused($focusedField, equals: .editTag)
                    Button("确认") {
                        addTag(newTag)
                    }
                    Button("取消") {
                        
                    }
                }
                .sheet(isPresented: $presentSelectAlert) {
                    SelectTagView(tags: defaultTags, selectedTag: $selectTag, cancelEvent: {
                        presentSelectAlert = false
                    }, confirmEvent: { selectedTags in
                        presentSelectAlert = false
                        tags += selectedTags
                        selectTagEvent?(selectedTags)
                    }, newTagEvent: {
                        presentSelectAlert = false
                        presentAlert = true
                    }).frame(width: 300)
                }
            }
        }
        .padding()
        .onAppear {
            selectTag = defaultTags.first ?? ""
        }
    }
    
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        self.removeTagEvent?(tag)
    }
    
    func addTag(_ tag: String) {
        tags.append(tag)
        self.addTagEvent?(tag)
    }
}

struct SelectTagView: View {
    var tags: [String]
    @Binding var selectedTag: String
    @State var selectedTags: [String] = []
    var cancelEvent: (()->())
    var confirmEvent: (([String])->())
    var newTagEvent: (()->())
    let createTag: String = "新建"
    private var showTags: [String] {
        var showTags: [String] = []
        showTags += tags
        showTags.append(createTag)
        return showTags
    }

    var body: some View {
        VStack {
            
            TagCloudView(data: showTags) { tag in
                if tag == createTag {
                    Button {
                        newTagEvent()
                    } label: {
                        Text("+")
                          .foregroundColor(.black)
                          .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                          .background(
                            RoundedRectangle(cornerRadius: 10)
                              .foregroundColor(.white)
                          )
                          .overlay(
                            RoundedRectangle(cornerRadius: 10)
                              .stroke(.black, lineWidth: 1)
                          )
                    }
                    .buttonStyle(.borderless)
                } else {
                    SelectableTag(title: tag) { selected in
                        if selected {
                            self.selectedTags.append(tag)
                        } else {
                            self.selectedTags.removeAll { $0 == tag }
                        }
                    }
                }
            }
                
            Spacer()
            
            HStack {
                Button("取消") {
                    cancelEvent()
                }
                
                Spacer()

                Button("确认") {
                    confirmEvent(selectedTags)
                }
            }
        }.padding()
    }
}

struct SelectableTag: View {
  @State var isSelected = false
  let title: String
    var selectedChange:((Bool)->())
  
  var body: some View {
    Button {
      isSelected.toggle()
        selectedChange(isSelected)
    } label: {
      Text(title)
        .foregroundColor(isSelected ? .white : .black)
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(
          RoundedRectangle(cornerRadius: 10)
            .foregroundColor(isSelected ? .black : .white)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(isSelected ? .white : .black, lineWidth: 1)
        )
    }
    .buttonStyle(.borderless)
  }
}

struct TagListViewPreview: PreviewProvider {
    static var previews: some View {
        RemovableTagListView(showCloseButton: true)
    }
}
