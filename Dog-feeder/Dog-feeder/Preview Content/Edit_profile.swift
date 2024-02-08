//
//  Edit_profile.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 8.02.24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct Edit_profile: View {
    @State private var name: String = ""
    @State private var bread: String = ""
    @State private var age: String = ""
    @State private var sex: String = ""
    @State private var weight: String = ""
    @State private var location: String = ""
    @State private var submit_message: String = ""
    @State private var submit_result: Bool = false

    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            
            VStack{
                Text("Edit your pet's info")
                    .bold()
                    .padding(.top, 120)
                    .font(.system(size: 40))
                
                Text(submit_message)
                    .opacity(submit_result ? 1 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 25)
                    .padding(.top, 10)
                    .padding(.bottom, -20)
                    .foregroundStyle(.red)
                
                Form {
                    Section(){
                        TextField("Name", text: $name)
                            .disableAutocorrection(true)
                        TextField("Bread", text: $bread)
                        TextField("Age", text: $age)
                        TextField("Sex", text: $sex)
                        TextField("Weight", text: $weight)
                        TextField("Location", text: $location)
                    }
                    
                    Button("Submit") {
                        submit_result = false
                        addData()
                        submit_result = true
                    }
                    .fixedSize()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    func addData() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated.")
            return
        }
        
        let uid = user.uid
        var petData = [String: Any]()
            
        // Add non-empty fields to petData
        if name != "" {
            petData["name"] = name
        }
        if bread != "" {
            petData["bread"] = bread
        }
        if age != "" {
            petData["age"] = age
        }
        if sex != "" {
            petData["sex"] = sex
        }
        if weight != "" {
            petData["weight"] = weight
        }
        if location != "" {
            petData["location"] = location
        }
        
        createOrUpdateDocument(collection: "pets-info", documentID: uid, data: petData) { error in
            if let error = error {
                submit_message = "Error updating data: \(error)"
            } else {
                submit_message = "Data updated successfully!"
            }
        }
    }
    
    func createOrUpdateDocument(collection: String, documentID: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection(collection).document(documentID)

        docRef.setData(data, merge: true) { error in
            if let error = error {
                submit_message = "Error writing document: \(error)"
                completion(error)
            } else {
                submit_message = "Document successfully written!"
                completion(nil)
            }
        }
    }
}

#Preview {
    Edit_profile()
}
