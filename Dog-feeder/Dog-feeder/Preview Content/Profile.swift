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
    @State private var ageUnit: String = ""
    @State private var sex: String = ""
    @State private var weight: Float = 0.0
    @State private var weightUnit: String = ""
    @State private var location: String = ""
    @State private var showEdit: Bool = false
    @State private var showContent: Bool = false
    @State private var showAlert = false
    @State private var fetch_message: String = ""
    @State private var еxisting_profile: Bool = true
    
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
        
        deleteData(uid: uid)
        currentUser.delete { error in
            if error != nil {
            print("Error deleting profile")
          } else {
              print("User with UID \(uid) successfully deleted.")
              showContent = true
          }
        }
    }
    
    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            Text(fetch_message)
                .opacity(еxisting_profile ? 0 : 1)
                .padding(.bottom, 65)
                .padding([.leading, .trailing], 15)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .font(.system(size: 25))
            VStack{
                Text(name + " (" + sex + ")")
                    .opacity(еxisting_profile ? 1 : 0)
                    .bold()
                    .font(.system(size: 36))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                Text("📍" + location)
                    .opacity(еxisting_profile ? 1 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .bottom], 10)
                
                HStack(spacing: 20) {
                    Text("Age: \n" + String(age) + " " + ageUnit)
                        .opacity(еxisting_profile ? 1 : 0)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 20)
                        .padding([.top, .bottom], 40)
                        .background(Color("Buttons.Login-Register"))
                        .foregroundColor(.white)
                        .cornerRadius(22)
                        .opacity(еxisting_profile ? 1 : 0)
                    
                    Text("Breed: \n" + breed)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 20)
                        .padding([.top, .bottom], 40)
                        .background(Color("Buttons.Login-Register"))
                        .foregroundColor(.white)
                        .cornerRadius(22)
                        .opacity(еxisting_profile ? 1 : 0)
                    
                    Text("Weight: \n" + String(weight) + " " + weightUnit)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 20)
                        .padding([.top, .bottom], 40)
                        .background(Color("Buttons.Login-Register"))
                        .foregroundColor(.white)
                        .cornerRadius(22)
                        .opacity(еxisting_profile ? 1 : 0)
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
                    showAlert = true
                }
                .padding([.leading, .trailing], 28)
                .padding([.top, .bottom], 5)
                .background(Color("Buttons.Login-Register"))
                .foregroundColor(.white)
                .cornerRadius(22)
                .font(.system(size: 20))
                .bold()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteProfile()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
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
            fetchData { data, name, breed, age, ageUnit, sex, weight, weightUnit, location, error  in
                if let error = error {
                    fetch_message = "Oops! Pet Profile Missing :(" + "\n" + "Please go to the 'Edit profile' section to add the information."
                    еxisting_profile = false
                } else {
                    if let name = name {self.name = name}
                    if let breed = breed {self.breed = breed}
                    if let age = age {self.age = age}
                    if let ageUnit = ageUnit {self.ageUnit = ageUnit}
                    if let sex = sex {self.sex = sex}
                    if let weight = weight {self.weight = weight}
                    if let weightUnit = weightUnit {self.weightUnit = weightUnit}
                    if let location = location {self.location = location}
                }
            }
        }
    }
}

#Preview {
    Profile()
}
