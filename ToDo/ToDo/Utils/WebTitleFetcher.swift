import Foundation
import SwiftSoup

class WebTitleFetcher {
    static let shared = WebTitleFetcher()
    private let session: URLSession
    
    init(configuration: URLSessionConfiguration = .default) {
        configuration.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchDouyinTitleFromWeb(url: String, completion: @escaping (String?, Error?) -> Void) {
        // 1. 获取重定向后的真实URL
        guard let url = URL(string: url) else {
            completion(nil, NSError(domain: "Invalid URL", code: 400, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let finalURL = (response as? HTTPURLResponse)?.url else {
                completion(nil, NSError(domain: "Can't get final URL", code: 500, userInfo: nil))
                return
            }
            
            // 2. 获取网页内容
            URLSession.shared.dataTask(with: finalURL) { data, _, error in
                guard let data = data, let html = String(data: data, encoding: .utf8) else {
                    completion(nil, error)
                    return
                }
                
                // 3. 解析标题
                if let range = html.range(of: "<title>", options: .caseInsensitive),
                   let endRange = html.range(of: "</title>", options: .caseInsensitive, range: range.upperBound..<html.endIndex) {
                    let title = String(html[range.upperBound..<endRange.lowerBound])
                        .replacingOccurrences(of: "抖音", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(title, nil)
                } else {
                    completion(nil, NSError(domain: "Title not found", code: 404, userInfo: nil))
                }
            }.resume()
        }.resume()
    }
    
    func fetchTitle(
        from urlString: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // 验证 URL
        guard let url = URL(string: urlString) else {
            completion(.failure(TitleError.invalidURL))
            return
        }
        
        // 发起请求
        session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // 错误处理
            if let error = error {
                self.completeOnMainThread(.failure(error), completion: completion)
                return
            }
            
            // 数据校验
            guard let data = data,
                  let html = String(data: data, encoding: self.detectEncoding(response: response))
            else {
                self.completeOnMainThread(.failure(TitleError.noData), completion: completion)
                return
            }
            
            // 解析标题
            do {
                let title = try self.parseTitle(from: html)
                self.completeOnMainThread(.success(title), completion: completion)
            } catch {
                self.completeOnMainThread(.failure(error), completion: completion)
            }
        }.resume()
    }
    
    private func detectEncoding(response: URLResponse?) -> String.Encoding {
        guard let response = response as? HTTPURLResponse,
              let encodingName = response.textEncodingName
        else { return .utf8 }
        
        return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
        ))
    }
    
    private func parseTitle(from html: String) throws -> String {
        let doc = try SwiftSoup.parse(html)
        
        // 优先 Open Graph 标题
        if let ogTitle = try doc.select("meta[property='og:title']").first()?.attr("content"),
           !ogTitle.isEmpty {
            return ogTitle
        }
        
        // 普通标题标签
        let title = try doc.title().trimmingCharacters(in: .whitespacesAndNewlines)
        return title
    }
    
    private func completeOnMainThread<T>(
        _ result: Result<T, Error>,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

enum TitleError: Error {
    case invalidURL, noData, parseFailed, emptyTitle
}
