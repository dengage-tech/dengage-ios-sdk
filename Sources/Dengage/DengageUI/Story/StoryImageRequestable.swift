
import Foundation
import UIKit

public enum StoryImageError: Error, CustomStringConvertible {
    
    case invalidImageURL
    case downloadError
    
    public var description: String {
        switch self {
        case .invalidImageURL: return "Invalid Image URL"
        case .downloadError: return "Unable to download image"
        }
    }
}

class StoryImageURLSession {
    
    static let `default` = StoryImageURLSession()
    private var dataTasks = [URLSessionDataTask]()
    
    func downloadImage(from urlString: String, completion: @escaping ImageResponse) {
        guard let url = URL(string: urlString) else {
            completion(.failure(StoryImageError.invalidImageURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(.failure(error ?? StoryImageError.downloadError))
                return
            }
            StoryImageCache.shared.setObject(image, forKey: url.absoluteString as AnyObject)
            completion(.success(image))
        }
        task.resume()
        dataTasks.append(task)
    }
}

public enum StoryImageResult<Value, ErrorType> {
    case success(Value)
    case failure(ErrorType)
}

public typealias ImageResponse = (StoryImageResult<UIImage, Error>) -> Void

protocol StoryImageRequestable {
    func setImage(urlString: String, bgColors: [UIColor], placeholder: UIImage?, completion: ImageResponse?)
}

enum ImageStyle: Int {
    case squared, rounded
}

typealias SetImageRequester = (StoryResult<Bool, Error>) -> Void

extension UIImageView: StoryImageRequestable {
    func setImage(url: String, bgColors: [UIColor] = [], style: ImageStyle = .rounded, completion: SetImageRequester? = nil) {
        image = nil
        isActivityEnabled = true
        layer.masksToBounds = false
        layer.cornerRadius = style == .rounded ? frame.height / 2 : 0
        activityStyle = style == .rounded ? .white : .whiteLarge
        clipsToBounds = true
        setImage(urlString: url, bgColors: bgColors) { response in
            if let completion = completion {
                switch response {
                case .success(_):
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}


extension UIImageView {
    
    func setImage(urlString: String, bgColors: [UIColor] = [], placeholder: UIImage? = nil, completion: ImageResponse? = nil) {
        image = placeholder
        showActivityIndicator(bgColors: bgColors)
        
        if let cachedImage = StoryImageCache.shared.object(forKey: urlString as AnyObject) as? UIImage {
            hideActivityIndicator()
            image = cachedImage
            completion?(.success(cachedImage))
        } else {
            StoryImageURLSession.default.downloadImage(from: urlString) { [weak self] result in
                self?.handleImageResult(result, completion: completion)
            }
        }
    }
    

    
    private func handleImageResult(
        _ result: StoryImageResult<UIImage, Error>, completion: ImageResponse?
    ) {
        hideActivityIndicator()
        DispatchQueue.main.async {
            if case .success(let image) = result {
                self.image = image
            }
            completion?(result)
        }
    }
}
