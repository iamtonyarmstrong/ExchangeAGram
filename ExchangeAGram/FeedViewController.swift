//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Anthony Armstrong on 3/14/15.
//  Copyright (c) 2015 openinformant. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var feedArray:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let moc = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "FeedItem")
        feedArray = moc!.executeFetchRequest(request, error: nil)!

        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:FeedCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("feedCell", forIndexPath: indexPath) as FeedCollectionViewCell

        let thisItem = feedArray[indexPath.item] as FeedItem

        //print("\(indexPath.item): " + thisItem.caption)

        cell.cellCaption.text = thisItem.caption
        cell.cellImage.image = UIImage(data: thisItem.image)


        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let feedItem:FeedItem = feedArray[indexPath.item] as FeedItem


        println("\(indexPath.item): " + feedItem.caption)

        var filterVC:FilterViewController = FilterViewController()
        filterVC.thisFeedItem = feedItem

        // Now, call the new view controller using code
        self.navigationController?.pushViewController(filterVC, animated: false)     // this is an optional because you might not be inside a NavigationController


    }

    // MARK: - Actions

    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {

         // How to create the Camera
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            let mediaTypes = [kUTTypeImage]   //Grab the media types -> Images
            cameraController.mediaTypes = mediaTypes    //set the Media Types
            cameraController.allowsEditing = false      //No editing for now

            self.presentViewController(cameraController, animated: true, completion: nil)   //show the camera

        } else if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            let mediaTypes = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false

            self.presentViewController(photoLibraryController, animated: true, completion: nil)

        } else {
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))

            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage

        let imageData = UIImageJPEGRepresentation(image, 1.0)       //Convert the image data into a JPEG
        let thumbNailData = UIImageJPEGRepresentation(image, 0.4)   //Make a thumbnail

        // Do Core Data stuff...
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let moc = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: moc!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: moc)

        feedItem.image = imageData!
        feedItem.caption = "Test Caption"
        feedItem.thumbNail = thumbNailData
        appDelegate.saveContext()

        // Add the new image to the array, then force UI to update the dimiss the Image Picker Controller
        self.feedArray.append(feedItem)
        self.collectionView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
