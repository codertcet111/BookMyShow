//
//  HomeViewController.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 29/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

/*
 Note: View Hierarchy
 In the HomeView I have Used TableView:
 First TableViewCell is having Main Image then,
 The second tableViewcell is containing CollectionView, this tableViewCell is reused for 2 times in my case for Movies and TvShows,
 U can use it for much more categories.
 In the collectionView, one type of collectionviewCell is reused for many times.
 */

import UIKit
import Alamofire
import SDWebImage
//SDWebImage: For Image fetch and caching
//Alamofire: For Networking

class HomeViewController: UIViewController{

    //Have used the Alamofire for API's request and response handling
    var alamoFireManager = Alamofire.SessionManager.default
    @IBOutlet var homeTableViewOutlet: UITableView!
    /*
     MovieResults are for storing movies collection and similarly for TvShows collection
     Similarly U can do it for all diffrent categories such as, Persons, Events and many more.
     */
    var MovieResults: MoviesResultsClass?
    var TvShowsResults: TvShowResultsClass?
    var activityView: UIActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = AppName
        buildMovieDataSource()
        
    }
    
    //MARK: buildMovieDataSource
    func buildMovieDataSource(){
        self.showActivityIndicator()
        self.alamoFireManager = getManagerWithConf()
        //Below requesting to API for the trending movies
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
                
                //No Networking error, now the time to check API's response
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
    
    //Below requesting to API for the trending TvShows
    //MARK: buildTvShowDataSource
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
    
    
    //MARK: Show alert method for showing alert view
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
    
    //MARK: Show activity indicator
    func showActivityIndicator(){
        self.activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView?.center = self.view.center
        activityView?.hidesWhenStopped = true
        activityView?.startAnimating()
        activityView?.color = UIColor.black
        self.view.addSubview(activityView!)
    }
    
    //MARK: Stop Activity indicator
    func stopActivityIndicator(){
        self.activityView?.stopAnimating()
    }
    
    //MARk: prepare for segue is overwritten to transfer data to the next ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Since sender is Any type so can transfer array as well
        if segue.identifier == "detailSegue"{
            let passedData = sender as? NSArray
            //Below setting the destination view controllers properties
            let selectedIndexPath = passedData?[1] as? NSIndexPath
            let tag = passedData?[0] as? NSInteger
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.id = (tag == 1 ? self.MovieResults?.results[selectedIndexPath?.row ?? 0].id : self.TvShowsResults?.results[selectedIndexPath?.row ?? 0].id) ?? 0
            //If their are more categories then please remove below If condition and write switch
            detailViewController.categoryType = (tag == 1 ? "movie" : "tv")
        }
    }

}


//MARK: UITableViewDelegate method's implemented
extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    //MARK: TableViewNumberOfSection
    func numberOfSections(in tableView: UITableView) -> Int {
        //If adding more section then update it
        return 1
    }
    
    //MARK: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //1 row for Main Banner Image and rest are for number of widgets (1 for moview, 1 for TvShows)
        //Change the number if want more widgets and also handle in all its delegate methods
        return 3
    }
    
    //MARK: CellForRowAt
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

//MARK: UICollectionView Delegate's protocol have been implemented
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    //MARK: CollectionViewNumberOfSection
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //If adding more section then update it
        return 1
    }
    
    //MARK: CollectionViewNumberOfItems
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //In the category cell's 'setCollectionViewDataSourceDelegate' method, I have assigned tags to diffrent collectionView
        if collectionView.tag == 1{
            return self.MovieResults?.results.count ?? 0
        }else{
            return self.TvShowsResults?.results.count ?? 0
        }
    }
    
    //MARK: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Intialized cell without IF condition since same cell has been reused for all tableViewcell's
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        print("Tag: \(collectionView.tag)")
        print("row: \(indexPath.row)")
        print("Section: \(indexPath.section)")
        if collectionView.tag == 1{
            if let tempDetail = self.MovieResults?.results[indexPath.row]{
                cell.titleLabelOutlet.text = tempDetail.title
                //Get the image URl from Helper class
                let imageURL = URL(string: getImageUrl("w500", tempDetail.poster_path))!
                cell.pictureImageViewOutlet.sd_setShowActivityIndicatorView(true)
                cell.pictureImageViewOutlet.sd_setIndicatorStyle(.gray)
                cell.pictureImageViewOutlet.contentMode = UIView.ContentMode.scaleAspectFit
                cell.pictureImageViewOutlet.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"Entertanment.png"))
                cell.rateLabelOutlet.text = String(tempDetail.vote_average)
                cell.popularityLabelOutlet.text = String(tempDetail.popularity)
                //Below category type has been assigned to help in identifying its type while redirecting to next view
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
                //Below category type has been assigned to help in identifying its type while redirecting to next view
                cell.categoryType = 1
                cell.id = tempDetail.id
            }
        }
        return cell
    }
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //For cell selection just performing segue
        //Have passed details in sender
        performSegue(withIdentifier: "detailSegue", sender: [collectionView.tag, indexPath])
    }
}
