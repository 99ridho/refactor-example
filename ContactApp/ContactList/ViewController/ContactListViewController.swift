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
    
    private var rawContacts: [Contact] = []
    private var contactCellData: [ContactListCellData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    private func setupView() {
        title = "Contact List"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        view.backgroundColor = .white
    }
    
    private func fetchContacts() {
        let url = URL(string: "https://gist.githubusercontent.com/99ridho/cbbeae1fa014522151e45a766492233c/raw/8935d40ae0650f12b452d6a5e9aa238a02b05511/contacts.json")!
        let task = URLSession.shared.dataTask(with: url) { [weak self, jsonDecoder] (data, response, error) in
            if error != nil {
                // do something with error
                return
            }
            
            guard let theData = data else {
                // do something when data is null
                return
            }
            
            do {
                let response = try jsonDecoder.decode(ContactListResponse.self, from: theData)
                let contacts = response.data
                
                self?.rawContacts = contacts
                self?.contactCellData = contacts.map {
                    ContactListCellData(imageURL: $0.imageUrl, name: $0.name)
                }
                
                self?.tableView.reloadData()
            } catch {
                // do something when failed response mapping
            }
        }
        
        task.resume()
    }
}

extension ContactListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactCellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = contactCellData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reuseIdentifier) as! ContactListTableViewCell
        cell.configureCell(with: cellData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
