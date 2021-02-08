//
//  DocumentModel.swift
//  pdf experements
//
//  Created by 18592232 on 08.02.2021.
//

import Foundation

class DocumentModel: Codable {
	let id, title, descriptionHeader, descriptionBody: String?
	let url: String?
	let textFragment, code: String?
	let ratingAverage: String?
	let ratingVotes: String?
	let disciplines, comments: [String?]

	init(id: String?, title: String?, descriptionHeader: String?, descriptionBody: String?,
		 url: String?, textFragment: String?, code: String?, ratingAverage: String?, ratingVotes: String?,
		 disciplines: [String?], comments: [String?]) {
		self.id = id
		self.title = title
		self.descriptionHeader = descriptionHeader
		self.descriptionBody = descriptionBody
		self.url = url
		self.textFragment = textFragment
		self.code = code
		self.ratingAverage = ratingAverage
		self.ratingVotes = ratingVotes
		self.disciplines = disciplines
		self.comments = comments
	}
}
