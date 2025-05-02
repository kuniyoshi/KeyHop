//
//  ApplicationModel.swift
//  KeyHop
//
//  Created by Devin AI on 2025-05-02.
//

import Foundation
import SwiftData

@Model
final class ApplicationModel {
    var applicationPath: String
    var keybindings: String
    
    init(applicationPath: String, keybindings: String) {
        self.applicationPath = applicationPath
        self.keybindings = keybindings
    }
}
