/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MapKit
import YelpAPI

public class ViewController: UIViewController {
  
  // MARK: - Properties
  private var filter = Filter.identity()
  public let annotationFactory = AnnotationFactory()
  public var businesses: [Business] = []
  public var client: BusinessSearchClient = YLPClient(apiKey: YelpAPIKey)
  private let locationManager = CLLocationManager()
  
  // MARK: - Outlets
  @IBOutlet public var mapView: MKMapView! {
    didSet {
      mapView.showsUserLocation = true
    }
  }
  
  // MARK: - View Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.requestWhenInUseAuthorization()
  }
  
  // MARK: - Actions
  @IBAction func businessFilterToggleChanged(_ sender: UISwitch) {
    if sender.isOn {
      // 1
      filter = Filter.starRating(atLeast: 4.0)
    } else {
      // 2
      filter = Filter.identity()
    }
    // 3
    filter.businesses = businesses

    // 4
    addAnnotations()
    
  }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
  
  public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    centerMap(on: userLocation.coordinate)
  }
  
  private func centerMap(on coordinate: CLLocationCoordinate2D) {
    let regionRadius: CLLocationDistance = 3000
    let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                              latitudinalMeters: regionRadius,
                                              longitudinalMeters: regionRadius)
    mapView.setRegion(coordinateRegion, animated: true)
    searchForBusinesses()
  }
  
  private func searchForBusinesses() {
    // 1
    client.search(
      with: mapView.userLocation.coordinate,
      term: "coffee",
      limit: 35, offset: 0,
      success: { [weak self] businesses in
        guard let self = self else { return }
        
        // 2
        self.businesses = businesses
        self.filter.businesses = businesses
        DispatchQueue.main.async {
          self.addAnnotations()
        }
      }, failure: { error in
        
        // 3
        print("Search failed: \(String(describing: error))")
      })
    
  }
  
  private func addAnnotations() {
    // 1
    mapView.removeAnnotations(mapView.annotations)

    // 2
    for business in filter {

      // 3
      let viewModel =
        annotationFactory.createBusinessMapViewModel(for: business)
      mapView.addAnnotation(viewModel)
    }

  }
  
  
  public func mapView(_ mapView: MKMapView,
                      viewFor annotation: MKAnnotation)
  -> MKAnnotationView? {
    guard let viewModel =
            annotation as? BusinessMapViewModel else {
      return nil
    }
    
    let identifier = "business"
    let annotationView: MKAnnotationView
    
    if let existingView = mapView.dequeueReusableAnnotationView(
      withIdentifier: identifier) {
      annotationView = existingView
    } else {
      annotationView = MKAnnotationView(
        annotation: viewModel,
        reuseIdentifier: identifier)
    }
    
    annotationView.image = viewModel.image
    annotationView.canShowCallout = true
    return annotationView
  }
  
  
}
