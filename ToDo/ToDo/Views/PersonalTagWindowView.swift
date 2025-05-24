//
//  PersonalTagWindowView.swift
//  ToDo
//
//  Created by LQ on 2025/5/24.
//

import SwiftUI


// 自定义弹窗内容
struct PersonalTagWindowView: View {
    @Binding var isPresented: Bool
    @State var itemId: String
    @State var selectPersonalTag: String = ""
    @State var tagType: String = ""
    @State var numType: Int = 1
    
    var nums: [Int] {
        let type = PersonalTagType.type(with: tagType)
        return type.nums
    }
    
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        VStack(spacing: 20) {
            Text("设置关联")
                .font(.system(size: 25)).bold()
            
            Picker("选择品格", selection: $selectPersonalTag) {
                ForEach(modelData.personalTagList.map {$0.tag}, id: \.self) { tag in
                    Text(tag).tag(tag)
                }
            }
            
            Picker("选择类型", selection: $tagType) {
                ForEach(PersonalTagType.titles, id: \.self) { tag in
                    Text(tag).tag(tag)
                }
            }.pickerStyle(.segmented)
            
            Picker("选择数值", selection: $numType) {
                ForEach(nums, id: \.self) { tag in
                    Text("\(tag)").tag(tag)
                }
            }.pickerStyle(.segmented)
            
            HStack(spacing: 40) {
                Button("取消") {
                    isPresented = false
                }
                
                Button("确认") {
                    // 处理确认操作
                    isPresented = false
                    updateTag()
                }
                .keyboardShortcut(.defaultAction) // 设置回车快捷键
            }
        }
        .onChange(of: tagType, { oldValue, newValue in
            if nums.contains(numType) {
                return
            }
            numType = -1 * numType
        })
        .onAppear(perform: {
            selectPersonalTag = modelData.personalTagList.first?.tag ?? ""
            tagType = PersonalTagType.good.title
        })
        .padding()
        .background(Color(.windowBackgroundColor)) // 使用系统窗口背景色
    }
    
    func updateTag() {
        guard let tag = modelData.personalTagList.first(where: { $0.tag == selectPersonalTag
        }) else {
            return
        }
        let type = PersonalTagType.type(with: tagType)
        if type == .good {
            tag.goodEvents[itemId] = numType
        } else {
            tag.badEvents[itemId] = numType
        }
        modelData.updatePersonalTag(tag)
    }
    
}

