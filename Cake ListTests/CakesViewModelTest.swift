//
//  CakesViewModelTest.swift
//  Cake ListTests
//
//  Created by Frank on 25/04/2019.

import XCTest

// TODO: move this to its own file, probably useful for other tests.
class MockHttpClient : HttpClient {
    let result: Result<Data, Error>

    func makeGETNetworkRequest(path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        completion(result)
    }

    init(result: Result<Data, Error>) {
        self.result = result
    }
}

enum MockError: Error {
    case SomethingWentWrong
}

final class CakesViewModelTest: XCTestCase {

    let expectation = XCTestExpectation(description: "completion called")

    override func setUp() {
        super.setUp()
    }

    var model: CakesViewModel!

    func testUnexpectedErrorCase() {
        let result = Result<Data, Error>.failure(MockError.SomethingWentWrong)
        let client = MockHttpClient(result: result)

        model = CakesViewModel(httpClient: client) {
            XCTAssert(self.model.error != nil)
            XCTAssert(self.model.isLoading == false)
            XCTAssert(self.model.numberOfRows == 0)
            XCTAssert(self.model.numberOfSections == 1)
            self.expectation.fulfill()
        }

        model.getData()

        wait(for: [expectation], timeout: 5)
    }

    func testSimpleHappyCase() {
        let mockDataString = "[{\"title\":\"Lemon cheesecake\",\"desc\":\"A cheesecake made of lemon\",\"image\":\"https://s3-eu-west-1.amazonaws.com/s3.mediafileserver.co.uk/carnation/WebFiles/RecipeImages/lemoncheesecake_lg.jpg\"}]"
        let data = mockDataString.data(using: .utf8)!
        let result = Result<Data, Error>.success(data)
        let client = MockHttpClient(result: result)

        model = CakesViewModel(httpClient: client) {
            XCTAssert(self.model.error == nil)
            XCTAssert(self.model.isLoading == false)
            XCTAssert(self.model.numberOfRows == 1)
            XCTAssert(self.model.numberOfSections == 1)
            let cellViewModel = self.model.viewModelForCell(at: IndexPath(row: 0, section: 0))
            XCTAssert(cellViewModel.description == "A cheesecake made of lemon")
            XCTAssert(cellViewModel.title == "Lemon cheesecake")
            XCTAssert(cellViewModel.imageURI == "https://s3-eu-west-1.amazonaws.com/s3.mediafileserver.co.uk/carnation/WebFiles/RecipeImages/lemoncheesecake_lg.jpg")
            self.expectation.fulfill()
        }

        model.getData()

        wait(for: [expectation], timeout: 5)
    }
}
