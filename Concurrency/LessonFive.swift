//
//  LessonFive.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-23.
//

import SwiftUI

struct LessonFive: View {
    @State private var images: [UIImage] = []
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    private let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle(Text("Lesson Five 🥳"))
        }
//        .onAppear {
//            Task {
//                do {
//                    
////                    async let fetchImage1 = fetchImage()
////                    async let fetchTitle1 = fetchTitle()
//                    
////                    let (image, title) = await (try fetchImage1, fetchTitle1)
//                    
////                    async let fetchImage2 = fetchImage()
////                    async let fetchImage3 = fetchImage()
////                    async let fetchImage4 = fetchImage()
////                    
////                    let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
////                    self.images.append(contentsOf: [image1, image2, image3, image4])
//                    
//                } catch {
//                    print("Error fetching images: \(error.localizedDescription)")
//                }
//            }
            
            
            
//        }
    }
    
    func fetchTitle() async -> String {
        return "Title"
    }
    
    func fetchImage() async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
}

#Preview {
    LessonFive()
}
