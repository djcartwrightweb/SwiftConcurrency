//
//  LessonSix.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-24.
//

import SwiftUI


class LessonSixDataManager {
    
    //    private let url = URL(string: "https://picsum.photos/200")!
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/200")
        
        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlStrings = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count) //small performance boost
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
        
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        do {
            guard let url = URL(string: urlString) else { throw URLError(.badURL) }
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { throw URLError(.badURL) }
            return image
        } catch {
            throw URLError(.badURL)
        }
    }
    
}


@Observable
class LessonSixViewModel {
    
    let manager = LessonSixDataManager()
    var images: [UIImage] = []
    
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            await MainActor.run {
                self.images = images
            }
        }
    }
}


struct LessonSix: View {
    
    @State private var viewModel = LessonSixViewModel()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Task Group 🔥")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    LessonSix()
}
