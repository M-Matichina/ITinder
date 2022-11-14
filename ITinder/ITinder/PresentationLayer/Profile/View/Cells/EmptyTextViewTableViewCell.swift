//
//  EmptyTextViewTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 15.08.2021.
//

import UIKit

final class EmptyTextViewTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var backView: UIView!

    // MARK: - Handler

    var textHandler: ((_ text: String) -> Void)?

    // MARK: - Properties

    private var placeholderText = ""

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        backgroundColor = .clear
        textView.delegate = self
        backView.layer.cornerRadius = 10
    }

    func configure(_ text: String, _ placeholder: String) {
        placeholderText = placeholder
        textView.text = text == "" ? placeholder : text
        textView.textColor = text == "" ? UIColor.systemGray : UIColor.black
    }
}

extension EmptyTextViewTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholderText
            textView.textColor = UIColor.systemGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        textHandler?(textView.text)
    }
}
