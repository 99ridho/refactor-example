//
//  ContactListViewModel.swift
//  ContactApp
//
//  Created by Ridho Pratama on 01/10/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import Foundation
import UIKit

class ContactListViewModel: NSObject {
    private let service: ContactServiceProtocol
    
    private var contactsCellData: [ContactListCellData] = []
    private var rawContacts: [Contact] = []
    
    // MARK: - View Model Outputs
    var onContactSelectedByID: ((Int) -> Void)?
    var onDataRefreshed: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(service: ContactServiceProtocol = NetworkContactService()) {
        self.service = service
        
        super.init()
    }
    
    func fetchContactList() {
        service.fetchContacts { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case let .success(contacts):
                    self?.rawContacts = contacts
                    self?.contactsCellData = contacts.map {
                        ContactListCellData(imageURL: $0.imageUrl, name: $0.name)
                    }
                    self?.onDataRefreshed?()
                case let .failure(error):
                    self?.onError?(error)
                }
            }
        }
    }
}

// MARK: - Table view data source & delegates will be implemented here
extension ContactListViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsCellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = contactsCellData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reuseIdentifier) as! ContactListTableViewCell
        cell.configureCell(with: cellData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactID = rawContacts[indexPath.row].id
        onContactSelectedByID?(contactID)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
