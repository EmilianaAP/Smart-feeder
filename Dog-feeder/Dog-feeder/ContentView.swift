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
        NavigationStack{
            ZStack {
                Color("Background").ignoresSafeArea(.all)
                
                VStack {
                    Text("SnackBuddy")
                        .padding(.top, 170)
                        .bold()
                        .font(.system(size: 56))
                    
                    Image("Login-Register")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 30)
                    
                    Button("Login") {
                        showLogin = true
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
                    
                    Button("Register") {
                        showRegister = true
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
                
                .navigationDestination(isPresented: $showLogin) {
                    Login()
                }
                .navigationDestination(isPresented: $showRegister) {
                    Register()
                }
            }
        }.tint(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
