//
//  HttpClient.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.


import Foundation

protocol HttpClient {
    func makeGETNetworkRequest(path: String, completion: @escaping (Result<Data, Error>) -> Void)
}
