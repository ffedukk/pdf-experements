//
//  NetworkService.swift
//  pdf experements
//
//  Created by 18592232 on 08.02.2021.
//

import UIKit

class NetworkService {
	func fetch(url: URL, completion: @escaping (Result<DocumentModel,Error>) -> ()) {
		let session = URLSession(configuration: .default)
		
		session.dataTask(with: url) { (data, response, error) in
			completion(Result {
				if let err = error { throw err }
				guard let data = data else { throw networkError.NoDataError }
				print(data, response, error)
				if let documentModel = try? JSONDecoder().decode(DocumentModel.self, from: data) {
					return documentModel
				} else {
					print(try? JSONSerialization.jsonObject(with: data, options: []))
					throw networkError.DecodeError
				}
			})
		}.resume()
	}

	enum networkError: Error {
		case NoDataError
		case DecodeError
	}
}
