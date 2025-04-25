//
//  LessonNineteen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-25.
//

import SwiftUI

actor TitleDatabase {
    func getNewTitle() -> String {
        "Some new title"
    }
}

@MainActor class ObservableViewModel: ObservableObject {
    @Published var title: String = "Starting title"
    let database = TitleDatabase()
    
    func updateTitle() async {
        title = await database.getNewTitle()
    }
}

@MainActor @Observable class LessonNineteenViewModel {
    var title: String = "Starting title"
    let database = TitleDatabase()
    
    func updateTitle() {
        Task { @MainActor in
            title = await database.getNewTitle()
            print(Thread.current)
        }
    }
}

struct LessonNineteen: View {
    
    @StateObject private var vm = ObservableViewModel()
    @State private var viewModel = LessonNineteenViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .onAppear {
               viewModel.updateTitle()
            }
    }
}

#Preview {
    LessonNineteen()
}
