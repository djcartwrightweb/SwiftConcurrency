//
//  lessonOne.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-02-13.
//

import SwiftUI

class lessonOneDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("new text", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("new text")
        } else {
            return .failure(URLError(.badServerResponse))
        }
    }
    
    func getTitle3() throws -> String {
        if isActive {
            return "new text"
        } else {
            throw URLError(.zeroByteResource)
        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "FINAL TEXT"
        } else {
            throw URLError(.zeroByteResource)
        }
    }
}

@Observable
class lessonOneViewModel {
    
    let manager = lessonOneDataManager()
    
    var text = "Starting text"
    
    func fetchTitle() {
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            text = newTitle
        } else if let error = returnedValue.error {
            text = error.localizedDescription
        }
         */
        /*
        let result = manager.getTitle2()
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
        */
        /*
        do {
            let newTitle = try manager.getTitle3()
            self.text = newTitle
            
            let newTitle2 = try manager.getTitle4()
            self.text = newTitle2
            
        } catch {
            self.text = error.localizedDescription
        }
         */
        if let newTitle = try? manager.getTitle4() {
            self.text = newTitle
        }
    }
}

struct lessonOne: View {
    
    @State private var vm = lessonOneViewModel()
    
    var body: some View {
        Text(vm.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                vm.fetchTitle()
            }
    }
}

#Preview {
    lessonOne()
}
