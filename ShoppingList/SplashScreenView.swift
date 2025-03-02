//
//  SplashScreenView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("🛒 Shopping List App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("By Team 55")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
