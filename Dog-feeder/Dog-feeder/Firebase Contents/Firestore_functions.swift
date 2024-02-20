//
//  Firestore_functions.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 8.02.24.
//

import FirebaseFirestore
import FirebaseAuth

func addData(name: String, breed: String, age: Int, sex: String, weight: Float, 
             location: String, completion: @escaping (String) -> Void) {
    guard let user = Auth.auth().currentUser else {
        print("User not authenticated.")
        completion("User not authenticated.")
        return
    }
    
    let uid = user.uid
    var petData = [String: Any]()

    petData["name"] = name
    petData["breed"] = breed
    petData["age"] = age
    petData["sex"] = sex
    petData["weight"] = weight
    petData["location"] = location
    
    createOrUpdateDocument(collection: "pets-info", documentID: uid, data: petData) { error in
        if let error = error {
            completion("Error updating data: \(error.localizedDescription)")
        } else {
            completion("Data updated successfully!")
        }
    }
}


func createOrUpdateDocument(collection: String, documentID: String, 
                            data: [String: Any], completion: @escaping (Error?) -> Void) {
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


func fetchData(completion: @escaping ([String: Any]?, String?, String?, Int?, 
                                      String?, Float?, String?, Error?) -> Void) {
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
            
            if let name = data?["name"] as? String,
               let breed = data?["breed"] as? String,
               let age = data?["age"] as? Int,
               let sex = data?["sex"] as? String,
               let weight = data?["weight"] as? Float,
               let location = data?["location"] as? String {
                completion(data, name, breed, age, sex, weight, location, nil)
            } else {
                print("Error: 'name' field not found or has invalid type.")
                completion(nil, nil, nil, nil, nil, nil, nil, NSError(domain: "", code: -1, 
                                                                      userInfo: [NSLocalizedDescriptionKey: "Name field not found"]))
            }
        } else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
            print("Document does not exist")
            completion(nil, nil, nil, nil, nil, nil, nil, error)
        }
    }
}

func deleteData() {
    guard let currentUser = Auth.auth().currentUser else {
        print("No user is currently signed in.")
        return
    }
    let uid = currentUser.uid
    let db = Firestore.firestore()
    var docRef = db.collection("pets-info").document(uid)
    
    docRef.delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        }
        else {
            print("Document \(docRef) successfully removed!")
        }
    }
    
    docRef = db.collection("notifications").document(uid)
    docRef.delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        }
        else {
            print("Document \(docRef) successfully removed!")
        }
    }
}

func addNotification(lastFiveMessages: [String] = []) {
    guard let user = Auth.auth().currentUser else {
        print("User not authenticated.")
        return
    }

    let uid = user.uid
    let db = Firestore.firestore()
    let notificationsRef = db.collection("notifications").document(uid)

    // Fetch existing notifications
    notificationsRef.getDocument { document, error in
        if let error = error {
            print("Error fetching existing notifications: \(error.localizedDescription)")
            return
        }

        var existingMessages = document?.data()?["messages"] as? [String] ?? []

        // Append new messages to existing ones
        existingMessages.append(contentsOf: lastFiveMessages)

        // Update the document with the expanded array
        notificationsRef.setData(["messages": existingMessages]) { error in
            if let error = error {
                print("Error updating notifications: \(error.localizedDescription)")
            } else {
                print("Notifications updated successfully.")
            }
        }
    }
}


func fetchNotifications(completion: @escaping ([String]?, Error?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else {
        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
        return
    }
    
    let uid = currentUser.uid
    let db = Firestore.firestore()
    let docRef = db.collection("notifications").document(uid)
    
    docRef.getDocument { document, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        if let document = document, document.exists {
            let data = document.data()
            if let messages = data?["messages"] as? [String] {
                completion(messages, nil)
            } else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Messages not found in document"]))
            }
        } else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
        }
    }
}
