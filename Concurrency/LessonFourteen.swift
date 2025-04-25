//
//  LessonFourteen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-25.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        "Some Data!"
    }
}

actor myManagerActor {
    func getData() async throws -> String {
        "Some Data!"
    }
}

@MainActor @Observable final class LessonFourteenViewModel {
    let managerClass = MyManagerClass()
    let managerActor = myManagerActor()
    
    private var myTasks: [Task<Void, Never>] = []

    private(set) var myData: String = "Starting text"
    
    func cancelTasks() {
        myTasks.forEach { $0.cancel() }
        myTasks = []
    }
    
    func OnButtonPress() {
        let task = Task {
            do {
                myData = try await managerActor.getData()
            } catch {
                print("Error: \(error)")
            }
        }
        myTasks.append(task)
    }
}

struct LessonFourteen: View {
    
    @State private var viewModel = LessonFourteenViewModel()
    
    var body: some View {
        Button("click me") {
            viewModel.OnButtonPress()
        }
    }
}

#Preview {
    LessonFourteen()
}

