//
//  SplashView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/12/24.
//

import SwiftUI

let appGradient = LinearGradient(gradient: Gradient(colors: [.pink, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing) // AngularGradient(gradient: Gradient(colors: [.pink, .indigo]), center: .center, angle: .degrees(-30))

struct SplashView: View {
    var body: some View {
        VStack {
            Image(systemName: "hexagon.fill")
                .font(.system(size: 200))
                .foregroundStyle(appGradient)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.19, green: 0.2, blue: 0.21))
    }
}

#Preview {
    SplashView()
}
