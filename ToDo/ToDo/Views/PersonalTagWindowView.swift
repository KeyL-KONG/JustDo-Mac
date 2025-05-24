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
    @State var personalTag: PersonalTag?
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
                
                if let personalTag {
                    Button {
                        personalTag.goodEvents.removeValue(forKey: itemId)
                        personalTag.badEvents.removeValue(forKey: itemId)
                        modelData.updatePersonalTag(personalTag)
                        isPresented = false
                    } label: {
                        Text("删除").foregroundStyle(.red)
                    }
                }
                
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
            if let personalTag {
                selectPersonalTag = personalTag.tag
                if let num = personalTag.goodEvents[itemId] {
                    self.numType = num
                    self.tagType = PersonalTagType.good.title
                } else if let num = personalTag.badEvents[itemId] {
                    self.numType = num
                    self.tagType = PersonalTagType.bad.title
                }
            } else {
                selectPersonalTag = modelData.personalTagList.first?.tag ?? ""
                tagType = PersonalTagType.good.title
            }
        })
        .padding()
        .background(Color(.windowBackgroundColor)) // 使用系统窗口背景色
    }
    
    func updateTag() {
        guard let tag = personalTag ?? modelData.personalTagList.first(where: { $0.tag == selectPersonalTag
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

