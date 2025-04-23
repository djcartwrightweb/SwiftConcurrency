//
//  LessonFour.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-23.
//

import SwiftUI

@Observable class LessonFourViewModel {
    
    var image: UIImage?
    var image2: UIImage?
    
    func fetchImage() async {
                try? await Task.sleep(for: .seconds(5))
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {return}
            print("Starting request to \(url)")
            let (data, response) = try await URLSession.shared.data(from: url)
            print("Response received: \(response)")
            await MainActor.run {
                self.image = UIImage(data: data)
                print("Image returned ⚠️")
            }
        } catch {
            print("Error fetching image: \(error)")
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {return}
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image2 = UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct LessonFourHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink("Click me") {
                    LessonFour()
                }
            }
        }
    }
}

struct LessonFour: View {
    
    @State private var vm = LessonFourViewModel()
    @State private var myImagesTask: Task<(), Never>? = nil
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image = vm.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await vm.fetchImage()
        }
//        .onAppear {
//            self.myImagesTask = Task {
//                print("fetching images...")
//                await vm.fetchImage()
//                await vm.fetchImage2()
//                print("image fetched!")
//            }
//        }
//        .onDisappear {
//            self.myImagesTask?.cancel()
//        }
        
    }
}

#Preview {
    LessonFour()
}
