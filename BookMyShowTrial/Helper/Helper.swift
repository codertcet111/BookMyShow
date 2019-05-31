//
//  Helper.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import Foundation
import Alamofire

let nytRoute = "https://api.themoviedb.org/3/"
let imageBaseUrl = "https://image.tmdb.org/t/p/"
let apiKey = "d8cf4f63bf49ec4ecb1cd9c4f1318bce"
let noInternetMessage = "No Internet Connection"
let somethingWentWrongMessage = "Something Went Wrong"
let unauthorizedMessage = "Not Authorized"
let requestLimitExidedMessage = "Sorry, You have exceded request limit"
var SIGNEDIN_USER_EMAIL: String?

func getCategoryRequestUrl(_ category: String) -> String{
    var mainUrl = nytRoute
    mainUrl.append("trending/\(category)/day")
    mainUrl.append("?api_key=\(apiKey)")
    return mainUrl
}

func getMoviesShowUrl(_ type: String,_ id: Int) -> String{
    var mainUrl = nytRoute
    mainUrl.append("\(type)/\(id)")
    mainUrl.append("?api_key=\(apiKey)&language=en-US")
    return mainUrl
}

func getImageUrl(_ type: String,_ imageUrl: String) -> String{
    var mainUrl = imageBaseUrl
    mainUrl.append("\(type)/\(imageUrl)")
    mainUrl.append("?api_key=\(apiKey)")
    return mainUrl
}

func getManagerWithConf() -> SessionManager
{
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForResource = 25.0
    configuration.timeoutIntervalForRequest = 25.0
    let manager = Alamofire.SessionManager(configuration: configuration)
    manager.session.configuration.timeoutIntervalForRequest = 25.0
    manager.session.configuration.timeoutIntervalForResource = 25.0
    return manager
    
}
