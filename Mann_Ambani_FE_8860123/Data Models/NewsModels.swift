//
//  NewsModels.swift
//  Mann_Ambani_FE_8860123
//
//  Created by user230729 on 12/5/23.
//

import Foundation

//this is news model  which is used for parsing and storing data

struct News: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

// MARK: - Article
struct Article: Codable {
    let source: Source?
    let author: String?
    let title, description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String?
}
