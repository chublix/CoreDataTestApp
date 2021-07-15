//
//  URLSession+RxSwift.swift
//  RestaurantsList
//
//  Created by Andriy Chuprina on 7/15/21.
//

import RxSwift

extension URLSession {
    
    func dataTask(with request: URLRequest) -> Single<Data?> {
        return Single<Data?>.create { [weak self] single in
            let task = self?.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                single(.success(data))
            })
            task?.resume()
            return Disposables.create { task?.cancel() }
        }
    }
    
}
