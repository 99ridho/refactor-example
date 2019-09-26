//
//  Contact.swift
//  ContactApp
//
//  Created by Ridho Pratama on 26/09/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import Foundation

struct Contact: Decodable {
    let id: Int
    let name: String
    let phoneNumber: String
    let email: String
    let imageUrl: String
}

struct ContactListResponse: Decodable {
    let data: [Contact]
}
