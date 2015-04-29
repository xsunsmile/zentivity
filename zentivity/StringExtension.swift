//
//  StringExtension.swift
//  zentivity
//
//  Created by Hao Sun on 3/27/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

extension String {
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    func truncate(length: Int, trailing: String? = nil) -> String {
        if count(self) > length {
            return self.substringToIndex(advance(self.startIndex, length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}
