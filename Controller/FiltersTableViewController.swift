//
//  FiltersTableViewController.swift
//  WebsiteFilter
//
//  Created by Екатерина Токарева on 04/02/2023.
//

import UIKit
import CoreData

final class FiltersTableViewController: UITableViewController {
    
    private var filters: [Filter] = []
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Add filters to select and manage them in the list"
        label.textAlignment = .center
        return label
    }()
    private var persistenceContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "Filters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissController))
        tableView.backgroundView = emptyStateLabel
        tableView.backgroundView?.isHidden = !filters.isEmpty
    }
    
    @objc private func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateData() {
        guard let context = persistenceContext else { return }
        let filtersFetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
        do {
            filters = try context.fetch(filtersFetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row].text
        cell.accessoryType = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let context = persistenceContext else { return }
        context.delete( filters[indexPath.row])
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        filters.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.backgroundView?.isHidden = !filters.isEmpty
    }
}
