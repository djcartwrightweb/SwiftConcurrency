//
//  LessonTen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-24.
//

import SwiftUI

@globalActor final class MyFirstGlobalActor {
    static let shared = MyNewDataManager()
}

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve"]
    }
    
}

@Observable
@MainActor
class LessonTenViewModel {
    
    let manager = MyFirstGlobalActor.shared
    var dataArray: [String] = []
    
    @MyFirstGlobalActor
    func getData() {
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run {
                self.dataArray = data
            }
        }
    }
    
}

struct LessonTen: View {
    
    @State private var viewModel = LessonTenViewModel()
    
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
            await viewModel.getData()
        }
    }
}

#Preview {
    LessonTen()
}
