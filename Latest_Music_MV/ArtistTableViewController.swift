//
//  ArtistTableViewController.swift
//  Latest_Music_MV
//
//  Created by Kenny Lam on 28/04/2017.
//  Copyright © 2017 Kenny Lam. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistTableViewController: UITableViewController {

    // ArtistList
    var artistList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Get Events for the first time when on page
        getArtists()
        
        // When you pull table to refresh
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (artistList.count != 0) {
            return artistList.count
        } else {
            return 0
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = artistList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var artistName: String;
        
        //When you selected a cell. Define Action here
        artistName = artistList[indexPath.row]
        
        performSegue(withIdentifier: "ArtistDetailSegue", sender: artistName)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Make sure your segue name in storyboard is the same as this line
        if (segue.identifier == "ArtistDetailSegue") {
            if let artistDetailPage = segue.destination as? ArtistDetailController {
                artistDetailPage.artistName = sender as? String
                
            }
        }
        
    }
    
    //GetArtist
    func getArtists() {
        artistList = []
        
        //First request permission on Library.
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.runMediaLibraryQuery()
            } else {
                self.displayMediaLibraryError()
            }
        }
    }
    
    func runMediaLibraryQuery() {
        // This var wil prevent duplicate values
        var prevArtist:String = ""
        // Counter just to check how many artist.
        var counter:Int = 1
        
        //Loop in library with sort on Artist
        let query = MPMediaQuery.artists()
        
        // For each item found in query, print value in log
        for item in query.items! {
            if prevArtist != item.artist {
//                print("\(counter): \(item.artist!)")
                self.artistList.append(item.artist!)
                prevArtist = item.artist!
                counter = counter+1
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func displayMediaLibraryError() {
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by corporate or parental settings"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown error"
        }
        
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        present(controller, animated: true, completion: nil)
    }
    
    //Handle Pull function
    func handleRefresh(refreshControl: UIRefreshControl) {
        getArtists()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
