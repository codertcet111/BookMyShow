//
//  DetailViewController.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class DetailViewController: UIViewController {

    var categoryType: String
    var id: Int
    var model: detailsViewClass?
    var reviewData: [String]?
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var castCollectionViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var rateTextview: UILabel!
    @IBOutlet weak var ProductimageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var castingPeopleLabel: UILabel!
    @IBOutlet weak var castCollectionview: UICollectionView!
    @IBOutlet weak var reviewLabelView: UIView!
    
    @IBOutlet weak var reviewesCollectionView: UICollectionView!
    @IBAction func addReviewButtonAction(_ sender: UIButton) {
    }
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var reviewTextLabel: UILabel!
    @IBOutlet weak var TitleTextview: UILabel!
    //Have used the Alamofire for API's request and response handling
    var alamoFireManager = Alamofire.SessionManager.default
    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(categoryType)
        buildDataSource()

        // Do any additional setup after loading the view.
    }
    func buildDataSource(){
        self.showActivityIndicator() 
        self.alamoFireManager = getManagerWithConf()
        //Below requesting to NYT's for section: home
        self.alamoFireManager.request(getMoviesShowUrl(self.categoryType, self.id))
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
                        self.model = try? JSONDecoder().decode(detailsViewClass.self,from: response.data!)
                        self.setDetailview()
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
    
    func setDetailview() -> (){
        self.TitleTextview.text = self.model?.name != nil ? self.model?.name : self.model?.title
        self.rateTextview.text = String(self.model?.vote_average ?? 0.0)
        self.descriptionTextView.text = String(self.model?.popularity ?? 0) + " Views"
        let imageURL = URL(string: getImageUrl("w500", self.model?.poster_path ?? ""))!
        self.ProductimageView.sd_setShowActivityIndicatorView(true)
        self.ProductimageView.sd_setIndicatorStyle(.gray)
        self.ProductimageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.ProductimageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"Entertanment.png"))
        if noDataForProduction(){
            self.castCollectionview.isHidden = true
            self.castCollectionViewHeightConstraints.constant = 0
            self.castCollectionview.reloadData()
        }
        //Get all the review data
        self.setReviewData()
    }
    
    func setReviewData() -> (){
        //Take the data from DB and dump into reviewData array
        self.reviewesCollectionView.reloadData()
    }
    
    func noDataForProduction() -> Bool{
        return self.model?.production_companies?.count == 0 && self.model?.created_by?.count == 0
    }
    
    func showAlert(_ message: String) -> (){
        let alert = UIAlertController(title: message, message: nil , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { _ in
            self.buildDataSource()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
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

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0{
            return 0
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}
