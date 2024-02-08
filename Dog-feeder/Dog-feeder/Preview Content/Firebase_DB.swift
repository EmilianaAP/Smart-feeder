//
//  Firebase_DB.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 8.02.24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Firebase_DB: View {
    var body: some View {
        VStack {
            Text("Welcome to Firebase SwiftUI App!")
                .padding()
            Button("Add Example Data") {
                addExampleData()
            }
        }
    }
    
    func addExampleData() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated.")
            return
        }
        
        let uid = user.uid
        let exampleData = [
            "name": "Erix",
            "age": 5,
            "bread": "Dog"
        ] as [String : Any]
        
        createOrUpdateDocument(collection: "pets-info", documentID: uid, data: exampleData) { error in
            if let error = error {
                print("Error updating data: \(error)")
            } else {
                print("Data updated successfully!")
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
}

#Preview {
    Firebase_DB()
}
