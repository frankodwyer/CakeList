//
//  CakesViewModel.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.


import Foundation

enum CakesViewModelError : Error {
    case ParseError
}

struct CakesState {
    var isLoading = false
    var error: Error?
    var cakes = [Cake]()
}

class CakesViewModel {
    static let dataURL = "https://gist.githubusercontent.com/hart88/198f29ec5114a3ec3460/raw/8dd19a88f9b8d24c23d9960f3300d0c917a4f07c/cake.json"

    // boilerplate to allow a nice syntax for observing changes
    private var state = CakesState() {
        didSet {
            DispatchQueue.main.async { [unowned self] in 
                self.callback()
            }
        }
    }
    private var callback: () -> Void

    private let httpClient: HttpClient

    init(httpClient: HttpClient = NetworkHttpClient(), callback: @escaping () -> Void) {
        self.callback = callback
        self.httpClient = httpClient
    }

    var numberOfRows: Int {
        return state.cakes.count
    }

    var numberOfSections: Int {
        return 1
    }

    var isLoading: Bool {
        return state.isLoading
    }

    var error: Error? {
        return state.error
    }

    func viewModelForCell(at indexPath: IndexPath) -> CakeCellViewModel {
        return CakeCellViewModel(cake: state.cakes[indexPath.row])
    }

    func getData() {
        state.isLoading = true
        httpClient.makeGETNetworkRequest(path: CakesViewModel.dataURL) { (result) in
            switch result {
            case .success(let data):
                if let cakes = Cake.from(data: data) {
                    self.state.cakes = cakes
                    self.state.error = nil
                } else {
                    self.state.cakes = []
                    self.state.error = CakesViewModelError.ParseError
                }

            case .failure(let error):
                self.state.cakes = []
                self.state.error = error
            }
            self.state.isLoading = false
        }
    }

}
