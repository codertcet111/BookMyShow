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
import CoreData
import GoogleSignIn

class DetailViewController: UIViewController {

    var categoryType: String = ""
    var id: Int = 0
    var model: detailsViewClass?
    var commentsData = [[String]]()
    
//    init(_ id: Int,_ categoryType: String) {
//        self.id = id
//        self.categoryType = categoryType
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var castCollectionViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var rateTextview: UILabel!
    @IBOutlet weak var ProductimageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var castingPeopleLabel: UILabel!{
        didSet{
            castingPeopleLabel.layer.borderWidth = 0.5
            castingPeopleLabel.layer.borderColor = UIColor.black.cgColor
        }
    }
    @IBOutlet weak var castCollectionview: UICollectionView!
    @IBOutlet weak var reviewLabelView: UIView!{
        didSet{
            reviewLabelView.layer.borderWidth = 0.5
            reviewLabelView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet weak var reviewCollectionViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var reviewesCollectionView: UICollectionView!
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
        if noDataForProducersAndCast(){
//            self.castCollectionview.isHidden = true
            self.castCollectionViewHeightConstraints.constant = 5
        }else{
            self.setDataForProducersAndCast()
        }
        //Get all the review data
        self.setCommentData()
    }
    
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
    
    func setDataForProducersAndCast() -> (){
        for creator in self.model?.created_by ?? []{
            self.producersAndCastName.append(creator.name ?? "")
            self.producersAndCastURL.append(creator.profile_path ?? "")
        }
        for producer in self.model?.production_companies ?? []{
            self.producersAndCastName.append(producer.name ?? "")
            self.producersAndCastURL.append(producer.logo_path ?? "")
        }
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
    
    func saveComment(_ comment: String){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let managedContext = appDelegate.persistentContainer.viewContext
            let commentEntity = NSEntityDescription.entity(forEntityName: "Comments", in: managedContext)!
            let commentObject = NSManagedObject(entity: commentEntity, insertInto: managedContext)
            commentObject.setValue(comment, forKeyPath: "comment")
            commentObject.setValue(SIGNEDIN_USER_EMAIL ?? "Anonymous", forKeyPath: "email")
            
            do{
                try managedContext.save()
            } catch let error as NSError{
                print("Could not save it, \(error), \(error.userInfo)")
            }
            self.setCommentData()
        }
    }
    
    func retrieveCommentData(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Comments")
            do{
                let result = try managedContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    self.commentsData.append([data.value(forKey: "comment") as! String, data.value(forKey: "email") as! String])
                }
            } catch {
                print("Failed to read Data")
                //Hide the comment section
            }
        }
    }

}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            let normalText = self.commentsData[indexPath.row][0]
            let boldText  = " - by :" + self.commentsData[indexPath.row][1]
            let attributedString = NSMutableAttributedString(string:normalText)
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
            let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
            attributedString.append(boldString)
            cell.userrReviewTextLabel.attributedText = attributedString
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}
