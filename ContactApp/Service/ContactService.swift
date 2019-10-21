//
//  ContactService.swift
//  ContactApp
//
//  Created by Ridho Pratama on 01/10/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import Foundation
import RxSwift

enum ContactServiceError: Error {
    case missingData
}

protocol ContactServiceProtocol {
    func fetchContacts(completion: @escaping ((Result<[Contact], Error>) -> Void))
    func reactiveFetchContacts() -> Observable<[Contact]>
}

class NetworkContactService: ContactServiceProtocol {
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    func fetchContacts(completion: @escaping ((Result<[Contact], Error>) -> Void)) {
        let url = URL(string: "https://gist.githubusercontent.com/99ridho/cbbeae1fa014522151e45a766492233c/raw/8935d40ae0650f12b452d6a5e9aa238a02b05511/contacts.json")!
        
        let task = URLSession.shared.dataTask(with: url) { [jsonDecoder] (data, response, error) in
            if let theError = error {
                completion(.failure(theError))
                return
            }
            
            guard let theData = data else {
                completion(.failure(ContactServiceError.missingData))
                return
            }
            
            do {
                let response = try jsonDecoder.decode(ContactListResponse.self, from: theData)
                let contacts = response.data

                completion(.success(contacts))
            } catch (let decodeError) {
                completion(.failure(decodeError))
            }
        }
        
        task.resume()
    }
    
    func reactiveFetchContacts() -> Observable<[Contact]> {
        let url = URL(string: "https://gist.githubusercontent.com/99ridho/cbbeae1fa014522151e45a766492233c/raw/8935d40ae0650f12b452d6a5e9aa238a02b05511/contacts.json")!
        
        let urlRequest = URLRequest(url: url)
        
        let response = URLSession.shared.rx
            .data(request: urlRequest)
            .flatMapLatest { data -> Observable<ContactListResponse> in
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do{
                    let resultData = try decoder.decode(ContactListResponse.self, from: data)
                    return Observable.just(resultData)
                } catch (let decodeError) {
                    return Observable.error(decodeError)
                }
        }
        
        let contacts = response.map { $0.data }
        
        return contacts
    }
}
