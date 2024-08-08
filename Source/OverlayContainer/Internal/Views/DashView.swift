//
//  DashView.swift
//  
//
//  Created by VLADIMIR LEVTSOV on 26.07.2023.
//

import UIKit

class DashView: UIView {

	private let dashView = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		dashView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(dashView)
		backgroundColor = .white
		dashView.backgroundColor = .init(red: 233/255, green: 235/255, blue: 236/255, alpha: 1)
		NSLayoutConstraint.activate([
			dashView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			dashView.topAnchor.constraint(equalTo: self.topAnchor, constant: 11),
			dashView.widthAnchor.constraint(equalToConstant: 80),
			dashView.heightAnchor.constraint(equalToConstant: 3),
			dashView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6)
		])
		dashView.layer.cornerRadius = 1.5

	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
