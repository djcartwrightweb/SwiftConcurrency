//
//  LessonEighteen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-25.
//

import SwiftUI

class LessonEighteenDataManager {
    
    func getAsyncStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { [weak self] continuation in
            self?.getFakeData { value in
                continuation.yield(value)
            } onFinish: { error in
                continuation.finish(throwing: error)
            }
        }
    }
    
    func getFakeData(newValue: @escaping (_ value: Int) -> (),
                     onFinish: @escaping (_ error: Error?) -> () ) {
        let items: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item)) {
                newValue(item)
                print("New Data: \(item)")
                if item == items.last {
                    onFinish(nil)
                }
            }
        }
    }
}

@MainActor @Observable final class LessonEighteenViewModel {
    private(set) var currentNumber: Int = 0
    let manager = LessonEighteenDataManager()
    
    func onViewAppear() {
        //        manager.getFakeData { [weak self] value in
        //            self?.currentNumber = value
        //        }
        
        let task1 = Task {
            do {
                for try await value in manager.getAsyncStream().dropFirst(2) {
                    currentNumber = value
                }
            } catch {
                print(error.localizedDescription)
            }
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            task1.cancel()
//        }
    }
}

struct LessonEighteen: View {
    
    @State private var viewModel = LessonEighteenViewModel()
    
    var body: some View {
        Text(viewModel.currentNumber.description)
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

#Preview {
    LessonEighteen()
}
