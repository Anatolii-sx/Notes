//
//  ViewController.swift
//  Notes
//
//  Created by Анатолий Миронов on 02.02.2022.
//

import UIKit

protocol NoteViewControllerDelegate {
    func addNote(_ note: Note)
    func correctNote(_ note: Note)
    func deleteNote(_ note: Note)
}

class MainViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let cellID = "note"
    
    private var notes: [Note] = []

    // MARK: - Methods Of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    // MARK: - UITableViewDataSource / UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let note = notes[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = note.text
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let noteVC = NoteViewController()
        noteVC.note = notes[indexPath.row]
        noteVC.delegate = self
        noteVC.isNewNote = false
        navigationController?.pushViewController(noteVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(note)
        }
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.08021575958, green: 0.4831395745, blue: 0.7987222075, alpha: 0.76)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(addNewNote)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
   @objc private func addNewNote() {
       let noteVC = NoteViewController()
       noteVC.delegate = self
       noteVC.isNewNote = true
       navigationController?.pushViewController(noteVC, animated: true)
    }
}

// MARK: - Getting Data
extension MainViewController {
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let notes):
                self.notes = notes
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Implementing NoteViewControllerDelegate protocol methods
extension MainViewController: NoteViewControllerDelegate {
    func addNote(_ note: Note) {
        notes.append(note)
        tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: .automatic)
    }
    
    func correctNote(_ note: Note) {
        let rowIndex = IndexPath(row: notes.firstIndex(of: note) ?? 0, section: 0)
        tableView.reloadRows(at: [rowIndex], with: .automatic)
    }
    
    func deleteNote(_ note: Note) {
        let rowIndex = IndexPath(row: notes.firstIndex(of: note) ?? 0, section: 0)
        notes.remove(at: rowIndex.row)
        tableView.deleteRows(at: [rowIndex], with: .automatic)
    }
}

