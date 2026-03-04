//
//  Strings.swift
//  AppGalery
//
//  Created by Ангелина Голубовская on 3.03.26.
//

import Foundation

enum L10n {
    static let galleryTitle = NSLocalizedString("gallery.title", comment: "")
    static let favoritesTitle = NSLocalizedString("favorites.title", comment: "")
    static let detailsTitle = NSLocalizedString("details.title", comment: "")
    static let unknownAuthor = NSLocalizedString("common.unknownAuthor", comment: "")

    static let errorTitle = NSLocalizedString("error.title", comment: "")
    static let errorDefaultMessage = NSLocalizedString("error.defaultMessage", comment: "")
    static let retry = NSLocalizedString("error.retry", comment: "")

    static let detailsNoTitle = NSLocalizedString("details.noTitle", comment: "")
    static let detailsNoDescription = NSLocalizedString("details.noDescription", comment: "")
    static let detailsUnknownDate = NSLocalizedString("details.unknownDate", comment: "")

    static func authorLine(_ author: String, _ date: String) -> String {
        let format = NSLocalizedString("details.authorLine", comment: "")
        return String(format: format, author, date)
    }
}
