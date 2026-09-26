import Foundation
import Testing
@testable import CardFlow

@Suite("Add card request")
struct AddCardRequestTests {

    @Test("Valid input is normalized")
    func validInputIsNormalized() throws {
        let request = try #require(
            AddCardRequest(
                cardNumber: "4242 4242 4242 4242",
                expirationDate: "12/30",
                securityCode: "123",
                now: date(year: 2026, month: 9)
            )
        )

        #expect(request.cardNumber == "4242424242424242")
        #expect(request.last4 == "4242")
        #expect(request.formattedExpirationDate == "12/30")
        #expect(request.securityCode == "123")
    }

    @Test(
        "Invalid card numbers are rejected",
        arguments: [
            "4242 4242 4242 4241",
            "1111 1111 1111 1111",
            "4242"
        ]
    )
    func invalidCardNumbersAreRejected(_ cardNumber: String) {
        #expect(AddCardRequest.isValidCardNumber(cardNumber) == false)
    }

    @Test("Current expiration month is accepted")
    func currentExpirationMonthIsAccepted() {
        #expect(
            AddCardRequest.isValidExpirationDate(
                "09/26",
                now: date(year: 2026, month: 9)
            )
        )
    }

    @Test(
        "Invalid expiration dates are rejected",
        arguments: ["08/26", "13/30", "00/30", "123"]
    )
    func invalidExpirationDatesAreRejected(_ expirationDate: String) {
        #expect(
            AddCardRequest.isValidExpirationDate(
                expirationDate,
                now: date(year: 2026, month: 9)
            ) == false
        )
    }

    @Test("Security code accepts only three or four digits")
    func securityCodeLengthIsValidated() {
        #expect(AddCardRequest.isValidSecurityCode("123"))
        #expect(AddCardRequest.isValidSecurityCode("1234"))
        #expect(AddCardRequest.isValidSecurityCode("12") == false)
        #expect(AddCardRequest.isValidSecurityCode("12345") == false)
    }

    private func date(year: Int, month: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.date(from: DateComponents(year: year, month: month, day: 15)) ?? .distantPast
    }
}
