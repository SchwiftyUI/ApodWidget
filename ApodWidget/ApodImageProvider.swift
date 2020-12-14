//
//  ApodImageProvider.swift
//  ApodWidgetExtension
//
//  Created by SchwiftyUI on 12/7/20.
//

import Foundation
import SwiftUI

enum ApodImageResponse {
    case Success(image: UIImage)
    case Failure
}

struct ApodApiResponse: Decodable {
    var url: String
}

class ApodImageProvider {
    static func getImageFromApi(completion: ((ApodImageResponse) -> Void)?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let urlString = "https://api.nasa.gov/planetary/apod?api_key=eaRYg7fgTemadUv1bQawGRqCWBgktMjolYwiRrHK&date=\(formatter.string(from: date))"
        
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseResponseAndGetImage(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }
    
    static func parseResponseAndGetImage(data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((ApodImageResponse) -> Void)?) {
        
        guard error == nil, let content = data else {
            print("error getting data from API")
            let response = ApodImageResponse.Failure
            completion?(response)
            return
        }
        
        var apodApiResponse: ApodApiResponse
        do {
            apodApiResponse = try JSONDecoder().decode(ApodApiResponse.self, from: content)
        } catch {
            print("error parsing URL from data")
            let response = ApodImageResponse.Failure
            completion?(response)
            return
        }
        
        let url = URL(string: apodApiResponse.url)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseImageFromResponse(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
        
    }
    
    static func parseImageFromResponse(data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((ApodImageResponse) -> Void)?) {
        
        guard error == nil, let content = data else {
            print("error getting image data")
            let response = ApodImageResponse.Failure
            completion?(response)
            return
        }
        
        let image = UIImage(data: content)!
        let response = ApodImageResponse.Success(image: image)
        completion?(response)
    }
}
