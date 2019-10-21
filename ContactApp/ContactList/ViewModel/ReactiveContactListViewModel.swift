//
//  ReactiveContactListViewModel.swift
//  ContactApp
//
//  Created by Wendy Liga on 21/10/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import RxCocoa
import RxSwift

internal class ReactiveContactListViewModel: ViewModelType{
    let service: ContactServiceProtocol
       
    init(service: ContactServiceProtocol = NetworkContactService()) {
        self.service = service
    }
    
    internal struct Input {
        let viewDidLoad: Driver<Void>
        let didTapAtIndex: Driver<IndexPath>
        let pullToRefresh: Driver<Void>
    }
    
    internal struct Output{
        let tableData: Driver<[ContactListCellData]>
        let error: Driver<String>
        let isLoading: Driver<Bool>
        let selectedIndex: Driver<(index: IndexPath, model: ContactListCellData)>
    }
    
    func transform(input: Input) -> Output {
        let fetchContactListErrorDetail = PublishSubject<String>()
        
        let fetchContactListTrigger = Driver.merge(input.viewDidLoad,input.pullToRefresh)
        
        let fetchContactList = fetchContactListTrigger
            .asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMapLatest { [service] _ -> Observable<[Contact]> in
                return service
                    .reactiveFetchContacts()
                    .do(onError: { err in
                        fetchContactListErrorDetail.onNext(err.localizedDescription)
                    })
            }
        
        let contactListCellData = fetchContactList
            .map { contacts -> [ContactListCellData] in
                return contacts.map { ContactListCellData(imageURL: $0.imageUrl, name: $0.name) }
            }
        
        let selectedIndex = input.didTapAtIndex
            .asObservable()
            .withLatestFrom(contactListCellData) { indexPath, models -> (index: IndexPath, model: ContactListCellData) in
                return (index: indexPath, model: models[indexPath.row])
            }
        
        let isFinishLoading = Observable.merge(
            fetchContactList.map {_ in true},
            contactListCellData.map {_ in false},
            fetchContactListErrorDetail.map {_ in false}
        )
        
        // MARK: - Output
        
        let ouputContactListCellData = contactListCellData.asDriver(onErrorJustReturn: [])
        let outputError = fetchContactListErrorDetail
            .asDriver(onErrorJustReturn: "")
            .filter { !$0.isEmpty }
        let outputSelectedIndex = selectedIndex.asDriver { _ in Driver.empty() }
        let outputIsLoading = isFinishLoading.asDriver(onErrorJustReturn: false)
        
        return Output(tableData: ouputContactListCellData,
                      error: outputError,
                      isLoading: outputIsLoading,
                      selectedIndex: outputSelectedIndex)
    }
}
