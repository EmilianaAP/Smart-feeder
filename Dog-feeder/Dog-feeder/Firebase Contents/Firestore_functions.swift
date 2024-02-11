//
//  Firestore_functions.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 8.02.24.
//

import FirebaseFirestore
import FirebaseAuth

func addData(name: String, breed: String, age: Int, sex: String, weight: Float, location: String, completion: @escaping (String) -> Void) {
    guard let user = Auth.auth().currentUser else {
        print("User not authenticated.")
        completion("User not authenticated.")
        return
    }
    
    let uid = user.uid
    var petData = [String: Any]()
    
    // Populate petData with non-empty fields
    if name != "" {
        petData["name"] = name
    }
    if breed != "" {
        petData["breed"] = breed
    }
    if age != 0 {
        petData["age"] = age
    }
    if sex != "" {
        petData["sex"] = sex
    }
    if weight != 0.0 {
        petData["weight"] = weight
    }
    if location != "" {
        petData["location"] = location
    }
    
    // Perform Firestore operation
    createOrUpdateDocument(collection: "pets-info", documentID: uid, data: petData) { error in
        if let error = error {
            completion("Error updating data: \(error.localizedDescription)")
        } else {
            completion("Data updated successfully!")
        }
    }
}


func createOrUpdateDocument(collection: String, documentID: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
    let db = Firestore.firestore()
    let docRef = db.collection(collection).document(documentID)

    docRef.setData(data, merge: true) { error in
        if let error = error {
            print("Error writing document: \(error)")
            completion(error)
        } else {
                print("Document successfully written!")
            completion(nil)
        }
    }
}


func fetchData(completion: @escaping ([String: Any]?, String?, String?, Int?, String?, Float?, String?, Error?) -> Void) {
    guard let user = Auth.auth().currentUser else {
        print("User not authenticated.")
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        completion(nil, nil, nil, nil, nil, nil, nil, error)
        return
    }
    
    let uid = user.uid
    let db = Firestore.firestore()
    let docRef = db.collection("pets-info").document(uid)
    
    docRef.getDocument { document, error in
        if let error = error {
            print("Error fetching document: \(error.localizedDescription)")
            completion(nil, nil, nil, nil, nil, nil, nil, error)
        } else if let document = document, document.exists {
            let data = document.data()
            
            // Extract the "name" field from the fetched data
            if let name = data?["name"] as? String,
               let breed = data?["breed"] as? String,
               let age = data?["age"] as? Int,
               let sex = data?["sex"] as? String,
               let weight = data?["weight"] as? Float,
               let location = data?["location"] as? String{
                // Call the completion handler with the fetched data, name, and nil error
                completion(data, name, breed, age, sex, weight, location, nil)
            } else {
                // If the "name" field does not exist or its value cannot be cast to a String, handle the error or set a default value
                print("Error: 'name' field not found or has invalid type.")
                completion(nil, nil, nil, nil, nil, nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Name field not found"]))
            }
        } else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
            print("Document does not exist")
            completion(nil, nil, nil, nil, nil, nil, nil, error)
        }
    }
}

func deleteData() {
    print("here")
    guard let currentUser = Auth.auth().currentUser else {
        print("No user is currently signed in.")
        return
    }
    let uid = currentUser.uid
    let db = Firestore.firestore()
    let docRef = db.collection("pets-info").document(uid)
    
    docRef.delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        }
        else {
            print("Document successfully removed!")
        }
    }
}


