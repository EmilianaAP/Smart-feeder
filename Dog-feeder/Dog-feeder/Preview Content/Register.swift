//
//  Register.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 11.01.24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Register: View {
    @State private var showLogin = false
    @State private var first_name: String = ""
    @State private var last_name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var password_confirm: String = ""

    private func createUser() {
        Auth.auth().createUser(withEmail: email, password: password, completion: { result, err in
            if let err = err {
                print("Failed due to error:", err)
                return
            }
            print("Successfully created account with ID: \(result?.user.uid ?? "")")
            showLogin=true
        })
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color("Background").ignoresSafeArea(.all)
                VStack{
                    Text("Register")
                        .bold()
                        .padding(.top, 120)
                        .padding(.bottom, 10)
                        .font(.system(size: 40))
                    
                    Form {
                        Section(){
                            TextField("First name", text: $first_name)
                            TextField("Last name", text: $last_name)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                            SecureField("Confirm password", text: $password_confirm)
                        }
                        
                        Button("Submit") {
                            if(password == password_confirm){
                                createUser()
                            }else{
                            }
                            showLogin = false
                        }
                        .fixedSize()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
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


#Preview {
    Register()
}
