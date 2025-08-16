//
//  iOSTagView.swift
//  ToDo
//
//  Created by LQ on 2025/8/17.
//

import SwiftUI

/// 支持多选的标签列表视图
public struct MultiSelectTagListView: View {
    /// 所有可用的标签数据
    public let tags: [String]
    
    /// 当前已选中的标签数组
    @Binding public var selectedTags: [String]
    
    /// 标签选择状态变化时的回调
    public var selectionChanged: (([String]) -> Void)?
    
    /// 是否显示添加按钮
    public let showAddButton: Bool
    
    /// 添加标签时的回调
    public var addTagAction: (() -> Void)?
    
    /// 标签文本颜色
    public let textColor: Color
    
    /// 未选中标签的背景颜色
    public let unselectedBackgroundColor: Color
    
    /// 选中标签的背景颜色
    public let selectedBackgroundColor: Color
    
    /// 标签边框颜色
    public let borderColor: Color
    
    /// 标签边框宽度
    public let borderWidth: CGFloat
    
    /// 标签圆角
    public let cornerRadius: CGFloat
    
    /// 标签垂直间距
    public let verticalSpacing: CGFloat
    
    /// 标签水平间距
    public let horizontalSpacing: CGFloat
    
    /// 标签内边距
    public let padding: EdgeInsets
    
    /// 初始化多选标签列表视图
    /// - Parameters:
    ///   - tags: 所有可用的标签数据
    ///   - selectedTags: 当前已选中的标签数组绑定
    ///   - selectionChanged: 标签选择状态变化时的回调
    ///   - showAddButton: 是否显示添加按钮
    ///   - addTagAction: 添加标签时的回调
    ///   - textColor: 标签文本颜色
    ///   - unselectedBackgroundColor: 未选中标签的背景颜色
    ///   - selectedBackgroundColor: 选中标签的背景颜色
    ///   - borderColor: 标签边框颜色
    ///   - borderWidth: 标签边框宽度
    ///   - cornerRadius: 标签圆角
    ///   - verticalSpacing: 标签垂直间距
    ///   - horizontalSpacing: 标签水平间距
    ///   - padding: 标签内边距
    public init(
        tags: [String],
        selectedTags: Binding<[String]>,
        selectionChanged: (([String]) -> Void)? = nil,
        showAddButton: Bool = false,
        addTagAction: (() -> Void)? = nil,
        textColor: Color = .black,
        unselectedBackgroundColor: Color = .white,
        selectedBackgroundColor: Color = .blue,
        borderColor: Color = .gray,
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 7.5,
        verticalSpacing: CGFloat = 3,
        horizontalSpacing: CGFloat = 3,
        padding: EdgeInsets = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    ) {
        self.tags = tags
        self._selectedTags = selectedTags
        self.selectionChanged = selectionChanged
        self.showAddButton = showAddButton
        self.addTagAction = addTagAction
        self.textColor = textColor
        self.unselectedBackgroundColor = unselectedBackgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.padding = padding
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TagCloudView(
                data: tags,
                verticalSpacing: verticalSpacing,
                horizontalSpacing: horizontalSpacing
            ) {
                MultiSelectTag(
                    title: $0,
                    isSelected: selectedTags.contains($0),
                    textColor: textColor,
                    unselectedBackgroundColor: unselectedBackgroundColor,
                    selectedBackgroundColor: selectedBackgroundColor,
                    borderColor: borderColor,
                    borderWidth: borderWidth,
                    cornerRadius: cornerRadius,
                    padding: padding
                ) {
                    toggleTagSelection($0)
                }
            }
            
            if showAddButton {
                Button(action: {
                    addTagAction?()
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                        Text("添加标签")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
    }
    
    /// 切换标签的选中状态
    /// - Parameter tag: 要切换的标签
    private func toggleTagSelection(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
        selectionChanged?(selectedTags)
    }
}

/// 支持多选的单个标签视图
struct MultiSelectTag: View {
    /// 标签标题
    let title: String
    
    /// 是否被选中
    let isSelected: Bool
    
    /// 标签文本颜色
    let textColor: Color
    
    /// 未选中标签的背景颜色
    let unselectedBackgroundColor: Color
    
    /// 选中标签的背景颜色
    let selectedBackgroundColor: Color
    
    /// 标签边框颜色
    let borderColor: Color
    
    /// 标签边框宽度
    let borderWidth: CGFloat
    
    /// 标签圆角
    let cornerRadius: CGFloat
    
    /// 标签内边距
    let padding: EdgeInsets
    
    /// 标签点击时的回调
    let onTap: (String) -> Void
    
    var body: some View {
        Button(action: {
            onTap(title)
        }) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : textColor)
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(isSelected ? selectedBackgroundColor : unselectedBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .buttonStyle(.borderless)
    }
}

// MARK: - 预览
struct MultiSelectTagListView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedTags = ["工作", "重要"]
        let allTags = ["工作事项", "学习", "生活", "健康", "重要", "紧急", "待办", "完成"]
        
        MultiSelectTagListView(
            tags: allTags,
            selectedTags: $selectedTags,
            showAddButton: true
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

