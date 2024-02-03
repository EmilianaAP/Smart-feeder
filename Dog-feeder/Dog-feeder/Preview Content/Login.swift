//
//  Login.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 11.01.24.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct Login: View {
    @State private var ID = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var authorization: Bool = false
    @State private var login_error: Bool = false
    @State private var error_message: String = ""

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed due to error:", err)
                error_message = err.localizedDescription
                login_error = true
                return
            }
            print("Successfully logged in with ID: \(result?.user.uid ?? "")")
            ID = (result?.user.uid ?? "")
            authorization=true
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color("Background").ignoresSafeArea(.all)
                VStack{
                    Text("Login")
                        .bold()
                        .padding(.top, 120)
                        .padding(.bottom, 10)
                        .font(.system(size: 40))
                    
                    Text(error_message)
                        .opacity(login_error ? 1 : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .top], 25)
                        .padding(.bottom, -20)
                        .foregroundStyle(.red)
                    
                    Form {
                        Section(){
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                        }
                        
                        Button("Login") {
                            loginUser()
                        }
                        .fixedSize()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        
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


#Preview {
    Login()
}
