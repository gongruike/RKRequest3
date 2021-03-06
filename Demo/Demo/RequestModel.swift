//
//  RequestModel.swift
//  Demo
//
//  Created by gongruike on 2017/3/1.
//  Copyright © 2017年 gongruike. All rights reserved.
//

import Alamofire
import SwiftyJSON

class User {
    
    let uid: String
    
    let username: String
    
    init(attributes: JSON) {
        //
        uid = attributes["uid"].stringValue
        username = attributes["username"].stringValue
    }
    
}

struct MyError: Error {
    // 与服务器协商的错误信息
    enum ErrorType {
        case stringInfo(String)
        case numberInfo(Int)
        case arrayInfo(Array<String>)
    }
    
    let type: ErrorType
    
    // 可以添加别的信息
    
    func getErrorInfo() -> String {
        switch self.type {
        case .stringInfo(let str):
            return str
        case .numberInfo(let number):
            return "\(number)"
        default:
            return "unknown error"
        }
    }
    
}

extension Error {
    
    func getErrorInfo() -> String {
        if let err = self as? MyError {
            return err.getErrorInfo()
        } else {
            return localizedDescription
        }
    }
    
}

class BaseRequest<Value>: RKSwiftyJSONRequest<Value> {
    
    override func parse(_ dataResponse: DataResponse<JSON>) -> Result<Value> {
        
        switch dataResponse.result {
        case .success(let data):
            return checkResponseError(dataResponse) ?? getExpectedResult(data)
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    /*
        我一直犹豫是否要把checkResponseError和getExpectedResult放到Request中
     
        现在流行的restful api接口有两种类型，
        1、以http status code为准，只有200系列是成功的，其他401，400，500类型的都是错误
        2、只要服务器有返回都是200，具体的错误code和信息都在返回的响应里
     
     */
    
    // 根据与服务器协定的错误处理方式进行检查
    func checkResponseError(_ dataResponse: DataResponse<JSON>) -> Result<Value>? {

        let statusCode = dataResponse.response?.statusCode
        if statusCode == 400 {
            return Result.failure(MyError(type: .stringInfo("error")))
        } else if statusCode == 401 {
            return Result.failure(MyError(type: .numberInfo(12345)))
        } else {
            return nil
        }
    }
    
    // 获取期望的数据
    func getExpectedResult(_ data: JSON) -> Result<Value> {
        return Result.failure(RKError.invalidRequestType)
    }
    
}

class UserInfoRequest: BaseRequest<User> {
    
    init(userID: String, completionHandler: CompletionHandler?) {
        super.init(url: "user/\(userID)", completionHandler: completionHandler)
    }
    
    override func getExpectedResult(_ data: JSON) -> Result<User> {
        return Result.success(User(attributes: data))
    }
    
}

class UserListRequest: BaseRequest<[User]> {
    
    init(completionHandler: CompletionHandler?) {
        super.init(url: "user", completionHandler: completionHandler)
    }
    
    override func getExpectedResult(_ data: JSON) -> Result<Array<User>> {
        return Result.success(data.map { User(attributes: $1) })
    }
    
}
