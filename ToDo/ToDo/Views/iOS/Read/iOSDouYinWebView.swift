#if os(iOS)
import SwiftUI
import WebKit
import SafariServices

struct DouyinWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    // 添加一个可选的闭包用于处理视图消失时的操作
    var onDisappear: (() -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        
        // 设置移动端User-Agent
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    // 添加此方法以在视图消失时暂停媒体
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        let pauseScript = """
        var videos = document.querySelectorAll('video');
        videos.forEach(function(video) {
            video.pause();
        });
        var audios = document.querySelectorAll('audio');
        audios.forEach(function(audio) {
            audio.pause();
        });
        """
        uiView.evaluateJavaScript(pauseScript)
        
        // 调用闭包通知父视图
        coordinator.parent.onDisappear?()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: DouyinWebView
        
        init(_ parent: DouyinWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            // 注入JS优化抖音页面显示
            let jsScript = """
            document.querySelector('header').style.display = 'none';
            document.querySelector('footer').style.display = 'none';
            """
            webView.evaluateJavaScript(jsScript)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

struct DouyinWebViewContainer: View {
    let urlString: String
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let url = URL(string: urlString) {
                DouyinWebView(url: url, isLoading: $isLoading) {
                    // 视图消失时的回调
                    print("WebView disappeared, audio/video paused")
                }
                .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
            } else {
                Text("无效的抖音链接")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("抖音视频")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#endif
