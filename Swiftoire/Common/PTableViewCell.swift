//
//  PTableViewCell.swift
//  PowerDelivery
//
//  Created by 付文华 on 2021/5/12.
//

import UIKit

class PTableViewCell: UITableViewCell {
    
    var dispose = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dispose = DisposeBag()
    }

}
