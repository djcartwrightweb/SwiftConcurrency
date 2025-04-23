//
//  lessonThree.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-23.
//

import SwiftUI

@Observable class LessonThreeViewModel {
    var dataArray: [String] = []
    
    func addAuthor1() async {
        
        
        self.dataArray.append("Author 1 : \(Thread.current)")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        self.dataArray.append("Author 2 : \(Thread.current)")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run {
            let author3 = "Author 3 : \(Thread.current)"
            self.dataArray.append(author3)
        }
    }
    
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something 1 : \(Thread.current)"
        let something2 = "Something 2 : \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(something1)
            let something2 = "Something 2 : \(Thread.current)"
            self.dataArray.append(something2)
        }
    }
    
}

struct LessonThree: View {
    
    @State private var viewModel = LessonThreeViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
                    .font(.caption)
            }
        }
        .onAppear {
            Task {
                await viewModel.addSomething()
                let finalText = "Final: \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}


#Preview {
    LessonThree()
}
