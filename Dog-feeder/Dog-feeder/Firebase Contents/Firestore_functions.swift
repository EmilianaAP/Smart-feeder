//
//  Firestore_functions.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 8.02.24.
//

import FirebaseFirestore
import FirebaseAuth

func addData(name: String, breed: String, age: String, sex: String, weight: String, location: String, completion: @escaping (String) -> Void) {
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


func fetchData(completion: @escaping ([String: Any]?, Error?) -> Void) {
    guard let user = Auth.auth().currentUser else {
        print("User not authenticated.")
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        completion(nil, error)
        return
    }
    
    let uid = user.uid
    let db = Firestore.firestore()
    let docRef = db.collection("pets-info").document(uid)
    
    docRef.getDocument { document, error in
        if let error = error {
            print("Error fetching document: \(error.localizedDescription)")
            completion(nil, error)
        } else if let document = document, document.exists {
            let data = document.data()
            completion(data, nil)
        } else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
            print("Document does not exist")
            completion(nil, error)
        }
    }
}


