//
//  GeneralHelper.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 02/06/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import SwiftyBeaver

let log = SwiftyBeaver.self

public struct GeneralHelper {
    
    //    #if DEBUG
    static func log(message: String, filename: String = #file, line: Int = #line, function: String = #function) {
        Swift.print("\((filename as NSString).lastPathComponent):\(line) \(function):\r\(message)")
    }
    //    #endif
    
    private init(){}
    
}
