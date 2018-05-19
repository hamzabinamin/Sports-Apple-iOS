//
//  Extensions.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/19/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
