//
//  ContactListViewController.swift
//  ContactApp
//
//  Created by Ridho Pratama on 26/09/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import UIKit

class ContactListViewController: UIViewController {
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ContactListTableViewCell.self, forCellReuseIdentifier: ContactListTableViewCell.reuseIdentifier)
        tv.estimatedRowHeight = 80
        tv.rowHeight = 80
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    private let viewModel = ContactListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupViewModel()
        self.fetchContacts()
    }
    
    private func setupView() {
        title = "Contact List"
        
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        view.backgroundColor = .white
    }
    
    private func setupViewModel() {
        viewModel.onContactSelectedByID = { id in
            print(id) // todo: handle
        }
        
        viewModel.onDataRefreshed = { [tableView] in
            tableView.reloadData()
        }
        
        viewModel.onError = { error in
            print(error) // todo: handle
        }
    }
    
    private func fetchContacts() {
        viewModel.fetchContactList()
    }
}
