//
//  User.swift
//  HoneyWell_Task
//
//  Created by Rahul Jamba on 20/02/26.
//


import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let email: String
    let phone: String
}
