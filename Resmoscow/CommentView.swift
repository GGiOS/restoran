//
//  CommentView.swift
//  Resmoscow
//
//  Created by Egor Galaev on 06/05/17.


import RSKPlaceholderTextView

protocol CommentViewProtocol {
    func cancel()
    func addComment(comment: String)
}

class CommentView: UIView {
    
    @IBOutlet weak var textView: RSKPlaceholderTextView!
    var delegate: CommentViewProtocol? {
        didSet {
            (viewWithTag(1) as? UIButton)?.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
            (viewWithTag(2) as? UIButton)?.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
            (viewWithTag(10) as? UILabel)?.text = NSLocalizedString("Comment to the order", comment: "").uppercased()
            textView.placeholder = NSLocalizedString("Write a comment", comment: "") as NSString?
            textView.text = Order.shared.comment
            textView.becomeFirstResponder()
        }
    }
     
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate?.cancel()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.addComment(comment: textView.text)
    }
}
