//
//  HomeViewController.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 29/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class HomeViewController: UIViewController{

    //Have used the Alamofire for API's request and response handling
    var alamoFireManager = Alamofire.SessionManager.default
    @IBOutlet var homeTableViewOutlet: UITableView!
    var MovieResults: MoviesResultsClass?
    var TvShowsResults: TvShowResultsClass?
    var activityView: UIActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buildMovieDataSource()
        print("Inside the View")
        
    }
//    override func awakeFromNib() {
//        self.delegate = self
//        self.dataSource = self
//    }
    
    
    func buildMovieDataSource(){
        self.showActivityIndicator()
        self.alamoFireManager = getManagerWithConf()
        //Below requesting to NYT's for section: home
        self.alamoFireManager.request(getCategoryRequestUrl("movie"))
            .responseJSON { response in
                self.stopActivityIndicator()
                if( response.error != nil)
                {
                    self.showAlert(somethingWentWrongMessage)
                    return
                }
                guard response.result.error == nil else {
                    
                    if( response.result.error?._code == -999 )
                    {
                        self.showAlert(somethingWentWrongMessage)
                        return
                    }
                    
                    self.showAlert(noInternetMessage)
                    return
                }
                
                if(response.response != nil && response.data != nil){
                    switch  response.response?.statusCode {
                    case 200:
                        self.MovieResults = try? JSONDecoder().decode(MoviesResultsClass.self,from: response.data!)
                        self.buildTvShowsDataSource()
                    case 401:
                        self.showAlert(unauthorizedMessage)
                    case 429:
                        self.showAlert(requestLimitExidedMessage)
                    default:
                        self.showAlert(somethingWentWrongMessage)
                    }
                }
        }
        
    }
    
    func buildTvShowsDataSource(){
        self.showActivityIndicator()
        self.alamoFireManager.request(getCategoryRequestUrl("tv"))
            .responseJSON { response in
                self.stopActivityIndicator()
                if( response.error != nil)
                {
                    self.showAlert(somethingWentWrongMessage)
                    return
                }
                guard response.result.error == nil else {
                    
                    if( response.result.error?._code == -999 )
                    {
                        self.showAlert(somethingWentWrongMessage)
                        return
                    }
                    
                    self.showAlert(noInternetMessage)
                    return
                }
                
                if(response.response != nil && response.data != nil){
                    switch  response.response?.statusCode {
                    case 200:
                        self.TvShowsResults = try? JSONDecoder().decode(TvShowResultsClass.self,from: response.data!)
                        self.homeTableViewOutlet.reloadData()
                    case 401:
                        self.showAlert(unauthorizedMessage)
                    case 429:
                        self.showAlert(requestLimitExidedMessage)
                    default:
                        self.showAlert(somethingWentWrongMessage)
                    }
                }
        }
    }
    
    func showAlert(_ message: String) -> (){
        let alert = UIAlertController(title: message, message: nil , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { _ in
            self.buildMovieDataSource()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            self.homeTableViewOutlet.isHidden = true
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActivityIndicator(){
        self.activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView?.center = self.view.center
        activityView?.hidesWhenStopped = true
        activityView?.startAnimating()
        activityView?.color = UIColor.black
        self.view.addSubview(activityView!)
    }
    
    func stopActivityIndicator(){
        self.activityView?.stopAnimating()
    }


}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell", for: indexPath) as! FeatureCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            return cell
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return self.MovieResults?.results.count ?? 0
        }else{
            return self.TvShowsResults?.results.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        print("Tag: \(collectionView.tag)")
        print("row: \(indexPath.row)")
        print("Section: \(indexPath.section)")
        if collectionView.tag == 1{
            if let tempDetail = self.MovieResults?.results[indexPath.row]{
                cell.titleLabelOutlet.text = tempDetail.title
                let imageURL = URL(string: getImageUrl("w500", tempDetail.poster_path))!
                cell.pictureImageViewOutlet.sd_setShowActivityIndicatorView(true)
                cell.pictureImageViewOutlet.sd_setIndicatorStyle(.gray)
                cell.pictureImageViewOutlet.contentMode = UIView.ContentMode.scaleAspectFit
                cell.pictureImageViewOutlet.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"Entertanment.png"))
                cell.rateLabelOutlet.text = String(tempDetail.vote_average)
                cell.popularityLabelOutlet.text = String(tempDetail.popularity)
                cell.categoryType = 0
                cell.id = tempDetail.id
            }
        }else {
            if let tempDetail = self.TvShowsResults?.results[indexPath.row]{
                cell.titleLabelOutlet.text = tempDetail.name
                let imageURL = URL(string: getImageUrl("w500", tempDetail.poster_path))!
                cell.pictureImageViewOutlet.sd_setShowActivityIndicatorView(true)
                cell.pictureImageViewOutlet.sd_setIndicatorStyle(.gray)
                cell.pictureImageViewOutlet.contentMode = UIView.ContentMode.scaleAspectFit
                cell.pictureImageViewOutlet.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"Entertanment.png"))
                cell.rateLabelOutlet.text = String(tempDetail.vote_average)
                cell.popularityLabelOutlet.text = String(tempDetail.popularity)
                cell.categoryType = 1
                cell.id = tempDetail.id
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.id = (collectionView.tag == 1 ? self.MovieResults?.results[indexPath.row].id : self.TvShowsResults?.results[indexPath.row].id) ?? 0
        detailViewController.categoryType = collectionView.tag == 1 ? "movie" : "tv"
        self.present(detailViewController, animated: true, completion: nil)
    }
}
