//
//  TableTabViewController.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 02/12/2020.
//

import Foundation
import UIKit

class TableTabViewController: UITableViewController {
    
    override func viewDidLoad() {
        if tabBarController?.navigationItem.rightBarButtonItems?.count != 2 {
            let imageRefresh = UIImage(named: "icon_refresh")
            let refreshButton = UIBarButtonItem(image: imageRefresh, style: .plain, target: self, action: #selector(selectorY))
            tabBarController?.navigationItem.rightBarButtonItems?.append(refreshButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func selectorY() {
        OTMClient.getStudentLocations(numberOfStudents: "100") { (studentLocations, error) in
            UserModel.studentLocations = studentLocations
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
    
    
    //: MARK - Table View Controller Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserModel.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let dataForRow = UserModel.studentLocations[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = dataForRow.firstName + " \(dataForRow.lastName)"
        cell.imageView!.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = UserModel.studentLocations[indexPath.row]
        if let url = URL(string: rowData.mediaURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
}
