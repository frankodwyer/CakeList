//
//  ImageStore.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.

import Foundation
import UIKit

enum ImageError: Error {
    case NotAnImageError
    case UnknownError
}

// this should all be replaced by a third party lib such as SDWebImage or AlamofireImage
// done this way due to the constraint of not using third party libs, this does some basic non-persistent caching and downsampling
// to reduce memory footprint.

class ImageStore {

    static let shared = ImageStore()

    private let downloadQueue = DispatchQueue(label: "image download queue")
    // TODO: listen for low memory warnings and lose the cache
    private let cache = NSCache<NSString, UIImage>() // could make a persistent cache also but this seems overkill and would need to handle expiry, besides, third party libs will handle this
    private var permanentFailures = Set<NSString>() // urls that we shouldn't attempt to load again

    func loadImage(httpClient: HttpClient = NetworkHttpClient(),
                   at url: String,
                   for size: CGSize,
                   scale: CGFloat,
                   completion: @escaping (UIImage?)->()) {

        downloadQueue.async {

            // rather than allowing insecure http loads to bypass ATS in the plist, hack the URL to force https.
            let url = url.replacingOccurrences(of: "http:", with: "https:")

            let key = ImageStore.makeCacheKey(url, size) // scale shouldn't vary on a single device

            let result: UIImage?
            // try to use cache first
            if let cachedImage = self.cache.object(forKey: key) {
                result = cachedImage
            } else if self.permanentFailures.contains(key) {
                // we decided this url will never load, don't try it again
                result = nil
            } else {
                // cache miss, not on blacklist => try to download.
                if let url = URL(string: url) {
                    let downsampleResult = ImageStore.downsample(imageAt: url, to: size, scale: scale)
                    switch downsampleResult {
                    case .success(let downloadedImage):
                        // happy case, we downloaded something, cache it.
                        self.cache.setObject(downloadedImage, forKey: key)
                        result = downloadedImage

                    case .failure(let error):
                        // failure, if it is permanent then don't try again
                        if self.errorIsNotRetryable(error) {
                            self.permanentFailures.insert(key)
                        }
                        result = nil
                    }

                }
                else {
                    // not even a proper URL
                    result = nil
                    self.permanentFailures.insert(key)
                }
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }

    }

    private func errorIsNotRetryable(_ error: Error) -> Bool {
        if let imageError = error as? ImageError, imageError == .NotAnImageError {
            // we got something from the network but it wasn't an image
            return true
        }

        let nsError = error as NSError

        if nsError.domain == "NSURLErrorDomain" && nsError.code == -1200 {
            // SSL error (arguably this is transient, however we shouldn't retry it until some time has passed)
            return true
        }

        return false
    }

    // all of this is to save memory/cpu/battery , rather than keeping the full size image around,
    // see https://developer.apple.com/videos/play/wwdc2018/219/ from which this is adapted.
    static func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> Result<UIImage, Error> {

        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary

        // we're already on a bg queue so we want this synchronous.
        // this is only so we can access the details of how the network request failed, and thus determine if it is transient or not
        let (data, response, error) = URLSession.shared.synchronousDataTask(with: imageURL)

        guard error == nil else { return .failure(error!) }
        guard let imageData = data, let imageResponse = response else { return Result.failure(ImageError.UnknownError)}

        guard let mimeType = imageResponse.mimeType, mimeType.contains("image") else { return .failure(ImageError.NotAnImageError) }

        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return Result.failure(ImageError.UnknownError) }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        if let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) {
            return .success(UIImage(cgImage: downsampledImage))
        } else {
            return .failure(ImageError.UnknownError)
        }
    }

    private static func makeCacheKey(_ url: String, _ size: CGSize) -> NSString {
        return NSString(string: "\(url)-\(size.height)-\(size.width)")
    }
}

// taken from https://stackoverflow.com/questions/26784315/can-i-somehow-do-a-synchronous-http-request-via-nsurlsession-in-swift
extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}
