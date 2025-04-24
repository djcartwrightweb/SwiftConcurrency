//
//  LessonNine.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-24.
//

import SwiftUI

class MyDataManager {
    static let shared = MyDataManager()
    
    private init() {}
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.concurrency.MyDataManager")
    
    func getRandomData(completion: @escaping (_ title: String?) -> ()) {
        lock.async {
            self.data.append(UUID().uuidString)
            print("\(Thread.current)")
            completion(self.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    static let shared = MyActorDataManager()
    
    private init() {}
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print("\(Thread.current)")
        return self.data.randomElement()
    }
    
   nonisolated func getSavedData() -> String {
        "NEW DATA"
    }
}

struct HomeView: View {
    
    let manager = MyActorDataManager.shared
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea(edges: .all)
            
            Text(text)
                .font(.headline)
        }
        .onAppear {
            let new = manager.getSavedData()
        }
        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .background).async {
//                
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            Task {
                let data = await manager.getRandomData()
                if let data = data {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.shared
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea(edges: .all)
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            Task {
                let data = await manager.getRandomData()
                if let data = data {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct LessonNine: View {
    var body: some View {
        TabView {
            Tab("First", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Second", systemImage: "2.circle") {
                BrowseView()
            }
        }
    }
}

#Preview {
    LessonNine()
}
