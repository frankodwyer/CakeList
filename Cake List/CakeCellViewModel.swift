//
//  CakeCellViewModel.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.


import Foundation

class CakeCellViewModel {
    let imageURI: String // the URL string, used as a unique ID
    let title: String
    let description: String

    init(cake: Cake) {
        imageURI = cake.imageURL.absoluteString
        title = cake.title
        description = cake.description
    }
}
