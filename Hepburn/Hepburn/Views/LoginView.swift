//
//  ContentView.swift
//  Hepburn
//
//  Created by HyeonTae Cho on 2021/01/22.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Hepburn")
                    .font(.title)
                Text("2021")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                NavigationLink(destination: MainView().environmentObject(Preferences())) {
                    Text("Login")
                }
            }
            .navigationTitle("App Name")
            .padding()
        }
    }
}

struct LgoinView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
