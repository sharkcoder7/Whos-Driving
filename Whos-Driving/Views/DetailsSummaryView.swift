import CoreLocation
import MapKit
import UIKit

/// Protocol with methods for responding to different events in the DetailsSummaryView.
protocol DetailsSummaryViewDelegate: class {
    
    /**
     Called when the edit button is tapped in the detail summary view.
     
     - parameter detailsSummaryView The DetailsSummaryView sending this message.
     */
    func detailsSummaryViewEditButtonTapped(detailsSummaryView: DetailsSummaryView)
    
    /**
     Called when the event location label is tapped in the DetailsSummaryView.
     
     - parameter detailsSummaryView The DetailsSummaryView sending this message.
     */
    func detailsSummaryViewLocationTapped(detailsSummaryView: DetailsSummaryView)
    
    /**
     Called when the map view is tapped in the DetailsSummaryView.
     
     - parameter detailsSummaryView The DetailsSummaryView sending this message.
     */
    func detailsSummaryViewMapViewTapped(detailsSummaryView: DetailsSummaryView)
}

/// View for displaying the summary of an event, such as the title, date, and location.
class DetailsSummaryView: DetailsBaseView {
    
    // MARK: Constants
    
    /// Animation duration for hiding/showing the map view.
    private let mapViewAnimationDuration = 0.3
    
    /// Default region distance of the map view.
    private let mapViewDefaultRegionDistance = 900 as CLLocationDistance
    
    /// The height to expand the map to when shown.
    private let mapViewExpandedHeight = 110.0 as CGFloat
    
    // MARK: Public properties
    
    /// Delegate of this class.
    weak var detailsSummaryViewDelegate: DetailsSummaryViewDelegate?
    
    /// The event being shown in this view.
    var event: Event?
    
    // MARK: Private Properties
    
    /// CLLocationManager used for determining the user's location.
    private let locationManager = CLLocationManager()
    
    /// The view model of this class.
    private var viewModel: DetailsSummaryViewModel?
    
    // MARK: IBOutlets
    
    /// The label showing the date of the event.
    @IBOutlet private weak var dateLabel: UILabel!
    
    /// The divider line at the bottom of the view.
    @IBOutlet private weak var dividerLine: UIView!
    
    /// Height constraint for the dividerLine.
    @IBOutlet private weak var dividerLineHeight: NSLayoutConstraint!
    
    /// The label showing the location of the event.
    @IBOutlet private weak var locationLabel: UILabel!
    
    /// Container view for the mapView and other views.
    @IBOutlet private weak var mapContainerView: UIView!
    
    /// Height constraint for the mapContainerView.
    @IBOutlet private weak var mapContainerViewHeightConstraint: NSLayoutConstraint!
    
    /// Disclaimer label in the corner of the mapView.
    @IBOutlet private weak var mapDisclaimerLabel: UILabel!
    
    /// The mapView showing the pin of location of the event.
    @IBOutlet private weak var mapView: MKMapView!
    
    /// The label showing the title of the event.
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: Instance Methods
    
    /**
    Configures the UI of the view for the provided event.
    
    - parameter anEvent The event used to configure the view.
    */
    func populateView(anEvent: Event) {
        event = anEvent
        viewModel = DetailsSummaryViewModel(event: anEvent)
        dateLabel.attributedText = viewModel?.attributedDateTimeStringOfSize(13.0)
        titleLabel.text = viewModel?.titleString()
        coloredEdgeView.driverStatus = anEvent.driverStatus
        locationLabel.attributedText = viewModel?.attributedLocationString()
        
        // Uncomment this to re-enable the map view.
//        handleLocationAuthorizationStatus()
    }
    
    // MARK: Actions
    
    /**
    Called when the edit button is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction private func editButtonTapped(sender: UIButton) {
        detailsSummaryViewDelegate?.detailsSummaryViewEditButtonTapped(self)
    }
    
    /**
     Called when the location label is tapped.
     */
    @objc private func locationLabelTapped() {
        detailsSummaryViewDelegate?.detailsSummaryViewLocationTapped(self)
    }
    
