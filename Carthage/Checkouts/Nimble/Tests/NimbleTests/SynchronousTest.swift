import Foundation
import XCTest
import Nimble

final class SynchronousTest: XCTestCase, XCTestCaseProvider {
    class Error: Swift.Error {}
    let errorToThrow = Error()

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testFailAlwaysFails() {
        failsWithErrorMessage("My error message") {
            fail("My error message")
        }
        failsWithErrorMessage("fail() always fails") {
            fail()
        }
    }

    func testUnexpectedErrorsThrownFails() {
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.to(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toNot(equal(1))
        }
    }

    func testToMatchesIfMatcherReturnsTrue() {
        expect(1).to(MatcherFunc { _, _ in true })
        expect {1}.to(MatcherFunc { _, _ in true })

        expect(1).to(MatcherFunc { _, _ in true }.predicate)
        expect {1}.to(MatcherFunc { _, _ in true }.predicate)

        expect(1).to(Predicate.simple("match") { _ in .matches })
        expect {1}.to(Predicate.simple("match") { _ in .matches })
    }

    func testToProvidesActualValueExpression() {
        var value: Int?
        expect(1).to(MatcherFunc { expr, _ in value = try expr.evaluate(); return true })
        expect(value).to(equal(1))
    }

    func testToProvidesAMemoizedActualValueExpression() {
        var callCount = 0
        expect { callCount += 1 }.to(MatcherFunc { expr, _ in
            _ = try expr.evaluate()
            _ = try expr.evaluate()
            return true
        })
        expect(callCount).to(equal(1))
    }

    func testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        var callCount = 0
        expect { callCount += 1 }.to(MatcherFunc { expr, _ in
            expect(callCount).to(equal(0))
            _ = try expr.evaluate()
            return true
        })
        expect(callCount).to(equal(1))
    }

    func testToMatchAgainstLazyProperties() {
        expect(ObjectWithLazyProperty().value).to(equal("hello"))
        expect(ObjectWithLazyProperty().value).toNot(equal("world"))
        expect(ObjectWithLazyProperty().anotherValue).to(equal("world"))
        expect(ObjectWithLazyProperty().anotherValue).toNot(equal("hello"))
    }

    // repeated tests from to() for toNot()
    func testToNotMatchesIfMatcherReturnsTrue() {
        expect(1).toNot(MatcherFunc { _, _ in false })
        expect {1}.toNot(MatcherFunc { _, _ in false })

        expect(1).toNot(MatcherFunc { _, _ in false }.predicate)
        expect {1}.toNot(MatcherFunc { _, _ in false }.predicate)

        expect(1).toNot(Predicate.simple("match") { _ in .doesNotMatch })
        expect {1}.toNot(Predicate.simple("match") { _ in .doesNotMatch })
    }

    func testToNotProvidesActualValueExpression() {
        var value: Int?
        expect(1).toNot(MatcherFunc { expr, _ in value = try expr.evaluate(); return false })
        expect(value).to(equal(1))
    }

    func testToNotProvidesAMemoizedActualValueExpression() {
        var callCount = 0
        expect { callCount += 1 }.toNot(MatcherFunc { expr, _ in
            _ = try expr.evaluate()
            _ = try expr.evaluate()
            return false
        })
        expect(callCount).to(equal(1))
    }

    func testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        var callCount = 0
        expect { callCount += 1 }.toNot(MatcherFunc { expr, _ in
            expect(callCount).to(equal(0))
            _ = try expr.evaluate()
            return false
        })
        expect(callCount).to(equal(1))
    }

    func testToNegativeMatches() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(MatcherFunc { _, _ in false })
        }
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(MatcherFunc { _, _ in false }.predicate)
        }
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Predicate.simple("match") { _ in .doesNotMatch })
        }
    }

    func testToNotNegativeMatches() {
        failsWithErrorMessage("expected to not match, got <1>") {
            expect(1).toNot(MatcherFunc { _, _ in true })
        }
        failsWithErrorMessage("expected to not match, got <1>") {
            expect(1).toNot(MatcherFunc { _, _ in true }.predicate)
        }
        failsWithErrorMessage("expected to not match, got <1>") {
            expect(1).toNot(Predicate.simple("match") { _ in .matches })
        }
    }

    func testNotToMatchesLikeToNot() {
        expect(1).notTo(MatcherFunc { _, _ in false })
        expect(1).notTo(MatcherFunc { _, _ in false }.predicate)
        expect(1).notTo(Predicate.simple("match") { _ in .doesNotMatch })
    }
}
