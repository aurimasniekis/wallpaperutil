//
//  Screen.swift
//  WallpaperUtil
//
//  Created by Aurimas Niekis on 12/13/16.
//  Copyright © 2016 Aurimas Niekis. All rights reserved.
//

import Foundation
import AppKit


protocol NSScreenType {
    var displayName: String { get }
    var deviceDescription: [String : Any] { get }
    var deviceId: NSNumber { get }
}

extension NSScreen: NSScreenType {
    var deviceId: NSNumber {
        return self.deviceDescription["NSScreenNumber"] as! NSNumber
    }

    var displayName: String {
        guard let info = infoForCGDisplay(displayID: numberForScreen(nsScreen: self as NSScreen), options: kIODisplayOnlyPreferredName) else {
            return "Unknown screen"
        }
        
        guard let localizedNames = info[kDisplayProductName] as! [String:String]? as [String:String]?,
            let name           = localizedNames.values.first as NSString? as String? else {
                return "Unnamed screen"
        }
        
        return name
    }
}

private func numberForScreen<NSScreenT: NSScreenType>(nsScreen: NSScreenT) -> CGDirectDisplayID {
    let screenNumber = nsScreen.deviceDescription["NSScreenNumber"]!
    return CGDirectDisplayID((screenNumber as! NSNumber).intValue)
}

private func infoForCGDisplay(displayID: CGDirectDisplayID, options: Int) -> [String: AnyObject]? {
    var iter: io_iterator_t = 0
    
    let services = IOServiceMatching("IODisplayConnect")
    let err = IOServiceGetMatchingServices(kIOMasterPortDefault, services, &iter)
    guard err == KERN_SUCCESS else {
        print("Could not find services for IODisplayConnect, error code \(err)")
        return nil
    }
    
    var service: io_object_t;
    repeat {
        service = IOIteratorNext(iter);
        let info = IODisplayCreateInfoDictionary(service, IOOptionBits(options)).takeRetainedValue() as NSDictionary as! [String:AnyObject]
        
        guard let cfVendorID  = info[kDisplayVendorID] as! CFNumber?,
            let cfProductID = info[kDisplayProductID] as! CFNumber? else {
                print("Missing vendor or product ID encountered when looping through screens")
                continue
        }
        
        var vendorID: CFIndex = 0, productID: CFIndex = 0
        guard CFNumberGetValue(cfVendorID,  .cfIndexType, &vendorID) &&
            CFNumberGetValue(cfProductID, .cfIndexType, &productID) else {
                print("Unexpected failure unwrapping vendor or product ID while looping through screens")
                continue
        }
        
        if UInt32(vendorID) == CGDisplayVendorNumber(displayID) &&
            UInt32(productID) == CGDisplayModelNumber(displayID) {
            return info
        }
    } while service != 0;
    
    return nil
}
