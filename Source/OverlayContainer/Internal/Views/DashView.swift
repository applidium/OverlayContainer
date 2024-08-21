//
//  DashView.swift
//  
//
//  Created by VLADIMIR LEVTSOV on 26.07.2023.
//

import UIKit

public class DashView: UIView {

	public private(set) var dragIndicator = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		dragIndicator.translatesAutoresizingMaskIntoConstraints = false
		addSubview(dragIndicator)
		backgroundColor = .white
		dragIndicator.backgroundColor = .init(red: 233/255, green: 235/255, blue: 236/255, alpha: 1)
		NSLayoutConstraint.activate([
			dragIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			dragIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 11),
			dragIndicator.widthAnchor.constraint(equalToConstant: 80),
			dragIndicator.heightAnchor.constraint(equalToConstant: 3)
		])
		dragIndicator.layer.cornerRadius = 1.5

	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
