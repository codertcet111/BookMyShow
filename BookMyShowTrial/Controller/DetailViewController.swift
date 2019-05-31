//
//  DetailViewController.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

/*
 Note: View Hierarchy
 In this view we have product description and also the Cast and producers detail.
 Other than this the user can add a comment for the product
 The comment will be stored on the device with the help of core data, and will be shown in the comment's section.
 Note: A big mistake that in the ViewController I have used 'review' for labels and UI components and 'comment' for backEnd process, so do not get confused by this
 Note: The term 'Product' have been refered for the Movie/TvShow
 */

import UIKit
import Alamofire
import SDWebImage
import CoreData
/*
 Alamofire: Networking
 SDWebImage: Image fetch and caching
 CoreData: For managing the local DataBase
 */

class DetailViewController: UIViewController {

    var categoryType: String = ""
    var id: Int = 0
    var model: detailsViewClass?
    var commentsData = [String]()
    
    //MARk: popUpView is used to show user's comment in detail
    @IBOutlet var popUpView: UIView!{
        didSet{
            popUpView.layer.cornerRadius = 8.0
            popUpView.clipsToBounds = true
        }
    }
    @IBOutlet weak var detailView: UIView!
    @IBAction func DoneButtonAction(_ sender: UIButton) {
        self.popUpView.removeFromSuperview()
    }
    
    @IBOutlet weak var popUpViewLabelOutlet: UILabel!{
        didSet{
            popUpViewLabelOutlet.layer.cornerRadius = 8.0
            popUpViewLabelOutlet.clipsToBounds = true
        }
    }
    @IBOutlet weak var castCollectionViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var rateTextview: UILabel!
    @IBOutlet weak var ProductimageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var castingPeopleLabel: UILabel!{
        didSet{
            castingPeopleLabel.layer.borderWidth = 0.5
            castingPeopleLabel.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var castCollectionview: UICollectionView!
    @IBOutlet weak var reviewLabelView: UIView!{
        didSet{
            reviewLabelView.layer.borderWidth = 0.5
            reviewLabelView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    //Review tag is same as Comment tag, so don't be confused
    @IBOutlet weak var reviewCollectionViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var reviewesCollectionView: UICollectionView!
    
    //addReviewButtonAction is to add comment to the DB
    @IBAction func addReviewButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Comment", message: "Enter The Comment", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Awesome!"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.saveComment(textField?.text ?? "Awesome!")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            //Do Nothing
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var reviewTextLabel: UILabel!
    @IBOutlet weak var TitleTextview: UILabel!
    //Have used the Alamofire for API's request and response handling
    var alamoFireManager = Alamofire.SessionManager.default
    var activityView: UIActivityIndicatorView?
    var producersAndCastName = [String]()
    var producersAndCastURL = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(categoryType)
        buildDataSource()

        // Do any additional setup after loading the view.
    }
    
    //MARK: buildDataSource it is the main method for requesting the API and setting the view
    func buildDataSource(){
        self.showActivityIndicator() 
        self.alamoFireManager = getManagerWithConf()
        //Below requesting to API for products detail
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
    
    //MARK: setDetailview, this method will set the view
    func setDetailview() -> (){
        self.TitleTextview.text = self.model?.name != nil ? self.model?.name : self.model?.title
        self.rateTextview.text = String(self.model?.vote_average ?? 0.0)
        self.descriptionTextView.text = String(self.model?.popularity ?? 0) + " Views"
        //Setting the products main image
        let imageURL = URL(string: getImageUrl("w500", self.model?.poster_path ?? ""))!
        self.ProductimageView.sd_setShowActivityIndicatorView(true)
        self.ProductimageView.sd_setIndicatorStyle(.gray)
        self.ProductimageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.ProductimageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"Entertanment.png"))
        //If in case no data for cast and producer
        if noDataForProducersAndCast(){
            self.castCollectionViewHeightConstraints.constant = 5
        }else{
            self.setDataForProducersAndCast()
        }
        //Get all the review data
        self.setCommentData()
    }
    
    //This method will call retrieveCommentData() and also will set the review's(comment) view
    func setCommentData() -> (){
        //Take the data from DB and dump into reviewData array
        self.retrieveCommentData()
        if self.commentsData.count == 0{
            self.reviewCollectionViewHeightConstraints.constant = 5
        }else{
            self.reviewCollectionViewHeightConstraints.constant = 100
            self.reviewesCollectionView.reloadData()
        }
    }
    
    func noDataForProducersAndCast() -> Bool{
        return self.model?.production_companies?.count == 0 && self.model?.created_by?.count == 0
    }
    
    //MARK: setDataForProducersAndCast setting the cast and producers data
    func setDataForProducersAndCast() -> (){
        for creator in self.model?.created_by ?? []{
            self.producersAndCastName.append(creator.name ?? "")
            self.producersAndCastURL.append(creator.profile_path ?? "")
        }
        for producer in self.model?.production_companies ?? []{
            self.producersAndCastName.append(producer.name ?? "")
            self.producersAndCastURL.append(producer.logo_path ?? "")
        }
        //Initializing the cast collection view
        self.castCollectionview.reloadData()
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
    
    //MARK: saveComment it will connect to PersistentManager for saving the data to DB
    func saveComment(_ comment: String){
        //let's get appDelegate object
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            //managedContextObject
            let managedContext = appDelegate.persistentContainer.viewContext
            //For Comment Entity
            let commentEntity = NSEntityDescription.entity(forEntityName: "Comments", in: managedContext)!
            let commentObject = NSManagedObject(entity: commentEntity, insertInto: managedContext)
            commentObject.setValue(comment, forKeyPath: "comment")
            commentObject.setValue(self.model?.id, forKeyPath: "productId")
            
            do{
                try managedContext.save()
            } catch let error as NSError{
                print("Could not save it, \(error), \(error.userInfo)")
            }
            //After saving the comment to DB it's time to update the view for new comment
            self.setCommentData()
        }
    }
    
    //MARK: retrieveCommentData it will fetch the data from DB
    func retrieveCommentData(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Comments")
            //Below a condition for fetching comments only for current product
            fetchRequest.predicate = NSPredicate(format: "productId == \(self.model?.id ?? 0)")
            do{
                let result = try managedContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    self.commentsData.append(data.value(forKey: "comment") as! String)
                }
            } catch {
                print("Failed to read Data")
                //Hide the comment section
            }
        }
    }

}

//MARK: COllectionView delegate's protocol implementation
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //I have assigned tag to indivisual collectionViews in the storyboard
        if collectionView.tag == 0{
            return self.producersAndCastName.count
        }else{
            return self.commentsData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "castCollectionViewCell", for: indexPath) as! castCollectionViewCell
            cell.castNameLabel.text = self.producersAndCastName[indexPath.row]
            let imageURL = URL(string: getImageUrl("w500", self.producersAndCastURL[indexPath.row]))!
            cell.castImageView.sd_setShowActivityIndicatorView(true)
            cell.castImageView.sd_setIndicatorStyle(.gray)
            cell.castImageView.contentMode = UIView.ContentMode.scaleAspectFit
            cell.castImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"Entertanment.png"))
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCollectionViewCell", for: indexPath) as! reviewCollectionViewCell
            cell.userrReviewTextLabel.text = self.commentsData[indexPath.row]
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            self.view.addSubview(self.popUpView)
            self.popUpViewLabelOutlet.text = self.commentsData[indexPath.row]
            self.popUpView.center = self.view.center
        }
    }
    
}
