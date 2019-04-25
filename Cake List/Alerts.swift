//
//  Alerts.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.
//  Copyright © 2019 Stewart Hart. All rights reserved.
//

import Foundation
import UIKit

struct Alerts {
    // a temporary function to present unexpected errors
    static func alert(with error: Error) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Something went wrong", comment: "Something went wrong"), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
        return alert
    }
}
