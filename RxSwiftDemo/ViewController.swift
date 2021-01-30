//
//  ViewController.swift

//  Created by irishsky on 2021/1/31.
//  Copyright © 2021 王彦森. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
class ViewController: UIViewController {
    
    var timer: Observable<Int>!
    var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavigation()
        setupTableView()
        bindData()
        setupTimer()
    }
    
    func setupNavigation() {
        let item=UIBarButtonItem(title: "api调用纪录", style: UIBarButtonItem.Style.plain, target: self, action: #selector(pushToHistoryTable))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc func pushToHistoryTable() {
        let vc = HistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height - 64)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
    }
    
    func bindData() {
        let networkData = UserDefaults.standard.object(forKey: "networkData")
        if (networkData != nil) {
            let data = Observable.just(networkData as! [String:String])
            data.bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(element.key)：\(element.value)"
                return cell
            }.disposed(by: disposeBag)
        }
    }
    
    func setupTimer(){
        timer = Observable<Int>.interval(DispatchTimeInterval.seconds(5), scheduler: MainScheduler.init())
        timer.subscribe(onNext: { [weak self] (num) in
            self?.getNetWorkData()
        })
            .disposed(by: disposeBag)
    }
    
    func getNetWorkData() {
        let urlString = "https://api.github.com/"
        let url = URL(string:urlString)
        let request = URLRequest(url: url!)
        let networkData = URLSession.shared.rx.json(request: request)
            .map{ [weak self] result -> [String: String] in
                if let data = result as? [String: String] {
                    UserDefaults.standard.set(data, forKey: "networkData")
                    self?.saveByUserDefault()
                    return data
                } else {
                    return ["":""]
                }
        }.catchErrorJustReturn(["error":"1009"])
        tableView.dataSource = nil
        networkData.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element.key)：\(element.value)"
            return cell
        }.disposed(by: disposeBag)
    }
    
    func saveByUserDefault() {
        if var array = UserDefaults.standard.object(forKey: "history") as? Array<String> {
            array.append(currentTime())
            UserDefaults.standard.set(array, forKey: "history")
            
        } else {
            let array = [currentTime()]
            UserDefaults.standard.set(array, forKey: "history")
        }
    }
    
    func currentTime() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateformatter.string(from: Date())
    }
}

