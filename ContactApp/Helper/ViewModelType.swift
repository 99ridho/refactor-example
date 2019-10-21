//
//  ViewModelType.swift
//  ContactApp
//
//  Created by Wendy Liga on 21/10/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
