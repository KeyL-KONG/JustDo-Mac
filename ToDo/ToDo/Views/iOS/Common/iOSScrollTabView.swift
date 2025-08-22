//
//  iOSScrollTabView.swift
//  ToDo
//
//  Created by LQ on 2025/8/17.
//

import SwiftUI

struct iOSScrollTabView: View {
    // Tab选项数组
    var tabs: [String]
    
    // 当前选中的tab索引
    @Binding var selection: Int
    
    // 滚动视图的代理，用于处理滚动相关逻辑
    @State private var scrollViewProxy: ScrollViewProxy?
    
    // 每个tab的宽度，用于计算滚动位置
    @State private var tabWidths: [Int: CGFloat] = [:]
    
    // 指示器的水平偏移量
    @State private var indicatorOffset: CGFloat = 0
    
    // 指示器的宽度
    @State private var indicatorWidth: CGFloat = 0
    
    // 指示器宽度相对于tab宽度的比例因子
    private let indicatorWidthFactor: CGFloat = 0.5
    
    init(tabs: [String], selection: Binding<Int>) {
        self.tabs = tabs
        self._selection = selection
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        tabView(for: index)
                            .background(GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        self.tabWidths[index] = geometry.size.width
                                        // 初始化指示器位置和宽度
                                        if index == selection {
                                            self.indicatorWidth = geometry.size.width * indicatorWidthFactor
                                            self.indicatorOffset = calculateIndicatorOffset(for: index) + (geometry.size.width * (1 - indicatorWidthFactor) / 2)
                                        }
                                    }
                                    .onChange(of: geometry.size) { _, newSize in
                                        self.tabWidths[index] = newSize.width
                                        // 更新指示器位置和宽度
                                        if index == selection {
                                            self.indicatorWidth = newSize.width * indicatorWidthFactor
                                            self.indicatorOffset = calculateIndicatorOffset(for: index) + (newSize.width * (1 - indicatorWidthFactor) / 2)
                                        }
                                    }
                            })
                    }
                }
                .overlay(
                    // 添加指示器
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: indicatorWidth, height: 3)
                        .offset(x: indicatorOffset)
                        .animation(.easeInOut, value: indicatorOffset)
                        .animation(.easeInOut, value: indicatorWidth),
                    alignment: .bottomLeading
                )
                .background(Color.clear)
            }
            .onAppear {
                self.scrollViewProxy = proxy
                // 初始时滚动到选中的tab
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo(selection, anchor: .center)
                    }
                }
            }
            .onChange(of: selection) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                    // 更新指示器位置
                    indicatorOffset = calculateIndicatorOffset(for: newValue) + (tabWidths[newValue] ?? 0) * (1 - indicatorWidthFactor) / 2
                    indicatorWidth = (tabWidths[newValue] ?? 0) * indicatorWidthFactor
                }
            }
        }
        .frame(height: 50)
    }
    
    /// 计算指示器的水平偏移量
    /// - Parameter index: tab索引
    /// - Returns: 指示器的水平偏移量
    private func calculateIndicatorOffset(for index: Int) -> CGFloat {
        var offset: CGFloat = 0
        for i in 0..<index {
            offset += tabWidths[i] ?? 0
        }
        return offset
    }
    
    /// 创建单个tab视图
    /// - Parameter index: tab索引
    /// - Returns: tab视图
    private func tabView(for index: Int) -> some View {
        Button(action: {
            withAnimation {
                selection = index
            }
        }) {
            Text(tabs[index])
                .font(selection == index ? .headline : .body) // 选中的tab使用更大的字体
                .fontWeight(selection == index ? .bold : .regular) // 选中的tab加粗
                .foregroundColor(selection == index ? .blue : .gray) // 选中的tab使用蓝色，其他使用灰色
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .id(index)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 新增支持手势的组件
struct iOSScrollTabViewWithGesture<Content: View>: View {
    // Tab选项数组
    var tabs: [String]
    
    // 当前选中的tab索引
    @Binding var selection: Int
    
    // 内容视图构建器
    let content: () -> Content
    
    // 拖拽手势相关状态
    @State private var dragOffset: CGFloat = 0
    
    init(tabs: [String], selection: Binding<Int>, @ViewBuilder content: @escaping () -> Content) {
        self.tabs = tabs
        self._selection = selection
        self.content = content
    }
    
    // 修改iOSScrollTabViewWithGesture的body部分
    var body: some View {
        VStack {
            iOSScrollTabView(tabs: tabs, selection: $selection)
            
            // 使用ZStack包装内容，添加手势识别
            ZStack {
                content()
            }
        }
//        .gesture(
//            DragGesture()
//                .onChanged { value in
//                    dragOffset = value.translation.width
//                }
//                .onEnded { value in
//                    // 计算滑动距离
//                    let threshold: CGFloat = 50 // 最小滑动距离阈值
//                    let dragDistance = value.translation.width
//                    
//                    // 只有当滑动距离超过阈值时才切换tab
//                    if abs(dragDistance) > threshold {
//                        if dragDistance > 0 {
//                            // 向右滑动，切换到上一个tab
//                            selection = max(0, selection - 1)
//                        } else {
//                            // 向左滑动，切换到下一个tab
//                            selection = min(tabs.count - 1, selection + 1)
//                        }
//                    }
//                    
//                    // 重置拖拽偏移
//                    dragOffset = 0
//                }
//        )
    }
}

struct ScrollContentView: View {
    @State private var selection: Int = 0
    let tabs = ["待办事项", "待计划事项", "复盘事项", "笔记", "标签"]
    
    var body: some View {
        iOSScrollTabViewWithGesture(tabs: tabs, selection: $selection) {
            List {
                // 根据selection显示不同的内容
                switch selection {
                case 0:
                    Text("待办事项内容")
                case 1:
                    Text("待计划事项内容")
                case 2:
                    Text("复盘事项内容")
                case 3:
                    Text("笔记内容")
                case 4:
                    Text("标签内容")
                default:
                    Text("默认内容")
                }
            }
        }
    }
}

// 预览代码
struct iOSScrollTabView_Previews: PreviewProvider {
    @State static var selection: Int = 0
    
    static var previews: some View {
        ScrollContentView()
        .previewLayout(.sizeThatFits)
    }
}

