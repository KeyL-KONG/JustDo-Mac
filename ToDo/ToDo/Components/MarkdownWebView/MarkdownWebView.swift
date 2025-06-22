import SwiftUI
import WebKit
import Foundation

#if os(macOS)
typealias PlatformViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias PlatformViewRepresentable = UIViewRepresentable
#endif

@available(macOS 11.0, iOS 14.0, *)
public struct MarkdownWebView: PlatformViewRepresentable {
    let markdownContent: String
    let itemId: String
    var scrollText: String
    let customStylesheet: String?
    let linkActivationHandler: ((URL) -> Void)?
    let renderedContentHandler: ((String) -> Void)?
    
    public init(_ markdownContent: String, itemId: String = "", scrollText: String = "", customStylesheet: String? = nil) {
        self.markdownContent = markdownContent
        self.itemId = itemId
        self.scrollText = scrollText
        self.customStylesheet = customStylesheet
        self.linkActivationHandler = nil
        self.renderedContentHandler = nil
    }
    
    internal init(_ markdownContent: String, itemId: String = "", scrollText: String = "", customStylesheet: String?, linkActivationHandler: ((URL) -> Void)?, renderedContentHandler: ((String) -> Void)?) {
        self.markdownContent = markdownContent
        self.customStylesheet = customStylesheet
        self.itemId = itemId
        self.scrollText = scrollText
        self.linkActivationHandler = linkActivationHandler
        self.renderedContentHandler = renderedContentHandler
    }
    
    public func makeCoordinator() -> Coordinator { .init(parent: self) }
    
    #if os(macOS)
    public func makeNSView(context: Context) -> CustomWebView { context.coordinator.platformView }
    #elseif os(iOS)
    public func makeUIView(context: Context) -> CustomWebView { context.coordinator.platformView }
    #endif
    
    func updatePlatformView(_ platformView: CustomWebView, context: Context) {
        platformView.itemId = itemId
        guard !platformView.isLoading else { return } /// This function might be called when the page is still loading, at which time `window.proxy` is not available yet.
        platformView.updateMarkdownContent(self.markdownContent)
//        if scrollText.isEmpty {
//            platformView.scrollTo(text: scrollText)
//        }
    }
    
    #if os(macOS)
    public func updateNSView(_ nsView: CustomWebView, context: Context) { self.updatePlatformView(nsView, context: context) }
    #elseif os(iOS)
    public func updateUIView(_ uiView: CustomWebView, context: Context) { self.updatePlatformView(uiView, context: context) }
    #endif
    
    public func onLinkActivation(_ linkActivationHandler: @escaping (URL) -> Void) -> Self {
        .init(self.markdownContent, itemId: itemId, customStylesheet: self.customStylesheet, linkActivationHandler: linkActivationHandler, renderedContentHandler: self.renderedContentHandler)
    }
    
