//
//  ProgressViewCustom.swift
//  MediStock
//
//  Created by Louise Ta on 02/01/2025.
//

import SwiftUI

struct ProgressViewCustom: View {
    var isLoading: Bool
    
    var body: some View {
        Group {
            if isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .padding()
                    .background(Color.secondary)
                    .tint(.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }
}

//#Preview {
//    ProgressViewCustom(isLoading: true)
//}
