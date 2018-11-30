//
//  DetailViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 29/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let header = UIView()
    let tableView = UITableView()

    override func loadView() {
        view = UIView()
        view.addSubview(tableView)
        view.addSubview(header)
        header.backgroundColor = .green
        header.heightAnchor.constraint(equalToConstant: 80).isActive = true
        header.pinToSuperview(edges: [.top, .left, .right])
        tableView.dataSource = self
        tableView.pinToSuperview()
        tableView.delegate = self
        tableView.scrollsToTop = false
        tableView.contentInsetAdjustmentBehavior = .never
    }

    var initialSetup = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !initialSetup else { return }
        initialSetup = true
        tableView.contentInset.top = header.frame.height
        tableView.contentOffset.y = -header.frame.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(indexPath.row)"
        cell.contentView.backgroundColor = .red
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
