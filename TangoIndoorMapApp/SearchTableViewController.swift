//
//  SearchTableViewController.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 08/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import UIKit

class SearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    
    private var height: CGFloat {
        return UIScreen.main.bounds.height - 40
    }
    
    var delegate: SimpleMessengerDelegate?
    
    var results = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        log.verbose("ViewDidLoad")
        let frame = CGRect(x:self.view.bounds.origin.x,
                               y:self.view.bounds.origin.y,
                               width:375,
                               height:height)
        tableView = UITableView(frame:frame, style: UITableViewStyle.plain)
        //        tableView = UITableView(frame:self.view.bounds, style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print("\(filteredAnimals), filteredAnimals.count: \(filteredAnimals.count)")
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = results[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = delegate else {
            return
        }
        delegate!.showSearchResult(result: results[indexPath.row])
        delegate!.isPopoverViewOn = false
        dismiss(animated: true, completion: nil)
    }
}
