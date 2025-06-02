//
//  WebView.swift
//  ReadList
//
//  Created by ByteDance on 2023/9/1.
//

#if os(macOS)

//
//  WebView.swift
//  ReadList
//
//  Created by ByteDance on 2023/9/1.
//

import SwiftUI
import WebKit

#if os(iOS)
typealias ViewRepresentable = UIViewRepresentable
typealias PlatformMenu = UIMenu
typealias PlatformMenuItem = UIMenuElement
#elseif os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias PlatformMenu = NSMenu
typealias PlatformMenuItem = NSMenuItem
#endif

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
    var parent: WebView
    
    init(_ parent: WebView) {
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

struct WebView: ViewRepresentable {
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
        
        self.wkWebView = WKWebView(frame: .zero, configuration: config)
    }
}

private var WebViewAssociatedObjectHandle: UInt8 = 0

extension WKWebView {
    var webView: WebView? {
        get {
            return objc_getAssociatedObject(self, &WebViewAssociatedObjectHandle) as? WebView
        }
        set {
            objc_setAssociatedObject(self, &WebViewAssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    #if os(iOS)
    override open func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        evaluateJavaScript("window.getSelection().toString()") { [weak self] result, error in
            if let selectedText = result as? String, !selectedText.isEmpty {
                let addToNoteAction = UIAction(
                    title: "添加到笔记",
                    image: nil
                ) { [weak self] _ in
                    self?.webView?.onSelectedText?(selectedText)
                }
                
                let menu = UIMenu(title: "", options: .displayInline, children: [addToNoteAction])
                builder.insertChild(menu, atStartOfMenu: .lookup)
            }
        }
    }
    #elseif os(macOS)
    @objc func addSelectedTextToNote(_ sender: NSMenuItem) {
        evaluateJavaScript("window.getSelection().toString()") { [weak self] result, error in
            if let selectedText = result as? String, !selectedText.isEmpty {
                DispatchQueue.main.async {
                    self?.webView?.onSelectedText?(selectedText)
                }
            }
        }
    }
    
    open override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        super.willOpenMenu(menu, with: event)
        
        evaluateJavaScript("window.getSelection().toString()") { result, error in
            if let selectedText = result as? String, !selectedText.isEmpty {
                if let addToNoteItem = menu.items.first(where: { $0.title == "添加到笔记" }) {
                    addToNoteItem.isHidden = false
                } else {
                    let newItem = NSMenuItem(
                        title: "添加到笔记",
                        action: #selector(self.addSelectedTextToNote(_:)),
                        keyEquivalent: ""
                    )
                    menu.insertItem(newItem, at: 0)
                }
            } else {
                menu.items.first(where: { $0.title == "添加到笔记" })?.isHidden = true
            }
        }
    }
    #endif
}

extension WebView {
    #if os(iOS)
    func makeUIView(context: Context) -> WKWebView {
        print("WebView - makeUIView")
        wkWebView.navigationDelegate = navigationDelegate
        wkWebView.webView = self
        
        let request = URLRequest(url: url)
        wkWebView.load(request)
        
        return wkWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("WebView - updateUIView")
    }
    #elseif os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        print("WebView - makeNSView")
        wkWebView.navigationDelegate = navigationDelegate
        wkWebView.webView = self
        
        let request = URLRequest(url: url)
        wkWebView.load(request)
        
        return wkWebView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        print("WebView - updateNSView")
    }
    #endif
}


#endif
