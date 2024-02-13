//
//  ContentView.swift
//  Smart-feeder
//
//  Created by Emiliana Petrenko on 16.11.23.
//

import SwiftUI

struct ContentView: View {
    @State private var showLogin: Bool = false
    @State private var showRegister: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea(.all)
                
                Image("Login-Register")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, 100)
                
                VStack {
                    Text("SnackBuddy")
                        .bold()
                        .padding(.top, 170)
                        .padding(.bottom, 20)
                        .font(.system(size: 56))
                    
                    Spacer()
                    
                    NavigationLink(destination: Login()) {
                        Text("Login")
                    }
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .background(Color("Buttons.Login-Register"))
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .padding(.bottom, 15)
                    .font(.system(size: 20))
                    
                    NavigationLink(destination: Register()) {
                        Text("Register")
                    }
                    .padding(.leading, 38)
                    .padding(.trailing, 38)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .background(Color("Buttons.Login-Register"))
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .padding(.bottom, 100)
                    .font(.system(size: 20))
                    
                    Spacer()
                }
            }
        }.tint(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            
            ContentView()
                .environment(\.colorScheme, .dark)
        }
    }
}
