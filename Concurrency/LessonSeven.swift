//
//  LessonSeven.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-24.
//

import SwiftUI

class LessonSevenNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completion: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            completion(UIImage(systemName: "heart.fill")!)
        })
    }
    
    func getHeartImageFromDatabase2() async -> UIImage {
        await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
  
}

@Observable
class LessonSevenViewModel {
    
    let networkManager = LessonSevenNetworkManager()
    var image: UIImage?
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func getHeartImage() async {
            self.image = await networkManager.getHeartImageFromDatabase2()
    }
    
}

struct LessonSeven: View {
    
    @State private var viewModel = LessonSevenViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

#Preview {
    LessonSeven()
}
