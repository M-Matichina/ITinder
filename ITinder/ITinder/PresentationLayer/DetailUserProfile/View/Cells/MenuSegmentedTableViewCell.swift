//
//  MenuSegmentedTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import UIKit

final class MenuSegmentedTableViewCell: UITableViewCell {
    
    // MARK: - Handlers

    var selectHandler: ((_ index: Int) -> Void)?

    // MARK: - Outlets

    @IBOutlet var menuSegmented: UISegmentedControl!

    // MARK: Properties

    private let defaultAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
    private let selectedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        menuSegmented.setTitleTextAttributes(defaultAttributes, for: .selected)
        menuSegmented.setTitleTextAttributes(selectedAttributes, for: .normal)
    }

    // MARK: Actions

    @IBAction func menuSegmentedAction(_ sender: Any) {
        selectHandler?(menuSegmented.selectedSegmentIndex)
    }
}
