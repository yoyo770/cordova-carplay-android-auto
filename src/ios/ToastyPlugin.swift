 import Foundation
import UIKit
 import Mapbox
 import MapboxCoreNavigation
 import MapboxNavigation
 import MapboxDirections
#if canImport(CarPlay)
import CarPlay
 
@available(iOS 12.0, *)
@objc(ToastyPlugin) class ToastyPlugin : CDVPlugin {
    
    var mapVC: ViewController?
    var navVC: NavigationViewController?
    lazy var barBtn: CPBarButton = {
        let barButton = CPBarButton(type: .text) { [weak self] (button: CPBarButton) in
            guard let strongSelf = self else {
                return
            }
            
            // TODO : Action
            
        }
        
        barButton.title = "test"
        return barButton
    }()
    
    override func pluginInitialize() {
        super.pluginInitialize()
        NotificationCenter.default.addObserver(self, selector: #selector(pageDidLoad), name: NSNotification.Name.CDVPageDidLoad, object: nil)
        
    }
    
    @objc func pageDidLoad() {
        self.webView?.isOpaque = false
        self.webView?.backgroundColor = UIColor.clear
    }
    
  @objc(show:)
  func show(command: CDVInvokedUrlCommand) {
   
//    let vc = ViewController()
//    self.mapVC = vc
    
    // Calculate the route from the user's location to the set destination
    self.calculateRoute(from: CLLocationCoordinate2D.init(latitude: 48.8885911, longitude: 2.165825), to: CLLocationCoordinate2D.init(latitude: 43.9783, longitude: 4.9039)) { (route, error) in
        if error != nil {
            print("Error calculating route")
        }
    }
    
//    let myView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//    myView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    //self.webView.superview?.insertSubview(myView, aboveSubview: self.webView)
    //self.webView.superview?.insertSubview(self.mapVC!.view, belowSubview: self.webView)
    
    
  }
    
    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        
        // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        
        // Specify that the route is intended for automobiles avoiding traffic
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        // Generate the route object and draw it on the map
        _ = Directions.shared.calculate(options) { [weak self] (waypoints, routes, error) in
            
            guard let strongSelf = self else {
                return
            }
            
            if let directionsRoute = routes?.first {
                strongSelf.navVC = NavigationViewController(for: directionsRoute)
                strongSelf.webView.superview?.insertSubview((strongSelf.navVC?.view)!, belowSubview: strongSelf.webView)
            }
        }
    }
}

@available(iOS 12.0, *)
extension CDVAppDelegate : CPApplicationDelegate {
    public func application(_ application: UIApplication, didConnectCarInterfaceController interfaceController: CPInterfaceController, to window: CPWindow) {
        CarPlayManager.shared.application(application, didConnectCarInterfaceController: interfaceController, to: window)
    }
    
    public func application(_ application: UIApplication, didDisconnectCarInterfaceController interfaceController: CPInterfaceController, from window: CPWindow) {
        CarPlayManager.shared.application(application, didDisconnectCarInterfaceController: interfaceController, from: window)
    }
    
}

@available(iOS 12.0, *)
public class CarPlayManager : NSObject {
    
    static let shared = CarPlayManager()
    var interfaceController: CPInterfaceController?
    var carWindow: CPWindow?
    var mapTemplate: CPMapTemplate?
}

@available(iOS 12.0, *)
extension CarPlayManager: CPApplicationDelegate {
    
    public func application(_ application: UIApplication, didConnectCarInterfaceController interfaceController: CPInterfaceController, to window: CPWindow) {
        print("CP did connect")
        
        print("[CARPLAY] CONNECTED TO CARPLAY!")

        // Keep references to the CPInterfaceController (handles your templates) and the CPMapContentWindow (to draw/load your own ViewController's with a navigation map onto)
        self.interfaceController = interfaceController
        self.carWindow = window

        print("[CARPLAY] CREATING CPMapTemplate...")

        let mapTemplate = createTemplate()
        
        self.mapTemplate = mapTemplate
        
        interfaceController.setRootTemplate(mapTemplate, animated: true)
        
        
        // Note: Obviously the AppDelegate is a bad place to handle everything and save all your references. This is done for example, don't put everything in the same class 🙃
    }
    
    public func application(_ application: UIApplication, didDisconnectCarInterfaceController interfaceController: CPInterfaceController, from window: CPWindow) {
        print("CP did diconnect")
    }
    
    // MARK: - CPMapTemplate creation
    private func createTemplate() -> CPMapTemplate {
        // Create the default CPMapTemplate objcet (you may subclass this at your leasure)
        let mapTemplate = CPMapTemplate()
        
        var map = ToastyPlugin()
        
        // Create the different CPBarButtons
        let searchBarButton = createBarButton(.search)
        mapTemplate.leadingNavigationBarButtons = [map.barBtn]
        
        let panningBarButton = createBarButton(.panning)
        mapTemplate.trailingNavigationBarButtons = [panningBarButton]
        
        // Always show the NavigationBar
        mapTemplate.automaticallyHidesNavigationBar = false
        
        return mapTemplate
    }
    
    // MARK: - CPBarButton creation
    enum BarButtonType: String {
        case search = "Search"
        case panning = "Pan map"
        case dismiss = "Dismiss"
    }
    
    private func createBarButton(_ type: BarButtonType) -> CPBarButton {
        let barButton = CPBarButton(type: .text) { (button) in
            print("[CARPLAY] SEARCH MAP TEMPLATE \(button.title ?? "-") TAPPED")
            
            switch(type) {
            case.dismiss:
                // Dismiss the map panning interface
                self.mapTemplate?.dismissPanningInterface(animated: true)
            case .panning:
                // Enable the map panning interface and set the dismiss button
                self.mapTemplate?.showPanningInterface(animated: true)
                self.mapTemplate?.trailingNavigationBarButtons = [self.createBarButton(.dismiss)]
            default:
                break
            }
        }
        
        // Set title based on type
        barButton.title = type.rawValue
        
        return barButton
    }
}

#endif
