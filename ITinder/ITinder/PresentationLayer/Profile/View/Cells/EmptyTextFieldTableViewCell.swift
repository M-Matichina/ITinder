//
//  EmptyTextFieldTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 15.08.2021.
//

import UIKit

final class EmptyTextFieldTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak private var backView: UIView!
    @IBOutlet weak private var textField: UITextField!

    // MARK: - Handler

    var textHandler: ((_ text: String) -> Void)?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        backgroundColor = .clear

        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        backView.layer.cornerRadius = 10
    }

    func configure(_ text: String, _ placeholder: String, _ keyboard: UIKeyboardType = .default, _ isEnabled: Bool = true) {
        textField.isUserInteractionEnabled = isEnabled
        textField.keyboardType = keyboard
        textField.text = text
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
    }
}

extension EmptyTextFieldTableViewCell: UITextFieldDelegate {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        textHandler?(textField.text ?? "")
    }
}
