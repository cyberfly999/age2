//
//  UserProfile.swift
//  Age2
//
//  Created by Vinzenz Hehlen on 10.07.2026.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var nickname: String
    var name: String?
    var prename: String?
    var dateOfBirth: Date
    var timeOfBirth: Date
    var gender: String?
    var timeZoneIdentifier: String

    init(
        id: UUID = UUID(),
        nickname: String,
        name: String? = nil,
        prename: String? = nil,
        dateOfBirth: Date,
        timeOfBirth: Date,
        gender: String? = nil,
        timeZoneIdentifier: String = TimeZone.current.identifier
    ) {
        self.id = id
        self.nickname = nickname
        self.name = name
        self.prename = prename
        self.dateOfBirth = dateOfBirth
        self.timeOfBirth = timeOfBirth
        self.gender = gender
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}
