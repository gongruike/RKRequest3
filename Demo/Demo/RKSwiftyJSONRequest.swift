//
//  RKSwiftyJSONRequest.swift
//  Demo
//
//  Created by gongruike on 2017/3/1.
//  Copyright © 2017年 gongruike. All rights reserved.
//

import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class RKSwiftyJSONRequest<Value>: DataRequest<SwiftyJSON.JSON, Value> {

    override func setResponseHandler() {
        //
        dataRequest?.responseSwiftyJSON(completionHandler: { dataResponse in
            
            print(dataResponse.debugDescription)
            //
            self.deliver(dataResponse);
        })
    }
    
}
