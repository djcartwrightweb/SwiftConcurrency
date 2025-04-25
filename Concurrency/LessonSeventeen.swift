//
//  LessonSeventeen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-25.
//

import SwiftUI
import PhotosUI

@MainActor
final class LessonSeventeenViewModel: ObservableObject {
    @Published private(set) var image: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published private(set) var images: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]) {
        
        Task {
            var images: [UIImage] = []
            for selection in selections {
                if let data = try await selection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
            self.images = images
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        Task {
            do {
                if let data = try await selection.loadTransferable(type: Data.self) {
                    image = UIImage(data: data)
                }
            } catch {
                print(error)
            }
        }
    }
}

struct LessonSeventeen: View {
    
    @StateObject private var viewModel = LessonSeventeenViewModel()
    
    var body: some View {
        VStack {
            
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            } else {
                ProgressView()
            }
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Select a photo")
            }
            
            Spacer()
            
            if viewModel.images.isEmpty {
                ProgressView()
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(viewModel.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            }
            
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                Text("Select a photo")
            }
        }
    }
}

#Preview {
    LessonSeventeen()
}
