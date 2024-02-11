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
    @State private var breed: String = "pishka"
    @State private var age = 3
    @State private var sex: String = "♂︎"
    @State private var weight: Float = 20.5
    @State private var location: String = "Sofia, Bulgaria"
    @State private var showEdit: Bool = false
    
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
            // If sign out succeeds, navigate to the content view page
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: ContentView())
                window.makeKeyAndVisible()
            }
        } catch let error as NSError {
            print("Error signing out: \(error.localizedDescription)")
            // Handle the error appropriately, such as showing an alert to the user.
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
                    
                    Button("Fetch Data") {
                        fetchData { data, name, breed, age, sex, weight, location, error  in
                            if let error = error {
                                print("Error fetching data: \(error.localizedDescription)")
                            } else {
                                // Update properties with fetched data
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
                                // Handle other fetched data if needed
                            }
                        }
                    }
                    .padding([.leading, .trailing], 51)
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
        }
    }
}

#Preview {
    Profile()
}
