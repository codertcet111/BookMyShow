//
//  Helper.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import Foundation
import Alamofire

//below are the some file constants
//Don't change below GoogleSignIn client Id credential
let Google_Sign_In_Client_Id = "615844827053-mvj0quhaojq90ee7g00innj565bf5feg.apps.googleusercontent.com"
let nytRoute = "https://api.themoviedb.org/3/"
//Below is the image base URl
let imageBaseUrl = "https://image.tmdb.org/t/p/"
//Don't change below key, Only update it once you got new API Key
let apiKey = "d8cf4f63bf49ec4ecb1cd9c4f1318bce"
let noInternetMessage = "No Internet Connection"
let somethingWentWrongMessage = "Something Went Wrong"
let unauthorizedMessage = "Not Authorized"
let requestLimitExidedMessage = "Sorry, You have exceded request limit"
let AppName = "BOOk MY SHOW"
var SIGNEDIN_USER_EMAIL: String?

//This function is to get indivisual Category requests from API
func getCategoryRequestUrl(_ category: String) -> String{
    var mainUrl = nytRoute
    mainUrl.append("trending/\(category)/day")
    mainUrl.append("?api_key=\(apiKey)")
    return mainUrl
}

//URL for insdivisual Movie or Show detail
func getMoviesShowUrl(_ type: String,_ id: Int) -> String{
    var mainUrl = nytRoute
    mainUrl.append("\(type)/\(id)")
    mainUrl.append("?api_key=\(apiKey)&language=en-US")
    return mainUrl
}

//URL for getting Image
func getImageUrl(_ type: String,_ imageUrl: String) -> String{
    var mainUrl = imageBaseUrl
    mainUrl.append("\(type)/\(imageUrl)")
    mainUrl.append("?api_key=\(apiKey)")
    return mainUrl
}

//For Alamofire the configurations are done below
//Change the 25.0 seconds to anythings as per API's and your's mutual understanding
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
