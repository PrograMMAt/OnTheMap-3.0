//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Ondrej Winter on 01/12/2020.
//

import Foundation
import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    var finishButtonTapped: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        linkTextField.delegate = self
        locationTextField.text = "What's your location?"
        linkTextField.text = "Share a link."
        
    }

    
    @IBAction func findLocationButtonTapped(_ sender: Any) {
        self.view.endEditing(true) //Causes the view (or one of its embedded text fields) to resign the first responder status.
        var clPlacemark: CLPlacemark?
        let geocoder = MapKit.CLGeocoder()

        var name = ""
        var locality = ""
        var country = ""
        var coordinate = CLLocationCoordinate2D()
        
        Spinner.start()
        
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) in
            guard let placemarks = placemarks else {
                Alert.showAlert(viewController: self, title: "Alert", message: "We didn't find the address. Please try again.", actionTitleOne: "OK", actionTitleTwo: nil, style: .default)
                return
            }
                
            clPlacemark = CLPlacemark(placemark: placemarks[0])
            if let coor = clPlacemark!.location?.coordinate {
                coordinate = coor
            }
            //update model
            UserModel.user["latitude"] = Float(coordinate.latitude)
            UserModel.user["longitude"] = Float(coordinate.longitude)
            
            if let clName = clPlacemark?.name {
                name = clName
                name.append(", ")
            }
            if let clloc = clPlacemark?.locality {
                locality = clloc
                locality.append(", ")
            }
            
            if let count = clPlacemark?.country {
                country = count
            }
            
            if self.linkTextField.text == "" || self.linkTextField.text == "Share a link." {
                Alert.showAlert(viewController: self, title: "Alert", message: "Please fill in a link.", actionTitleOne: "OK", actionTitleTwo: nil, style: .cancel)
            } else {
            
            // create mapView
            let mapView = MKMapView()
            let leftMargin:CGFloat = 0
            let topMargin:CGFloat = 0
            let mapWidth:CGFloat = self.view.frame.size.width
            let mapHeight:CGFloat = self.view.frame.size.height
            mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
            self.view.addSubview(mapView)
            mapView.delegate = self

            //mapView.centerCoordinate = coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            mapView.region = MKCoordinateRegion(center: coordinate, span: span)

            // create annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = name + locality + country
            mapView.addAnnotation(annotation)
            
            // create button
            let button = MainButton()
            button.setTitle("FINISH", for: .normal)
                button.frame = CGRect(x: 50, y: (self.view.frame.maxY - (self.view.frame.maxY / 10)), width: self.view.frame.maxX - 100, height: 45)
            self.view.addSubview(button)
                button.addTarget(self, action: #selector(self.finishTapped), for: .touchUpInside)
                button.backgroundColor = UIColor.init(red: 21/250, green: 163/255, blue: 221/250, alpha: 1)
                button.layer.cornerRadius = 3.0
                button.tintColor = UIColor.white
            }
            
            Spinner.stop()
        }
    }
    
    @objc func finishTapped(_ sender: UIButton) {
        if OTMClient.Auth.objectId == "" {
        
            OTMClient.postStudentLocation(mapString: locationTextField.text!, mediaURL: linkTextField.text!, latitude: UserModel.user["latitude"]! as! Float, longitude: UserModel.user["longitude"]! as! Float) { (response, error) in
                
                if let error = error {
                    Alert.showAlert(viewController: self, title: "Alert", message: "We are sorry, but the location couldn't be posted. Please try again.", actionTitleOne: "OK", actionTitleTwo: nil, style: .default)
                }
                
                if let response = response {
                    OTMClient.Auth.objectId = response.objectId
                    self.dismiss(animated: true, completion: nil)

                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            OTMClient.putStudentLocation(mapString: locationTextField.text!, mediaURL: linkTextField.text!, latitude: UserModel.user["latitude"]! as! Float, longitude: UserModel.user["longitude"]! as! Float) { (response, error) in
                if response {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //:MARK - MKMapViewDelegate
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    
    
    
    
    //:MARK - Textfield delegates
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
        return true
    }
    


}
