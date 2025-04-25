//
//  LessonThirteen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-24.
//

import SwiftUI

final class StrongSelfDataService {
    
    func getData() async -> String {
        "Updated data"
    }
    
}

@Observable final class LessonThirteenViewModel {
    
    private var someTask: Task<Void, Never>?
    private var myTasks: [Task<Void, Never>?] = []
    
    func cancelTasks() {
        someTask?.cancel()
        
        myTasks.forEach({ $0?.cancel() })
    }
    
    var data: String = "Some Title"
    let dataService = StrongSelfDataService()
    
    //This implies a strong reference
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    //this is an explicit strong reference
    func updateData2() {
        Task {
            self.data = await self.dataService.getData()
        }
    }
    
    //this is an explicit strong reference
    func updateData3() {
        Task { [self] in
            self.data = await self.dataService.getData()
        }
    }
    
    //this is a weak reference
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    //don't need to manage self as can just manager task
    func updateData5() {
         someTask = Task {
            self.data = await self.dataService.getData()
        }
    }
    
    func updateData6() {
         let task1 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
           self.data = await self.dataService.getData()
       }
        myTasks.append(task2)
        
        let task3 = Task {
           self.data = await self.dataService.getData()
       }
        myTasks.append(task3)
    }
}

struct LessonThirteen: View {
    
    @State private var viewModel = LessonThirteenViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData5()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
    }
}

#Preview {
    LessonThirteen()
}
