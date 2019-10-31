//
//  Errors.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/06.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import Foundation


enum AuthenticationError: Error {
    case invalid(String)
    case missing(String)
    case success
    case failure(String)
}
