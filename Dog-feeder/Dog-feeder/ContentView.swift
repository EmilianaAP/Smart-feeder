//
//  ContentView.swift
//  Smart-feeder
//
//  Created by Emiliana Petrenko on 16.11.23.
//

import SwiftUI

struct ContentView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    var body: some View {
        NavigationStack {
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
                    
                    Button("Login") {
                        print("Login tapped!")
                        showLogin = true
                    }
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .background(Color(#colorLiteral(red: 0.5722110271, green: 0.6789935231, blue: 0.4731182456, alpha: 1)))
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .padding(.bottom, 15)
                    .font(.system(size: 20))
                    
                    Button("Register") {
                        print("Register tapped!")
                        showRegister = true
                    }
                    .padding(.leading, 38)
                    .padding(.trailing, 38)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .background(Color(#colorLiteral(red: 0.5722110271, green: 0.6789935231, blue: 0.4731182456, alpha: 1)))
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .padding(.bottom, 100)
                    .font(.system(size: 20))
                    
                    Spacer()
                }
                
                .navigationDestination(
                     isPresented: $showLogin) {
                          Login()
                     }
                .navigationDestination(
                     isPresented: $showRegister) {
                          Register()
                     }
            }
        }
    }
    
}

struct Login: View {
@State private var username: String = ""
@State private var password: String = ""
@State private var authorization: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color("Background").ignoresSafeArea(.all)
                VStack{
                    Text("Login")
                        .bold()
                        .padding(.top, 120)
                        .padding(.bottom, 10)
                    
                    Form {
                        Section(){
                            TextField(text: $username, prompt: Text("Username")) {
                                Text("Email")
                            }
                            SecureField(text: $password, prompt: Text("Password")) {
                                Text("Password")
                            }
                        }
                        
                        Button("Login") {
                            authorization = true                    }
                        .fixedSize()
                        .foregroundColor(Color("Pink"))
                        
                    }
                        .scrollContentBackground(.hidden)
                    
                    .navigationDestination(
                        isPresented: $authorization) {
                            Main()
                                .navigationBarBackButtonHidden(true)
                        }
                }
            }
        }
    }
}

struct Register: View {
@State private var showLogin = false
@State private var username: String = ""
@State private var email: String = ""
@State private var password: String = ""
@State private var password_confirm: String = ""

    
    var body: some View {
        NavigationStack{
            ZStack{
                Color("Background").ignoresSafeArea(.all)
                VStack{
                    Text("Register")
                        .font(.custom(
                            "Bold",
                            fixedSize: 36))
                        .bold()
                        .padding(.top, 120)
                        .padding(.bottom, 10)
                    
                    Form {
                        Section(){
                            TextField(text: $username, prompt:
                                        Text("Username")) {
                                Text("Username")
                            }
                            TextField(text: $email, prompt:
                                        Text("Email")) {
                                Text("Email")
                            }
                            SecureField(text: $password, prompt:
                                            Text("Password")) {
                                Text("Password")
                            }
                            SecureField(text: $password_confirm, prompt:
                                            Text("Confirm password")) {
                                Text("Confirm password")
                            }
                        }
                        
                        Button("Submit") {
                            showLogin = true
                        }
                        .fixedSize()
                        .foregroundColor(Color("Pink"))
                        
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationDestination(
                    isPresented: $showLogin) {
                        Login()
                    }
            }
        }
    }
}

struct Main:View {
    var width: CGFloat = 200
    var height: CGFloat = 20
    var percentage_food: CGFloat = 60
    var percentage_water: CGFloat = 100
    var color1 = Color(#colorLiteral(red: 0.8560530543, green: 0.4147394896, blue: 0.4633637071, alpha: 1))
    var color2 = Color(#colorLiteral(red: 0.8743290305, green: 0, blue: 0.05853315443, alpha: 1))
    
    var body: some View {
        let multiplier = width / 100
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            VStack{
                ZStack(alignment: .leading){
                    RoundedRectangle(cornerRadius: height, style: .continuous)
                        .frame (width: width, height: height)
                        .foregroundColor (Color.black.opacity(0.1) )
                    
                    RoundedRectangle(cornerRadius: height, style: .continuous)
                        .frame (width: percentage_food * multiplier, height: height)
                        .background (
                            LinearGradient (gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing)
                                .clipShape (RoundedRectangle (cornerRadius: height, style: .continuous))
                        )
                        .foregroundColor(.clear)
                }
                .padding(.bottom, 20)
                ZStack(alignment: .leading){
                    RoundedRectangle(cornerRadius: height, style: .continuous)
                        .frame (width: width, height: height)
                        .foregroundColor (Color.black.opacity(0.1) )
                    
                    RoundedRectangle(cornerRadius: height, style: .continuous)
                        .frame (width: percentage_water * multiplier, height: height)
                        .background (
                            LinearGradient (gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing)
                                .clipShape(RoundedRectangle (cornerRadius: height, style: .continuous))
                        )
                        .foregroundColor(.clear)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
