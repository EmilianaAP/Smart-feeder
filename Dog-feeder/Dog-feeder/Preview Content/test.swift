import SwiftUI

struct test: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: MainPage()) {
                    Text("Go to Main Page")
                }
            }
            .navigationTitle("Content View")
        }
    }
}

struct MainPage: View {
    var body: some View {
        VStack {
            NavigationLink(destination: ProfileView()) {
                Text("Go to Profile")
            }
        }
        .navigationTitle("Main Page")
    }
}

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Text("Profile")
            Button(action: {
                // Navigate back to MainPage skipping ContentView
                self.presentationMode.wrappedValue.dismiss()
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back to Main Page")
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    test()
}
