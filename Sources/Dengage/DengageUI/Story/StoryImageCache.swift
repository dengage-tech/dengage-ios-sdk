
import Foundation
import UIKit


private let oneHundredMB = 1024 * 1024 * 100

class StoryImageCache: NSCache<AnyObject, AnyObject> {
    static let shared = StoryImageCache()
    private override init() {
        super.init()
        self.setMaximumLimit()
    }
    func setMaximumLimit(size: Int = oneHundredMB) {
        totalCostLimit = size
    }
}


/*
 class StoryImageCache {
 static let shared = StoryImageCache()
 
 private let fileManager = FileManager.default
 private var mainDirectoryUrl: URL? {
 fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
 }
 
 func getImage(forKey key: String) -> UIImage? {
 guard let url = URL(string: key),
 let fileUrl = mainDirectoryUrl?.appendingPathComponent(url.lastPathComponent)
 else {
 return nil
 }
 
 guard let imageData = try? Data(contentsOf: fileUrl) else {
 return nil
 }
 
 return UIImage(data: imageData)
 }
 
 
 
 func cacheImage(_ image: UIImage, forKey key: String) {
 guard let url = URL(string: key),
 let fileUrl = mainDirectoryUrl?.appendingPathComponent(url.lastPathComponent)
 else {
 return
 }
 
 DispatchQueue.global().async {
 if let data = image.jpegData(compressionQuality: 1.0) {
 try? data.write(to: fileUrl)
 }
 
 }
 }
 
 }
 */




class StoryVideoCacheManager {
    
    enum VideoError: Error, CustomStringConvertible {
        case downloadError
        case fileRetrieveError
        var description: String {
            switch self {
            case .downloadError:
                return "Can't download video"
            case .fileRetrieveError:
                return "File not found"
            }
        }
    }
    
    static let shared = StoryVideoCacheManager()
    private init(){}
    typealias Response = Result<URL, Error>
    
    private let fileManager = FileManager.default
    private lazy var mainDirectoryUrl: URL? = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        return documentsUrl
    }()
    
    func getFile(for stringUrl: String, completionHandler: @escaping (Response) -> Void) {
        
        guard let file = directoryFor(stringUrl: stringUrl) else {
            completionHandler(Result.failure(VideoError.fileRetrieveError))
            return
        }
        
        guard !fileManager.fileExists(atPath: file.path) else {
            completionHandler(Result.success(file))
            return
        }
        
        guard let url = URL(string: stringUrl) else {
            completionHandler(Result.failure(VideoError.downloadError))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.downloadTask(with: url) { (tempUrl, response, error) in
            if let tempUrl = tempUrl, error == nil {
                do {
                    try self.fileManager.moveItem(at: tempUrl, to: file)
                    DispatchQueue.main.async {
                        completionHandler(Result.success(file))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(Result.failure(VideoError.downloadError))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(Result.failure(VideoError.downloadError))
                }
            }
        }
        task.resume()
    }
    
    private func directoryFor(stringUrl: String) -> URL? {
        guard let fileURL = URL(string: stringUrl)?.lastPathComponent, let mainDirURL = self.mainDirectoryUrl else { return nil }
        let file = mainDirURL.appendingPathComponent(fileURL)
        return file
    }
}

enum VideoError: Error {
    case downloadError, fileRetrieveError
}

extension VideoError: CustomStringConvertible {
    var description: String {
        switch self {
        case .downloadError: return "Can't download video"
        case .fileRetrieveError: return "File not found"
        }
    }
}
