//
//  MapController.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 24/11/2020.
//

import Foundation
import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadNewAnnotations()
        addRefreshButton()
    }
    
    
    @objc func selectorRefreshButton() {
        loadNewAnnotations()
    }
    
    
    // MARK: - Functions declared
    
    func addAnotations() {
        var annotations = [MKPointAnnotation]()

        for student in UserModel.studentLocations {

            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let firstName = student.firstName
            let lastName = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func loadNewAnnotations () {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        OTMClient.getStudentLocations(numberOfStudents: "100", completion: { (studentLocations, error) in
            
            if let error = error {
                Alert.showAlert(viewController: self, title: "Alert", message: "The data could not be downloaded. Please try to log out and run the app again.", actionTitleOne: "OK", actionTitleTwo: nil)
            }
            
            UserModel.studentLocations = studentLocations
            DispatchQueue.main.async {
                self.addAnotations()
            }
        })
    }
    
    func addRefreshButton() {
        if tabBarController?.navigationItem.rightBarButtonItems?.count != 2 {
            let imageRefresh = UIImage(named: "icon_refresh")
            let refreshButton = UIBarButtonItem(image: imageRefresh, style: .plain, target: self, action: #selector(selectorRefreshButton))
            tabBarController?.navigationItem.rightBarButtonItems?.append(refreshButton)
        }
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if var toOpen = view.annotation?.subtitle! {
                if toOpen.contains("www.") == false {
                    toOpen = "www." + toOpen
                }
                if toOpen.contains("https://") || toOpen.contains("http://") == false {
                    toOpen = "https://" + toOpen
                }
                let urlToTest = URL(string: toOpen)
                guard let url = urlToTest else {
                    return
                }
                UIApplication.shared.open(url,options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
    
    

}
