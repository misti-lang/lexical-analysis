open Jest

describe("Test runP", () => {
    open Expect
    open Parsers
    let mockParser = Parser((_, _) => PError("mock"))

    test("throws with a negative start position", () => {
        expect(() => runP(mockParser, "", -1)) |> toThrow
    })

    test("doesn't throw with a zero position", () => {
        expect(() => runP(mockParser, "", 0)) |> not_ |> toThrow
    })

    test("doesn't throw with a positive position", () => {
        expect(() => runP(mockParser, "", 1)) |> not_ |> toThrow
    })
})

describe("Test parseCharacter", () => {
    open Expect
    open Parsers

    test("throws with an empty string", () => {
        expect(() => parseCharacter("")) |> toThrow
    })
})
