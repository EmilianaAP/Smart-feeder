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
                    .padding(.bottom, 250)
                    .padding(.top, 60)
                VStack {
                    Text("SnackBuddy")
                        .font(.custom(
                                "Baskerville-BoldItalic",
                                fixedSize: 36))
                        .bold()
                        .padding(.top, 80)
                        .padding(.bottom, 10)
                    
                    Button("Login") {
                        print("Login tapped!")
                        showLogin = true
                    }
                    .padding(.bottom, 5)
                    .fixedSize()
                    .foregroundColor(Color("Pink"))
                    
                    Button("Register") {
                        print("Register tapped!")
                        showRegister = true
                    }
                    .fixedSize()
                    .foregroundColor(Color("Pink"))
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
            VStack{
                
                Text("Login")
                    .font(.custom(
                        "Baskerville-BoldItalic",
                        fixedSize: 36))
                    .bold()
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                Form {
                    TextField(text: $username, prompt: Text("Username")) {
                        Text("Username")
                    }
                    SecureField(text: $password, prompt: Text("Password")) {
                        Text("Password")
                    }
                    
                    Button("Login") {
                        authorization = true                    }
                    .fixedSize()
                    .foregroundColor(Color("Pink"))
                    
                }
                
                .navigationDestination(
                     isPresented: $authorization) {
                         Main()
                             .navigationBarBackButtonHidden(true)
                     }
            }
        }
    }
}

struct Register: View {
@State private var username: String = ""
@State private var email: String = ""
@State private var password: String = ""
@State private var password_confirm: String = ""

    
    var body: some View {
        VStack{
            Text("Register")
                .font(.custom(
                        "Baskerville-BoldItalic",
                        fixedSize: 36))
                .bold()
                .padding(.bottom, 10)
            
            Form {
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
                
                Button("Submit") {
                    // register!
                }
                .fixedSize()
                .foregroundColor(Color("Pink"))
                
            }
        }
    }
}

struct Main:View {
    var width: CGFloat = 200
    var height: CGFloat = 20
    var percentage_food: CGFloat = 60
    var percentage_water: CGFloat = 70
    var color1 = Color(#colorLiteral(red: 0.8560530543, green: 0.4147394896, blue: 0.4633637071, alpha: 1))
    var color2 = Color(#colorLiteral(red: 0.8743290305, green: 0, blue: 0.05853315443, alpha: 1))
    
    var body: some View {
        let multiplier = width / 100
        
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

#Preview {
    ContentView()
}