    public func onRendered(_ renderedContentHandler: @escaping (String) -> Void) -> Self {
        .init(self.markdownContent, itemId: itemId, customStylesheet: self.customStylesheet, linkActivationHandler: self.linkActivationHandler, renderedContentHandler: renderedContentHandler)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: MarkdownWebView
        let platformView: CustomWebView
        
        init(parent: MarkdownWebView) {
            self.parent = parent
            self.platformView = .init()
            super.init()
            
            self.platformView.navigationDelegate = self
            
//            #if DEBUG && os(iOS)
//            if #available(iOS 16.4, *) {
//                self.platformView.isInspectable = true
//            }
//            #endif
            
            /// So that the `View` adjusts its height automatically.
            self.platformView.setContentHuggingPriority(.required, for: .vertical)
            
            /// Disables scrolling.
            #if os(iOS)
            self.platformView.scrollView.isScrollEnabled = false
            #endif
            
            /// Set transparent background.
            #if os(macOS)
            self.platformView.setValue(false, forKey: "drawsBackground")
            /// Equavalent to `.setValue(true, forKey: "drawsTransparentBackground")` on macOS 10.12 and before, which this library doesn't target.
            #elseif os(iOS)
            self.platformView.isOpaque = false
            #endif
            
            /// Receive messages from the web view.
            self.platformView.configuration.userContentController = .init()
            self.platformView.configuration.userContentController.add(self, name: "sizeChangeHandler")
            self.platformView.configuration.userContentController.add(self, name: "renderedContentHandler")
            
            #if os(macOS)
            let defaultStylesheetFileName = "default-macOS"
            #elseif os(iOS)
            let defaultStylesheetFileName = "default-iOS"
            #endif
            guard let templateFileURL = Bundle.main.url(forResource: "template", withExtension: ""),
                  let templateString = try? String(contentsOf: templateFileURL),
                  let scriptFileURL = Bundle.main.url(forResource: "script", withExtension: ""),
                  let script = try? String(contentsOf: scriptFileURL),
                  let defaultStylesheetFileURL = Bundle.main.url(forResource: defaultStylesheetFileName, withExtension: ""),
                  let defaultStylesheet = try? String(contentsOf: defaultStylesheetFileURL)
            else { return }
            let htmlString = templateString
                .replacingOccurrences(of: "PLACEHOLDER_SCRIPT", with: script)
                .replacingOccurrences(of: "PLACEHOLDER_STYLESHEET", with: self.parent.customStylesheet ?? defaultStylesheet)
            self.platformView.loadHTMLString(htmlString, baseURL: nil)
        }
        
        /// Update the content on first finishing loading.
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // TODO 添加标签逻辑
//            (webView as! CustomWebView).callAsyncJavaScript("""
//                                     const style = document.createElement('style');
//                                             style.textContent = `
//                                                 .highlight-tag {
//                                                     position: relative;
//                                                     background: yellow;
//                                                     cursor: pointer;
//                                                 }
//                                                 .highlight-tag::after {
//                                                     content: '🔖';
//                                                     position: absolute;
//                                                     bottom: 100%;
//                                                     left: 50%;
//                                                     transform: translateX(-50%);
//                                                     font-size: 12px;
//                                                 }
//                                             `;
//                                             document.head.append(style);
//                                     """, in: nil, in: .page, completionHandler: nil)
            (webView as! CustomWebView).updateMarkdownContent(self.parent.markdownContent)

        }
        
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if navigationAction.navigationType == .linkActivated {
                guard let url = navigationAction.request.url else { return .cancel }
                
                if let linkActivationHandler = self.parent.linkActivationHandler {
                    linkActivationHandler(url)
                } else {
                    #if os(macOS)
                    NSWorkspace.shared.open(url)
                    #elseif os(iOS)
                    DispatchQueue.main.async {
                        Task { await UIApplication.shared.open(url) }
                    }
                    #endif
                }
                
                return .cancel
            } else {
                return .allow
            }
        }
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "sizeChangeHandler":
                guard let contentHeight = message.body as? CGFloat,
                      self.platformView.contentHeight != contentHeight
                else { return }
                self.platformView.contentHeight = contentHeight
                self.platformView.invalidateIntrinsicContentSize()
            case "renderedContentHandler":
                guard let renderedContentHandler = self.parent.renderedContentHandler,
                      let renderedContentBase64Encoded = message.body as? String,
                      let renderedContentBase64EncodedData: Data = .init(base64Encoded: renderedContentBase64Encoded),
                      let renderedContent = String(data: renderedContentBase64EncodedData, encoding: .utf8)
                else { return }
                renderedContentHandler(renderedContent)
            default:
                return
            }
        }
    }
    
    public class CustomWebView: WKWebView {
        var contentHeight: CGFloat = 0
        var itemId: String? = nil
        
        public override var intrinsicContentSize: CGSize {
            .init(width: super.intrinsicContentSize.width, height: self.contentHeight)
        }
        
        /// Disables scrolling.
        #if os(macOS)
        public override func scrollWheel(with event: NSEvent) {
            if event.deltaY == 0 {
                super.scrollWheel(with: event)
            } else {
                self.nextResponder?.scrollWheel(with: event)
            }
        }
        #endif
        
        /// Removes "Reload" from the context menu.
        #if os(macOS)
        public override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
            menu.items.removeAll { $0.identifier == .init("WKMenuItemIdentifierReload") }
            
            evaluateJavaScript("window.getSelection().toString()") { result, error in
                if let selectedText = result as? String, !selectedText.isEmpty {
                    // task
                    if let addToNoteItem = menu.items.first(where: { $0.title == CommonDefine.addNewTask }) {
                        addToNoteItem.isHidden = false
                    } else {
                        let newItem = NSMenuItem(
                            title: CommonDefine.addNewTask,
                            action: #selector(self.addSelectedTextToNote(_:)),
                            keyEquivalent: ""
                        )
                        menu.insertItem(newItem, at: 0)
                    }
                    
                    // think
                    if let addToThinkItem = menu.items.first(where: { $0.title == CommonDefine.addNewThink }) {
                        addToThinkItem.isHidden = false
                    } else {
                        let newItem = NSMenuItem(
                            title: CommonDefine.addNewThink,
                            action: #selector(self.addSelectedTextToThink(_:)),
                            keyEquivalent: ""
                        )
                        menu.insertItem(newItem, at: 0)
                    }
                    
                    // highligh
                    if let addToHighlighItem = menu.items.first(where: { $0.title == CommonDefine.highlightText }) {
                        addToHighlighItem.isHidden = false
                    } else {
                        let newItem = NSMenuItem(
                            title: CommonDefine.highlightText,
                            action: #selector(self.addSelectedTextToHighligh(_:)),
                            keyEquivalent: ""
                        )
                        menu.insertItem(newItem, at: 0)
                    }
                } else {
                    menu.items.first(where: { $0.title == CommonDefine.addNewTask })?.isHidden = true
                    menu.items.first(where: { $0.title == CommonDefine.addNewThink })?.isHidden = true
                    menu.items.first(where: { $0.title == CommonDefine.highlightText })?.isHidden = true
                }
            }
        }
        
        @objc override func addSelectedTextToNote(_ sender: NSMenuItem) {
            evaluateJavaScript("window.getSelection().toString()") { [weak self] result, error in
                if let selectedText = result as? String, !selectedText.isEmpty {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: NSNotification.Name(CommonDefine.addNewTask),
                            object: nil,
                            userInfo: ["content": selectedText, "id": (self?.itemId ?? "")]
                        )
                    }
                }
            }
        }
        
        @objc func addSelectedTextToThink(_ sender: NSMenuItem) {
            evaluateJavaScript("window.getSelection().toString()") { [weak self] result, error in
                if let selectedText = result as? String, !selectedText.isEmpty {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: NSNotification.Name(CommonDefine.addNewThink),
                            object: nil,
                            userInfo: ["content": selectedText, "id": (self?.itemId ?? "")]
                        )
                    }
                }
            }
        }
        
        @objc func addSelectedTextToHighligh(_ sender: NSMenuItem) {
            evaluateJavaScript("window.getSelection().toString()") { [weak self] result, error in
                if let selectedText = result as? String, !selectedText.isEmpty {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: NSNotification.Name(CommonDefine.highlightText),
                            object: nil,
                            userInfo: ["content": selectedText, "id": (self?.itemId ?? "")]
                        )
                    }
                }
            }
        }
        
        #endif
        
        func updateMarkdownContent(_ markdownContent: String) {
            guard let markdownContentBase64Encoded = markdownContent.data(using: .utf8)?.base64EncodedString() else { return }
            self.callAsyncJavaScript("window.updateWithMarkdownContentBase64Encoded(`\(markdownContentBase64Encoded)`)", in: nil, in: .page, completionHandler: nil)
        }
        
        func scrollTo(text: String) {
            let sanitizedText = text
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'", with: "\\'")
                .replacingOccurrences(of: "\"", with: "\\\"")
            
            let script = """
            const elements = document.getElementsByTagName('*');
            for (let el of elements) {
                if (el.textContent.includes('\(sanitizedText)')) {
                    el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    break;
                }
            }
            """
            evaluateJavaScript(script, completionHandler: nil)
        }
    }
}
