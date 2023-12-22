//
//  ActivityIndicatorView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/22/23.
//

import Foundation
import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .medium)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
    }
}
