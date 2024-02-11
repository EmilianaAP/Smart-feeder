//
//  Profile.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 11.01.24.
//

import SwiftUI
import FirebaseAuth

struct Profile:View {
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var age = 0
    @State private var sex: String = ""
    @State private var weight: Float = 0.0
    @State private var location: String = ""
    @State private var showEdit: Bool = false
    @State private var showContent: Bool = false
    
    func logoutUser() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }

        let uid = currentUser.uid
        print("UID before signing out:", uid)

        do {
            try Auth.auth().signOut()
            print("User with UID \(uid) successfully signed out.")
            showContent = true
            
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
            
        }
    }
    
    func deleteProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        let uid = currentUser.uid
        
        deleteData()
        currentUser.delete { error in
          if let error = error {
            print("Error deleting profile")
          } else {
              print("User with UID \(uid) successfully deleted.")
              showContent = true
          }
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color("Background").ignoresSafeArea(.all)
                VStack{
                    Text(name + " (" + sex + ")")
                        .bold()
                        .font(.system(size: 36))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .padding(.top, 50)
                    
                    Text("📍" + location)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom], 10)
                    
                    HStack(spacing: 20) {
                        Text("Age: \n" + String(age) + " years")
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 20)
                            .padding([.top, .bottom], 40)
                            .background(Color("Buttons.Login-Register"))
                            .foregroundColor(.white)
                            .cornerRadius(22)
                        
                        Text("Bread: \n" + breed)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 20)
                            .padding([.top, .bottom], 40)
                            .background(Color("Buttons.Login-Register"))
                            .foregroundColor(.white)
                            .cornerRadius(22)
                        
                        Text("Weight: \n" + String(weight) + " kg")
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 20)
                            .padding([.top, .bottom], 40)
                            .background(Color("Buttons.Login-Register"))
                            .foregroundColor(.white)
                            .cornerRadius(22)
                    }
                    
                    Button("Edit profile") {
                        showEdit = true
                    }
                    .padding([.leading, .trailing], 38)
                    .padding([.top, .bottom], 5)
                    .background(Color("Buttons.Login-Register"))
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .padding(.top, 100)
                    .font(.system(size: 20))
                    
                    Button("Log out") {
                       logoutUser()
                    }
                    .padding([.leading, .trailing], 51)
                    .padding([.top, .bottom], 5)
                    .background(Color("Buttons.Login-Register"))
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .font(.system(size: 20))
                    .bold()
                    
                    Button("Delete profile") {
                        deleteProfile()
                    }
                    .padding([.leading, .trailing], 28)
                    .padding([.top, .bottom], 5)
                    .background(Color("Buttons.Login-Register"))
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .font(.system(size: 20))
                    .bold()
                }
            }
            .navigationDestination(isPresented: $showEdit) {
                Edit_profile()
            }
            .navigationDestination(isPresented: $showContent) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear{
                fetchData { data, name, breed, age, sex, weight, location, error  in
                    if let error = error {
                        print("Error fetching data: \(error.localizedDescription)")
                    } else {
                        if let name = name {
                            self.name = name
                        }
                        if let breed = breed {
                            self.breed = breed
                        }
                        if let age = age {
                            self.age = age
                        }
                        if let sex = sex {
                            self.sex = sex
                        }
                        if let weight = weight {
                            self.weight = weight
                        }
                        if let locaion = location {
                            self.location = location!
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Profile()
}
