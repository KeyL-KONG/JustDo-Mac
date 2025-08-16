//
//  WebView.swift
//  ReadList
//
//  Created by ByteDance on 2023/9/1.
//
#if os(iOS)

import SwiftUI
import WebKit

typealias ViewRepresentable = UIViewRepresentable
typealias PlatformMenu = UIMenu
typealias PlatformMenuItem = UIMenuElement

final class WebViewNavigationDelete: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decide policy")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("did start")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("did receive server")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("did fail provisional error: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("did fail error: \(error)")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("did commit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("did finish")
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}

// 首先定义消息处理器类
class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var parent: iOSWebView
    
    init(_ parent: iOSWebView) {
        self.parent = parent
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("WebViewCoordinator - 收到消息: \(message.name)")
        if message.name == "addToNote", let selectedText = message.body as? String {
            print("WebViewCoordinator - 选中文本: \(selectedText)")
            DispatchQueue.main.async {
                self.parent.onSelectedText?(selectedText)
            }
        }
    }
}

struct iOSWebView: ViewRepresentable {
    let url: URL
    var wkWebView: WKWebView
    let navigationDelegate = WebViewNavigationDelete()
    let onSelectedText: ((String) -> Void)?
    
    init(url: URL, onSelectedText: ((String) -> Void)? = nil) {
        self.url = url
        self.onSelectedText = onSelectedText
        
        let config = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences
        
        #if os(iOS)
        let selectionScript = """
        document.addEventListener('selectionchange', function() {
            const selection = window.getSelection();
            const selectedText = selection.toString().trim();
            
            if (selectedText) {
                const range = selection.getRangeAt(0);
                const rect = range.getBoundingClientRect();
                window.webkit.messageHandlers.textSelected.postMessage({
                    text: selectedText,
                    rect: {
                        x: rect.x,
                        y: rect.y,
                        width: rect.width,
                        height: rect.height
                    }
                });
            }
        });
        """
        let script = WKUserScript(source: selectionScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        config.userContentController.add(WebViewMessageHandler(onSelectedText: onSelectedText), name: "textSelected")
        #endif
        
        self.wkWebView = WKWebView(frame: .zero, configuration: config)
    }
}

#if os(iOS)
class CustomWKWebView: WKWebView {
    var onSelectedText: ((String) -> Void)?
    private var currentSelectedText: String = ""
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(addToNote) {
            return true
        }
        // 允许系统默认的复制操作
        if action == #selector(copy(_:)) {
            return true
        }
        // 禁用其他菜单项
        return false
    }
    
    @objc func addToNote() {
        onSelectedText?(currentSelectedText)
        // 清除选择
        evaluateJavaScript("window.getSelection().removeAllRanges();")
    }
    
    func updateSelectedText(_ text: String, rect: CGRect) {
        currentSelectedText = text
        
        // 确保成为第一响应者
        becomeFirstResponder()
        
        // 配置菜单控制器
        let menuController = UIMenuController.shared
        
        // 创建自定义菜单项
        let addToNoteItem = UIMenuItem(title: "添加到笔记", action: #selector(addToNote))
        
        // 设置菜单项
        menuController.menuItems = [addToNoteItem]
        
        // 设置菜单显示位置
        if #available(iOS 13.0, *) {
            menuController.showMenu(from: self, rect: rect)
        } else {
            menuController.setMenuVisible(true, animated: true)
            menuController.setTargetRect(rect, in: self)
        }
    }
    
    // 实现复制功能
    override func copy(_ sender: Any?) {
        evaluateJavaScript("window.getSelection().toString()") { [weak self] result, error in
            if let selectedText = result as? String {
                UIPasteboard.general.string = selectedText
            }
        }
    }
}

class WebViewMessageHandler: NSObject, WKScriptMessageHandler {
    let onSelectedText: ((String) -> Void)?
    
    init(onSelectedText: ((String) -> Void)?) {
        self.onSelectedText = onSelectedText
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "textSelected",
           let dict = message.body as? [String: Any],
           let selectedText = dict["text"] as? String,
           let rectDict = dict["rect"] as? [String: Any] {
            
            DispatchQueue.main.async {
                if let webView = message.webView as? CustomWKWebView {
                    // 从 JavaScript 传递过来的矩形信息构建 CGRect
                    let x = (rectDict["x"] as? CGFloat) ?? 0
                    let y = (rectDict["y"] as? CGFloat) ?? 0
                    let width = (rectDict["width"] as? CGFloat) ?? 0
                    let height = (rectDict["height"] as? CGFloat) ?? 0
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    
                    webView.updateSelectedText(selectedText, rect: rect)
                }
            }
        }
    }
}

extension iOSWebView {
    func makeUIView(context: Context) -> WKWebView {
        print("WebView - makeUIView")
        let customWebView = CustomWKWebView(frame: .zero, configuration: wkWebView.configuration)
        customWebView.navigationDelegate = navigationDelegate
        customWebView.onSelectedText = onSelectedText
        
        let request = URLRequest(url: url)
        customWebView.load(request)
        
        return customWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("WebView - updateUIView")
    }
}
#endif

#endif
