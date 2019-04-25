//
//  CakeCell.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.
//  Copyright © 2019 Stewart Hart. All rights reserved.
//

import UIKit

class CakeCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cakeDescription: UILabel!
    @IBOutlet weak var cakeImage: UIImageView!

    func configure(with model: CakeCellViewModel) {
        title.text = model.title
        cakeDescription.text = model.description
        cakeImage.image = nil

        let imageSize = cakeImage.bounds.size

        // TODO: could add an activity indicator in each cell's imageview, to indicate loading?
        ImageStore.shared.loadImage(at: model.imageURI, for: imageSize, scale: traitCollection.displayScale) { image in
            self.cakeImage.image = image
        }

        // makes the selection match the custom image bg color
        let selectedView = UIView()
        selectedView.backgroundColor = cakeImage.backgroundColor
        selectedBackgroundView = selectedView
    }

    // this is to avoid some glitching on the image when selecting
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let saveBackgroundColor = cakeImage.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        cakeImage.backgroundColor = saveBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let saveBackgroundColor = cakeImage.backgroundColor
        super.setSelected(selected, animated: animated)
        cakeImage.backgroundColor = saveBackgroundColor
    }

}
