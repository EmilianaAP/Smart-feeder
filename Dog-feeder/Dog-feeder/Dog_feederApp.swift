//
//  Dog_feederApp.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 16.11.23.
//

import SwiftUI
import FirebaseCore


@main
struct Dog_feederApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
