import Foundation

@objc(ToastyPlugin) class ToastyPlugin : CDVPlugin {
  @objc(show:)
  func show(command: CDVInvokedUrlCommand) {

    var pluginResult = CDVPluginResult(
      status: CDVCommandStatus_ERROR
    )

    let param = command.arguments[0] as AnyObject;
    
    var str:AnyObject?
    str = param["message"] as AnyObject?
    var msg = str as! String
  
    if msg.characters.count > 0 {
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
