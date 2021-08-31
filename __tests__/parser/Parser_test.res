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

    test("returns an error \"EOF\" when position > input length", () => {
        let reason =
            switch runP(mockParser, "", 1) {
            | PSuccess(_) => ""
            | PError(reason) => reason
            }
        expect(reason) |> toBe("EOF")
    })
})

describe("Test parseCharacter", () => {
    open Expect
    open Parsers

    test("throws with an empty string", () => {
        expect(() => parseCharacter("")) |> toThrow
    })

    test("throws with a string with more than 1 character", () => {
        expect(() => parseCharacter("ab")) |> toThrow
    })

    test("doesn't throw with an extended ascii char", () => {
        expect(() => parseCharacter(`á`)) |> not_ |> toThrow
    })

    test("doesn't throw with an unicode char", () => {
        expect(() => parseCharacter(`ト`)) |> not_ |> toThrow
    })

    test("returns PError when run with empty input", () => {
        let p = parseCharacter("a")
        let isError = 
            switch runP(p, "", 0) {
            | PSuccess(_) => false
            | PError(_) => true
            }

        expect(isError) |> toBe(true)
    })

    test("returns PError when doesn't find the required char", () => {
        let p = parseCharacter("a")
        let isError = 
            switch runP(p, "b", 0) {
            | PSuccess(_) => false
            | PError(_) => true
            }

        expect(isError) |> toBe(true)
    })

    test("returns PError with a message when doesn't find the required char", () => {
        let p = parseCharacter("a")
        let reason = 
            switch runP(p, "b", 0) {
            | PSuccess(_) => ""
            | PError(reason) => reason
            }

        expect(reason) |> toBe(`Expected character a, found b`)
    })

    test("parses an ascii char", () => {
        let p = parseCharacter("a")
        let result =
            switch runP(p, "a", 0) {
            | PSuccess(_, data) => data.data
            | PError(reason) => reason
            }
        expect(result) |> toBe("a")
    })

    test("parses an extended ascii char", () => {
        let p = parseCharacter(`á`)
        let result =
            switch runP(p, `á`, 0) {
            | PSuccess(_, data) => data.data
            | PError(reason) => reason
            }
        expect(result) |> toBe(`á`)
    })

    test("parses an unicode char", () => {
        let p = parseCharacter(`テ`)
        let result =
            switch runP(p, `テ`, 0) {
            | PSuccess(_, data) => data.data
            | PError(reason) => reason
            }
        expect(result) |> toBe(`テ`)
    })
})
