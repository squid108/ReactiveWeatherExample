//
//  APIClient.swift
//  WhatsTheWeatherIn
//
//  Created by MaedaRyoto on 2016/03/09.
//  Copyright © 2016年 marinbenc. All rights reserved.
//

import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON

class APIClient {
    
    static func call(method: Alamofire.Method, urlString: String) -> Observable<AnyObject> {
        return Observable.create { observer -> Disposable in
            Alamofire.request(method, urlString)
                .responseJSON { response in
                    switch response.result {
                    case .Success(let value):
                        observer.on(.Next(value))
                        observer.on(.Completed)
                    case .Failure(let error):
                        observer.on(.Error(error))
                    }
            }
            return AnonymousDisposable {}
        }
    }
    
    class func postError(title: String, message: String) {
        let errorAlertController = PublishSubject<UIAlertController>()
        errorAlertController.on(.Next(UIAlertController(title: title, message: message, preferredStyle: .Alert)))
    }
}
