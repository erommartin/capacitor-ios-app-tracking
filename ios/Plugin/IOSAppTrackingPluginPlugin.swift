import Foundation
import Capacitor
import AppTrackingTransparency
import AdSupport
/**
 * Please  read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(IOSAppTracking)
public class IOSAppTrackingPluginPlugin: CAPPlugin {

    @objc func getTrackingStatus(_ call: CAPPluginCall) {
        let advertising = ASIdentifierManager.init().advertisingIdentifier.uuidString
        if #available(iOS 14.0, *) {
            let status: ATTrackingManager.AuthorizationStatus = ATTrackingManager.trackingAuthorizationStatus
            call.resolve([
                "value": advertising, "status": status.rawValue == 0 ? "unrequested" : status.rawValue == 1 ? "restricted" : status.rawValue == 2 ? "denied" : status.rawValue == 3 ? "authorized" : ""
            ])
        } 
        else {
            call.resolve([ "value": advertising, "status": "authorized" ])
        }
    }

    @objc func requestPermission(_ call: CAPPluginCall) {
        if #available(iOS 14.0, *) {
            Task {
                do {
                    let status = await ATTrackingManager.requestTrackingAuthorization()
                    if status == .denied, ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                        debugPrint("iOS 17.4 ATT bug detected")
                        for await _ in await NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                            requestPermission(call)
                        }
                    } else {
                        let advertising = ASIdentifierManager.init().advertisingIdentifier.uuidString
                        call.resolve([
                            "value": advertising, "status": status.rawValue == 0 ? "unrequested" : status.rawValue == 1 ? "restricted" : status.rawValue == 2 ? "denied" : status.rawValue == 3 ? "authorized" : ""
                        ])
                    }
                } catch {
                    print(error)
                }
            }
        } 
        else {
            let advertising = ASIdentifierManager.init().advertisingIdentifier.uuidString
            call.resolve([ "value": advertising, "status": "authorized" ])
        }
     }

}



