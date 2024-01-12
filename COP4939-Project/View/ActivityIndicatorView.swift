//
//  ActivityIndicatorView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/22/23.
//

import Foundation
import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    let color: Color
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        
        view.color = UIColor(color)
        
        return view

    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
    }
}
