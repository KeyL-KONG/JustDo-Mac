#if os(iOS)

import SwiftUI
import WebKit

struct iOSUserAgent {
    public static let defaultUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
}

// MARK: - 通用缓存管理器
class UniversalWebCacheManager {
    static let shared = UniversalWebCacheManager()
    private var cachedWebViews = [String: WKWebView]()
    private let cacheQueue = DispatchQueue(label: "com.universalweb.cache.queue", attributes: .concurrent)
    private let maxCacheCount = 5 // 最大缓存数量
    
    // 预加载网页
    func preloadURL(_ urlString: String, userAgent: String = iOSUserAgent.defaultUA) {
        guard let url = URL(string: urlString) else { return }
        
        cacheQueue.async(flags: .barrier) {
            // 检查是否已缓存
            if self.cachedWebViews[urlString] == nil {
                // 清理旧缓存如果超过限制
                if self.cachedWebViews.count >= self.maxCacheCount {
                    
                }
                
                let configuration = WKWebViewConfiguration()
                configuration.allowsInlineMediaPlayback = true
                configuration.mediaTypesRequiringUserActionForPlayback = []
                
                let webView = WKWebView(frame: .zero, configuration: configuration)
                webView.isHidden = true
                
                // 设置自定义User-Agent（如果提供）
                
                    //webView.customUserAgent = userAgent
                
                
                // 添加到缓存
                self.cachedWebViews[urlString] = webView
                
                // 开始预加载
                DispatchQueue.main.async {
                    webView.load(URLRequest(url: url))
                }
            }
        }
    }
    
    // 获取缓存的WebView
    func getCachedWebView(for urlString: String) -> WKWebView? {
        return cacheQueue.sync {
            return cachedWebViews[urlString]
        }
    }
    
    // 清理特定缓存
    func removeCache(for urlString: String) {
        cacheQueue.async(flags: .barrier) {
            self.cachedWebViews.removeValue(forKey: urlString)
        }
    }
    
    // 清理所有缓存
    func clearAllCache() {
        cacheQueue.async(flags: .barrier) {
            self.cachedWebViews.removeAll()
        }
    }
}

// MARK: - 通用WebView组件
struct UniversalWebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    var userAgent: String? = nil
    var onDisappear: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> WKWebView {
        // 尝试获取缓存的WebView
        if let cachedWebView = UniversalWebCacheManager.shared.getCachedWebView(for: urlString) {
            isLoading = false
            cachedWebView.isHidden = false
            cachedWebView.navigationDelegate = context.coordinator
            return cachedWebView
        }
        
        // 没有缓存则创建新的
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        
        // 设置自定义User-Agent
//        if let userAgent = userAgent {
//            webView.customUserAgent = userAgent
//        } else {
//            webView.customUserAgent = iOSUserAgent.defaultUA
//        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 只有新创建的WebView才需要加载
        if uiView.url == nil, let url = URL(string: urlString) {
            uiView.load(URLRequest(url: url))
        }
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // 暂停所有媒体播放
        let pauseScript = """
        document.querySelectorAll('video, audio').forEach(e => {
            e.pause();
            e.currentTime = 0;
        });
        """
        uiView.evaluateJavaScript(pauseScript)
        
        // 通知消失事件
        coordinator.parent.onDisappear?()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: UniversalWebView
        
        init(_ parent: UniversalWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            if parent.urlString.contains("douyin") {
                let jsScript = """
                document.querySelector('header').style.display = 'none';
                document.querySelector('footer').style.display = 'none';
                """
                webView.evaluateJavaScript(jsScript)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

// MARK: - 带加载状态的容器视图
struct UniversalWebViewContainer: View {
    let urlString: String
    var userAgent: String? = nil
    var title: String? = nil
    var showProgress: Bool = true
    var preloadEnabled: Bool = true
    
    @State private var isLoading = true
    @State private var estimatedProgress: Double = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            UniversalWebView(
                urlString: urlString,
                isLoading: $isLoading,
                userAgent: userAgent
            ) {
                // WebView消失时的操作
                print("WebView disappeared for: \(urlString)")
            }
            .edgesIgnoringSafeArea(.all)
            
            // 进度条
            if showProgress && isLoading {
                ProgressView(value: estimatedProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 2)
                    .animation(.easeInOut, value: estimatedProgress)
            }
            
            // 加载指示器
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(title ?? "网页浏览")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if preloadEnabled {
                UniversalWebCacheManager.shared.preloadURL(urlString, userAgent: userAgent ?? iOSUserAgent.defaultUA)
            }
        }
    }
}

// MARK: - 预览
struct UniversalWebView_Previews: PreviewProvider {
    static var previews: some View {
        WebViewExample()
    }
}

#endif
