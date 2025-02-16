//
//  ContentView.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            HealthFormView(shouldShowOptions: false, onShouldShowOptionsChange: { _ in }, onSubmit: { _ in })
        }
    }
}
