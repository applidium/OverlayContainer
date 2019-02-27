//
//  SearchViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 29/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewControllerDidSelectARow(_ searchViewController: SearchViewController)
    func searchViewControllerDidSelectCloseAction(_ searchViewController: SearchViewController)
}

class SearchViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    DetailHeaderViewDelegate {

    weak var delegate: SearchViewControllerDelegate?

    private let showsCloseAction: Bool
    private(set) lazy var header = Bundle.main.loadNibNamed("DetailHeaderView", owner: self, options: nil)![0] as! DetailHeaderView
    private(set) lazy var tableView = UITableView()

    // MARK: - Life Cycle

    init(showsCloseAction: Bool) {
        self.showsCloseAction = showsCloseAction
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func loadView() {
        view = UIView()
        setUpView()
        title = "Search"
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Row \(indexPath.row)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchViewControllerDidSelectARow(self)
    }

    // MARK: - DetailHeaderViewDelegate

    func detailHeaderViewDidSelectCloseAction(_ headerView: DetailHeaderView) {
        delegate?.searchViewControllerDidSelectCloseAction(self)
    }

    // MARK: - Private

    private func setUpView() {
        header.delegate = self
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(header)
        header.heightAnchor.constraint(equalToConstant: 70).isActive = true
        header.pinToSuperview(edges: [.left, .right])
        if #available(iOS 11.0, *) {
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            header.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        }
        header.showsCloseAction = showsCloseAction
        tableView.dataSource = self
        tableView.pinToSuperview(edges: [.left, .right, .bottom])
        tableView.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        tableView.delegate = self
    }
}