    /**
     Called when the map view is tapped.
     */
    @objc private func mapViewTapped() {
        detailsSummaryViewDelegate?.detailsSummaryViewMapViewTapped(self)
    }
    
    // MARK: Private Methods
    
    /**
    Geocodes the locationString of the provided DetailsSummaryViewModel. If a match is found for the
    location a pin is placed on the map and the map view is shown. Otherwise the map view is hidden.
    
    - parameter viewModel The view model that provides the location of the event.
    */
    private func geocodeAddress(viewModel: DetailsSummaryViewModel?) {
        if let viewModel = viewModel {
            let addressString = viewModel.locationString()
            
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = addressString
            
            if let location = locationManager.location {
                let span = MKCoordinateSpanMake(1, 1)
                let region = MKCoordinateRegionMake(location.coordinate, span)
                searchRequest.region = region
            }

            let mapSearch = MKLocalSearch(request: searchRequest)
            mapSearch.startWithCompletionHandler { [weak self] (response, error) -> Void in
                guard let strongSelf = self else {
                    return
                }
                
                if error != nil {
                    dLog("\(error)")
                    strongSelf.hideMapView(animated: true)
                    return
                }
                
                if (response == nil) {
                    strongSelf.hideMapView(animated: true)
                    return
                }
                
                strongSelf.showMapView(animated: true)
                
                for mapItem in response!.mapItems {
                    let placemark = mapItem.placemark
                    let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, strongSelf.mapViewDefaultRegionDistance, strongSelf.mapViewDefaultRegionDistance)
                    strongSelf.mapView.removeAnnotations(strongSelf.mapView.annotations)
                    strongSelf.mapView.addAnnotation(placemark)
                    strongSelf.mapView.region = region
                    
                    return
                }
            }
        }
    }
    
    /**
     Configures the view for the current value of CLLocationManager.authorizationStatus().
     */
    private func handleLocationAuthorizationStatus() {
        switch (CLLocationManager.authorizationStatus()) {
        case CLAuthorizationStatus.AuthorizedAlways, CLAuthorizationStatus.AuthorizedWhenInUse:
            geocodeAddress(viewModel)
        case CLAuthorizationStatus.NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            hideMapView(animated: false)
        case CLAuthorizationStatus.Denied, CLAuthorizationStatus.Restricted:
            hideMapView(animated: true)
        }
    }
    
    /**
     Hides the map view, optionally animated.
     
     - parameter animated If true, the hiding of the view will be animated.
     */
    private func hideMapView(animated animated: Bool) {
        let animationDuration = (animated == true) ? mapViewAnimationDuration : 0.0
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.mapContainerViewHeightConstraint.constant = 0
            self.delegate?.detailsViewRequestsLayout(self, duration: animationDuration)
        })
    }
    
    /**
     Shows the map view, optionally animated.
     
     - parameter animated If true, the showing of the map view will be animated.
     */
    private func showMapView(animated animated: Bool) {
        let animationDuration = (animated == true) ? mapViewAnimationDuration : 0.0
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.mapContainerViewHeightConstraint.constant = self.mapViewExpandedHeight
            self.delegate?.detailsViewRequestsLayout(self, duration: animationDuration)
        })
    }
    
    // MARK: DetailsBaseView Methods
    
    override func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "DetailsSummaryView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: UIView Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dividerLine.backgroundColor = AppConfiguration.lightGray()
        dividerLineHeight.constant = coloredEdgeView.borderWidth
        
        // Uncomment this to re-enable the map view.
//        locationManager.delegate = self
        
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        mapContainerView.addGestureRecognizer(tapHandler)
        mapView.userInteractionEnabled = false
        
        let locationTapHandler = UITapGestureRecognizer(target: self, action: #selector(locationLabelTapped))
        locationLabel.addGestureRecognizer(locationTapHandler)
        
        hideMapView(animated: false)
    }
}

// MARK: CLLocationManagerDelegate Methods

extension DetailsSummaryView : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus()
    }
}

// MARK: MKMapViewDelegate methods

extension DetailsSummaryView : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.image = UIImage(named: "map-pin")
        
        return annotationView
    }
}
