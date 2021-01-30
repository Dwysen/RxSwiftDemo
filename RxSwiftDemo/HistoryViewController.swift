//
//  HistoryViewController.swift
//  RxSwiftDemo
//
//  Created by irishsky on 2021/2/1.
//  Copyright © 2021 王彦森. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController {
    var tableView: UITableView!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    func setupTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height - 64)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        if let array = UserDefaults.standard.object(forKey: "history") as? Array<String> {
            let data = Observable.just(array)
            data.bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = element.self
                return cell
            }.disposed(by: disposeBag)
        }
    }
}
