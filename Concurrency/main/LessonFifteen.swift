//
//  LessonFifteen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-25.
//

import SwiftUI

final class RefreshableDataService {
    func getData() async throws -> [String] {
        try await Task.sleep(for: .seconds(5))
        return ["Apple", "Banana", "Orange"].shuffled()
    }
}

@MainActor @Observable final class LessonFifteenViewModel {
    private(set) var items: [String] = []
    let manager = RefreshableDataService()
    func loadData() async {
        do {
            items = try await manager.getData()
        } catch {
            print(error)
        }
    }
}

struct LessonFifteen: View {
    
    @State private var viewModel = LessonFifteenViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .navigationTitle("Refreshable")
            .task {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    LessonFifteen()
}
