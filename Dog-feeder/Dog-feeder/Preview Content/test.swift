import SwiftUI

import SwiftUI

struct FirstView: View {
    @State private var currentPage: Int? = nil
    
    var body: some View {
        VStack {
            if currentPage == nil {
                Button("Go to Second Page") {
                    currentPage = 1
                }
            } else if currentPage == 1 {
                SecondView(currentPage: $currentPage)
            } else if currentPage == 2 {
                ThirdView(currentPage: $currentPage)
            }
        }
    }
}

struct SecondView: View {
    @Binding var currentPage: Int?
    
    var body: some View {
        VStack {
            Text("Second Page")
            Button("Go to Third Page") {
                currentPage = 2
            }
        }
    }
}

struct ThirdView: View {
    @Binding var currentPage: Int?
    
    var body: some View {
        VStack {
            Text("Third Page")
        }
    }
}

#Preview {
    FirstView()
}
