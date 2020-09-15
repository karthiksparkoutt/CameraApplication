//
//  CollectionViewCell.swift
//  SampleProject
//
//  Created by Karthik Rajan T  on 11/09/20.
//  Copyright © 2020 Karthik Rajan T . All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
       var isInEditingMode: Bool = false {
            didSet {
                checkmarkLabel.isHidden = !isInEditingMode
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isInEditingMode {
                    checkmarkLabel.text = isSelected ? "✓" : ""
                }
            }
        }
        
    }
