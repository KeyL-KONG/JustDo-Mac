//
//  Image+Extensions.swift
//  ToDo
//
//  Created by ByteDance on 2025/6/3.
//

#if os(macOS)
import Cocoa

extension NSImage {
    /// 将 NSImage 转换为 Data 对象
    /// - Parameters:
    ///   - format: 目标格式（.png, .jpeg, .tiff 等）
    ///   - properties: 格式特定属性（如 JPEG 压缩质量）
    /// - Returns: Data 对象（转换失败返回 nil）
    func toData(format: NSBitmapImageRep.FileType = .png,
                properties: [NSBitmapImageRep.PropertyKey: Any] = [:]) -> Data? {
        
        // 1. 获取图像的 TIFF 表示
        guard let tiffData = self.tiffRepresentation else {
            print("无法获取 TIFF 表示")
            return nil
        }
        
        // 2. 创建位图表示
        guard let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            print("无法创建位图表示")
            return nil
        }
        
        // 3. 转换为目标格式
        return bitmapRep.representation(using: format, properties: properties)
    }
    
    // 快捷方法
    func pngData() -> Data? {
        return toData(format: .png)
    }
    
    func jpegData(compressionQuality: CGFloat = 0.8) -> Data? {
        return toData(
            format: .jpeg,
            properties: [.compressionFactor: compressionQuality]
        )
    }
}

#endif
