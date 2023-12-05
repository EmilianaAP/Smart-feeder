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
                Image("Login-Register")
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
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

#Preview {
    ContentView()
}
