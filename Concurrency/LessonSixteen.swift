//
//  LessonSixteen.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-25.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, japanese
}

final class RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "McDonald's", cuisine: .american),
            Restaurant(id: "2", title: "Olive Garden", cuisine: .italian),
            Restaurant(id: "3", title: "Sushi Place", cuisine: .japanese),
            Restaurant(id: "4", title: "Pasta Place", cuisine: .italian)
        ]
    }
}

@MainActor final class LessonSixteenViewModel: ObservableObject {
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
        
    
    let manager = RestaurantManager()
    private var cancellables: Set<AnyCancellable> = []
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var showSearchSuggestions: Bool {
        searchText.count < 5
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(option: let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink{ [weak self] searchText, searchScope in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        //filter on search scope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restaurantsInScope = allRestaurants.filter { $0.cuisine == option }
        }
        
        //filter on search text
        let search = searchText.lowercased()
        filteredRestaurants = restaurantsInScope.filter { restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainsSearch
        }
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map { SearchScopeOption.cuisine(option: $0)}
        } catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String] {
        
        guard showSearchSuggestions else {return []}
        
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        
        suggestions.append("Market")
        suggestions.append("Grocery")
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        
        return suggestions
    }
    
    func getRestaurantSuggestions() -> [Restaurant] {
        guard showSearchSuggestions else {return []}
        
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter({$0.cuisine == .italian}))
        }
        
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter({$0.cuisine == .japanese}))
        }
        
        if search.contains("ame") {
            suggestions.append(contentsOf: allRestaurants.filter({$0.cuisine == .american}))
        }
        
        return suggestions
    }
}

struct LessonSixteen: View {
    
    @StateObject private var viewModel = LessonSixteenViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                    NavigationLink(value: restaurant) {
                        restaurantRow(for: restaurant)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            Text("ViewModel is searching \(viewModel.isSearching)")
            SearchChildView()
        }
        .task {
            await viewModel.loadRestaurants()
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search restaurants")
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        .searchSuggestions({
            ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
            ForEach(viewModel.getRestaurantSuggestions(), id: \.self) { restaurant in
                NavigationLink(value: restaurant) {
                    Text(restaurant.title)
                }
                    
            }
        })
        .navigationTitle("Restaurants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
    
    private func restaurantRow(for restaurant: Restaurant) -> some View {
        VStack(alignment: .leading) {
            Text(restaurant.title)
                .font(.headline)
            Text(restaurant.cuisine.rawValue)
                .font(.caption)
        }
        .padding(.horizontal)
    }
}

struct SearchChildView: View {
    
    @Environment(\.isSearching) private var isSearching // needs to be in a child view like this to work
    
    var body: some View {
        Text("Child View is searching \(isSearching)")
    }
}

#Preview {
    NavigationStack {
        LessonSixteen()
    }
}
