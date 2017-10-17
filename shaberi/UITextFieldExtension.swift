//
//  UITextFieldExtension.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/06.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit

class TextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
