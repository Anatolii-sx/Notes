//
//  NoteViewController.swift
//  Notes
//
//  Created by Анатолий Миронов on 02.02.2022.
//

import UIKit

class NoteViewController: UIViewController {
    
    // MARK: - Public Properties
    var note: Note?
    var delegate: NoteViewControllerDelegate!
    var isNewNote: Bool!
    var bottomConstraintTV: NSLayoutConstraint?
    
    // MARK: - Private Properties
    private lazy var noteTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }()
    
    // MARK: - Methods Of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(noteTextView)
        
        // navigation bar
        setBarButtonItems()
        changeEnableDeleteButton()
        
        // text view
        setConstraintsForNoteTextView()
        setStartText()
        
        // keyboard
        addDoneButtonOnKeyboard()
        setKeyboardNotifications()
        setStartFocusOnTextView()
    }
    
    // MARK: - Setup navigation bar
    private func setBarButtonItems() {
        let saveButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(save)
        )
        
        let deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteNote)
        )
        
        navigationItem.rightBarButtonItems = [saveButton, deleteButton]
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func changeEnableDeleteButton() {
        navigationItem.rightBarButtonItems?.last?.isEnabled = isNewNote ? false : true
    }
    
    @objc private func save() {
        guard !noteTextView.text.isEmpty, !noteTextView.text.hasWhitespace else {
            if let _ = note {
                deleteNote()
            }
            navigationController?.popViewController(animated: true)
            return
        }

        if let note = note {
            StorageManager.shared.edit(note, newText: noteTextView.text)
            delegate.correctNote(note)
        } else {
            StorageManager.shared.save(noteTextView.text) { note in
                self.delegate.addNote(note)
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteNote() {
        if let note = note {
            StorageManager.shared.delete(note)
            delegate.deleteNote(note)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup Keyboard
    private func addDoneButtonOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        noteTextView.inputAccessoryView = keyboardToolbar
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        
        let flexBarButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        keyboardToolbar.items = [flexBarButton, doneButton]
    }
    
    private func setKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setStartFocusOnTextView() {
        guard let _ = note else {
            noteTextView.becomeFirstResponder()
            return
        }
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            changeBottomConstraintTV(keyboardHeight: keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide() {
        setDefaultBottomConstraintTV()
    }
    
    // MARK: - Setup TextView
    private func setConstraintsForNoteTextView() {
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraintTV = noteTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32)
        bottomConstraintTV?.isActive = true
        NSLayoutConstraint.activate([
            noteTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func changeBottomConstraintTV(keyboardHeight: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.bottomConstraintTV?.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func setDefaultBottomConstraintTV() {
        UIView.animate(withDuration: 0.5) {
            self.bottomConstraintTV?.constant = -32
            self.view.layoutIfNeeded()
        }
    }
    
    private func setStartText() {
        if let note = note {
            noteTextView.text = note.text
        }
    }
}

// MARK: - Checking whitespace in String
extension String {
  var hasWhitespace: Bool {
    allSatisfy { $0.isWhitespace }
  }
}
