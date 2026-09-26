//
//  AddCardRequest.swift
//  CardFlow
//

import Foundation

struct AddCardRequest: Sendable {

    let cardNumber: String
    let expirationMonth: Int
    let expirationYear: Int
    let securityCode: String

    init?(
        cardNumber: String,
        expirationDate: String,
        securityCode: String,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let normalizedNumber = Self.digits(in: cardNumber)
        let normalizedSecurityCode = Self.digits(in: securityCode)

        guard Self.isValidCardNumber(normalizedNumber),
              let expiration = Self.expirationComponents(
                from: expirationDate,
                now: now,
                calendar: calendar
              ),
              Self.isValidSecurityCode(normalizedSecurityCode) else {
            return nil
        }

        self.cardNumber = normalizedNumber
        expirationMonth = expiration.month
        expirationYear = expiration.year
        self.securityCode = normalizedSecurityCode
    }

    var last4: String {
        String(cardNumber.suffix(4))
    }

    var formattedExpirationDate: String {
        String(format: "%02d/%02d", expirationMonth, expirationYear % 100)
    }

    static func digits(in value: String) -> String {
        String(value.filter(\.isNumber))
    }

    static func isValidCardNumber(_ value: String) -> Bool {
        let number = digits(in: value)

        guard (13...19).contains(number.count),
              Set(number).count > 1 else {
            return false
        }

        let checksum = number.reversed().enumerated().reduce(into: 0) { result, item in
            let (index, character) = item
            guard var digit = character.wholeNumberValue else { return }

            if index.isMultiple(of: 2) == false {
                digit *= 2

                if digit > 9 {
                    digit -= 9
                }
            }

            result += digit
        }

        return checksum.isMultiple(of: 10)
    }

    static func isValidExpirationDate(
        _ value: String,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        expirationComponents(from: value, now: now, calendar: calendar) != nil
    }

    static func isValidSecurityCode(_ value: String) -> Bool {
        let code = digits(in: value)
        return (3...4).contains(code.count)
    }

    private static func expirationComponents(
        from value: String,
        now: Date,
        calendar: Calendar
    ) -> (month: Int, year: Int)? {
        let expiration = digits(in: value)

        guard expiration.count == 4,
              let month = Int(expiration.prefix(2)),
              let shortYear = Int(expiration.suffix(2)),
              (1...12).contains(month) else {
            return nil
        }

        let year = 2000 + shortYear
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        guard year > currentYear || (year == currentYear && month >= currentMonth) else {
            return nil
        }

        return (month, year)
    }
}
