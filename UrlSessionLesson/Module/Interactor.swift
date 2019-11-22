//
//  Interactor.swift
//  UrlSessionLesson
//
//  Created by Константин Богданов on 06/11/2019.
//  Copyright © 2019 Константин Богданов. All rights reserved.
//

import UIKit
import CoreData

protocol InteractorInput {
    func loadImage(at path: String, completion: @escaping (UIImage?) -> Void)
    func loadImageList(by searchString: String, completion: @escaping ([ImageModel]) -> Void)
    func loadImageFromDb(completion: @escaping ([ImageViewModel]?) -> Void)
}

class Interactor: InteractorInput {
    let networkService: NetworkServiceInput
    
    init(networkService: NetworkServiceInput) {
        self.networkService = networkService
    }
    
    func loadImageFromDb(completion: @escaping ([ImageViewModel]?) -> Void) {
        let stack = CoreDataStack.shared
        
        stack.persistentContainer.performBackgroundTask { (context) in
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "RepImage")
            //fetchRequest.sortDescriptors = [] //optionally you can specify the order in which entities should ordered after fetch finishes
            let results = try! context.fetch(fetchRequest)
            let res = results as! [RepImage]
            var lol: [ImageViewModel] = []
            for im in res {
                lol.append(ImageViewModel(description: im.title!, image: UIImage(data: im.image!)!))
            }
            completion(lol)
        }
    }
    
    
    func loadImage(at path: String, completion: @escaping (UIImage?) -> Void) {
        networkService.getData(at: path, parameters: nil) { data in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
    }
    
    func loadImageList(by searchString: String, completion: @escaping ([ImageModel]) -> Void) {
        let url = API.searchPath(text: searchString, extras: "url_m")
        networkService.getData(at: url) { data in
            guard let data = data else {
                completion([])
                return
            }
            let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: .init()) as? Dictionary<String, Any>
            
            guard let response = responseDictionary,
                let photosDictionary = response["photos"] as? Dictionary<String, Any>,
                let photosArray = photosDictionary["photo"] as? [[String: Any]] else {
                    completion([])
                    return
            }
            
            let models = photosArray.map { (object) -> ImageModel in
                let urlString = object["url_m"] as? String ?? ""
                let	title = object["title"] as? String ?? ""
                self.loadImage(at: urlString) { [weak self] image in
                    guard let image = image else {
                        return
                    }
                    self!.saveDb(title: title, image: image)
                }
                return ImageModel(path: urlString, description: title)
            }
            completion(models)
        }
    }
    
    func saveDb(title:String, image: UIImage){
        let stack = CoreDataStack.shared
        print(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last!);
        stack.persistentContainer.performBackgroundTask { (context) in
            let im = RepImage(context: context)
            im.title = title
            im.image = image.pngData()
            try! context.save()
        }
    }
}
