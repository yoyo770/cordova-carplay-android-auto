 import Foundation
import UIKit
#if canImport(CarPlay)
import CarPlay
 
@available(iOS 12.0, *)
@objc(ToastyPlugin) class ToastyPlugin : CDVPlugin {
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
    
    
    
    
  @objc(show:)
  func show(command: CDVInvokedUrlCommand) {
   
    
   
    var pluginResult = CDVPluginResult(
      status: CDVCommandStatus_ERROR
    )

    let param = command.arguments[0] as AnyObject;
    
    var str:AnyObject?
    str = param["message"] as AnyObject?
    let msg = str as! String
    let template = CarPlayManager.shared.mapTemplate
    let buttons = template?.leadingNavigationBarButtons
    for btn in buttons! {
        btn.title = msg
    }
    template?.leadingNavigationBarButtons = buttons!
    
    
    
    if msg.count > 0 {
      let toastController: UIAlertController =
        UIAlertController(
          title: "",
          message: msg,
          preferredStyle: .alert
        )
        
      self.viewController?.present(
        toastController,
        animated: true,
        completion: nil
      )

      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        toastController.dismiss(
            animated: true,
            completion: nil
        )
      }
        
      pluginResult = CDVPluginResult(
        status: CDVCommandStatus_OK,
        messageAs: msg
      )
    }

    self.commandDelegate!.send(
      pluginResult,
      callbackId: command.callbackId
    )
    
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
