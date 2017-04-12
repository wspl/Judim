//
//  PLFetcher.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Alamofire
import Hydra

class PLFetcher {
    var method: HTTPMethod = .get
    var url: String = ""
    
    func method(_ method: HTTPMethod) -> PLFetcher {
        self.method = method
        return self
    }
    
    func url(_ url: String) -> PLFetcher {
        self.url = url
        return self
    }

    var html: Promise<String> {
        return Promise { resolve, reject in
            self.request = Alamofire
                .request(self.url, method: self.method, parameters: nil, headers: nil)
            
            self.request!.responseString(queue: .global(qos: .background), encoding: nil)
                { body in
                    
                if body.error == nil {
                    resolve(body.value!)
                } else {
                    reject(body.error!)
                }
            }
        }
    }
    
    typealias ProgressCallback = (_ progress: Double) -> ()
    var progressCallbacks = [ProgressCallback]()
    func progress(_ prg: @escaping (_ progress: Double) -> ()) -> PLFetcher {
        progressCallbacks.append(prg)
        return self
    }
    
    var request: DataRequest?
    
    var download: Promise<Data> {
        return Promise { resolve, reject in
            self.request = Alamofire
                .request(self.url, method: self.method)
                .downloadProgress { progress in
                    self.progressCallbacks.forEach { cb in cb(progress.fractionCompleted) }
            }
                
            self.request!.responseData(queue: .global(qos: .background)) { response in
                if let data = response.result.value {
                    resolve(data)
                } else {
                    reject(response.error!)
                }
            }
            
        }
    }
}
