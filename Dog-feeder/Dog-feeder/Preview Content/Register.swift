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
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var password_confirm: String = ""
    @State private var register_error: Bool = false
    @State private var error_message: String = ""

     private func createUser() {
         Auth.auth().createUser(withEmail: email, password: password, completion: { result, err in
             if let err = err {
                 print("Failed due to error:", err)
                 error_message = err.localizedDescription
                register_error = true
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

                     Text(error_message)
                         .opacity(register_error ? 1 : 0)
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
                             SecureField("Confirm password", text: $password_confirm)
                         }

                         Button("Submit") {
                             if(password == password_confirm){
                                 createUser()
                             }else{
                                 error_message = "Passwords does not match"
                                 register_error = true
                             }
                             showLogin = false
                         }
                         .fixedSize()
                         .foregroundColor(Color("Text"))
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
