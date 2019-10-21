//
//  ContactListViewController.swift
//  ContactApp
//
//  Created by Ridho Pratama on 26/09/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class ContactListViewController: UIViewController {
    private let refreshControl = UIRefreshControl()
    
    private lazy var tableView: UITableView = { [refreshControl] in
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ContactListTableViewCell.self, forCellReuseIdentifier: ContactListTableViewCell.reuseIdentifier)
        tv.refreshControl = refreshControl
        tv.estimatedRowHeight = 80
        tv.rowHeight = 80
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    private let reactiveViewModel: ReactiveContactListViewModel
    
    private let disposeBag = DisposeBag()
    
    internal init() {
        self.reactiveViewModel = ReactiveContactListViewModel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupViewModel()
    }
    
    private func setupView() {
        title = "Contact List"
        
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
        let input = ReactiveContactListViewModel.Input(
            viewDidLoad: .just(()),
            didTapAtIndex: tableView.rx.itemSelected.asDriver(),
            pullToRefresh: refreshControl.rx.controlEvent(.allEvents).asDriver()
        )
        
        let output = reactiveViewModel.transform(input: input)
        
        output.tableData.drive(
           tableView.rx.items(
               cellIdentifier: ContactListTableViewCell.reuseIdentifier,
               cellType: ContactListTableViewCell.self
           )
       ) { _, data, cell in
          cell.configureCell(with: data)
       }.disposed(by: disposeBag)
        
        output.error.drive(onNext: { errorMessage in
            print(">>> \(errorMessage)")
        }).disposed(by: disposeBag)
        
        output.selectedIndex.drive(onNext: { (index, model) in
            print(">>> select at \(index) with model \(model)")
        }).disposed(by: disposeBag)
        
        output.isLoading.drive(refreshControl.rx.isRefreshing).disposed(by: disposeBag)
    }
}
