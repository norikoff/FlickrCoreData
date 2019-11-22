//
//  ViewController.swift
//  UrlSessionLesson
//
//  Created by Константин Богданов on 06/11/2019.
//  Copyright © 2019 Константин Богданов. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	let tableView = UITableView()
	var images: [ImageViewModel] = []
	let reuseId = "UITableViewCellreuseId"
	let interactor: InteractorInput

	init(interactor: InteractorInput) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}
	required init?(coder: NSCoder) {
		fatalError("Метод не реализован")
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
			tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
		tableView.dataSource = self
		loadImage()
		search(by: "cat")
	}

	private func loadImage() {
		let imagePath = "http://s16.stc.all.kpcdn.net/share/i/12/11048313/inx960x640.jpg"
		interactor.loadImage(at: imagePath) { [weak self] image in
			if let image = image {
				let model = ImageViewModel(description: "Тестовая картинка", image: image)
				self?.images = [model]
				DispatchQueue.main.async {
					self?.tableView.reloadData()
				}
			}
		}
	}

	private func search(by searchString: String) {
        let group = DispatchGroup()
        group.enter()
		interactor.loadImageList(by: searchString) { [weak self] models in
            group.enter()
            self!.interactor.loadImageFromDb(completion: { (im) in
                self?.images = im!
                group.leave()
            })
            group.leave()
		}
        group.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
        }
	}

//    private func loadImages(with models: [ImageModel]) {
//        let models = models.suffix(10)
//
//        let group = DispatchGroup()
//        for model in models {
//            print(model.path)
//            group.enter()
//            interactor.loadImage(at: model.path) { [weak self] image in
//                guard let image = image else {
//                    group.leave()
//                    return
//                }
//                self!.interactor.loadImageFromDb(completion: { (arr) in
//                    self?.images = arr!
//                })
////                self?.images.append(viewModel)
//                group.leave()
//            }
//
//        }
//
//        group.notify(queue: DispatchQueue.main) {
//            self.tableView.reloadData()
//        }
//    }
}

extension ViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return images.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
		let model = images[indexPath.row]
		cell.imageView?.image = model.image
		cell.textLabel?.text = model.description
		return cell
	}
}
