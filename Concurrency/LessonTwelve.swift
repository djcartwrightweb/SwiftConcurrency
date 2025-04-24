//
//  LessonTwelve.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-24.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Banana")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Orange")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Watermelon")

    }
    
}

@Observable class LessonTwelveViewModel {
    
    let manager = AsyncPublisherDataManager()
    @MainActor var dataArray: [String] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
        Task {
            
            await MainActor.run {
                self.dataArray = ["One"]
            }
            
            for await value in manager.$myData.values {
                await MainActor.run {
                    self.dataArray.append(contentsOf: value)
                }
                break
            }
            
            await MainActor.run {
                self.dataArray.append("TWO")
            }
        }
            
    }
    
    func start() async {
        await manager.addData()
    }
}

struct LessonTwelve: View {
    
    @State private var viewModel = LessonTwelveViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    LessonTwelve()
}
