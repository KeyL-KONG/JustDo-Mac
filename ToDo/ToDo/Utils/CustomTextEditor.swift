//
//  CustomTextEditor.swift
//  ToDo
//
//  Created by ByteDance on 2025/6/4.
//
#if os(macOS)
import SwiftUI

import AppKit

struct CustomTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var cursorPosition: Int {
        didSet {
            print("custom cursor pos: \(cursorPosition) \(self)")
            self.onCursorPositionChanged?(cursorPosition)
        }
    }
    var onCursorPositionChanged: ((Int) -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textView.backgroundColor = .clear
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        
        scrollView.borderType = .bezelBorder
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // 只有当文本确实改变时才更新，避免光标跳动
        if textView.string != text {
            textView.string = text
        }
        
        // 设置光标位置 - 使用 NSRange
        let currentRange = textView.selectedRange()
        if currentRange.location != cursorPosition {
            //textView.setSelectedRange(NSRange(location: cursorPosition, length: 0))
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor
        
        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            let selectedRange = textView.selectedRange()
            print("select range len: \(selectedRange.location), parent: \(parent), cursor: \(parent.cursorPosition)")
            //parent.cursorPosition = selectedRange.location
            
            // 如果有回调，执行回调
            //parent.onCursorPositionChanged?(selectedRange.location)
        }
    }
}
#endif
