open Jest

describe("Test pRun", () => {
    open Expect
    open Parsers
    let mockParser = Parser((_, _) => PError("mock"))

    test("throws with a negative start position", () => {
        expect(() => pRun(mockParser, "", -1)) |> toThrow
    })

    test("doesn't throw with a zero position", () => {
        expect(() => pRun(mockParser, "", 0)) |> not_ |> toThrow
    })

    test("doesn't throw with a positive position", () => {
        expect(() => pRun(mockParser, "", 1)) |> not_ |> toThrow
    })

    test("returns an error \"EOF\" when position > input length", () => {
        let reason =
            switch pRun(mockParser, "", 1) {
            | PSuccess(_) => ""
            | PError(reason) => reason
            }
        expect(reason) |> toBe("EOF")
    })
})

describe("Test pChar", () => {
    open Expect
    open Parsers

    test("throws with an empty string", () => {
        expect(() => pChar("")) |> toThrow
    })

    test("throws with a string with more than 1 character", () => {
        expect(() => pChar("ab")) |> toThrow
    })

    test("doesn't throw with an extended ascii char", () => {
        expect(() => pChar(`á`)) |> not_ |> toThrow
    })

    test("doesn't throw with an unicode char", () => {
        expect(() => pChar(`ト`)) |> not_ |> toThrow
    })

    test("returns PError when run with empty input", () => {
        let p = pChar("a")
        let isError = 
            switch pRun(p, "", 0) {
            | PSuccess(_) => false
            | PError(_) => true
            }

        expect(isError) |> toBe(true)
    })

    test("returns PError when doesn't find the required char", () => {
        let p = pChar("a")
        let isError = 
            switch pRun(p, "b", 0) {
            | PSuccess(_) => false
            | PError(_) => true
            }

        expect(isError) |> toBe(true)
    })

    test("returns PError with a message when doesn't find the required char", () => {
        let p = pChar("a")
        let reason = 
            switch pRun(p, "b", 0) {
            | PSuccess(_) => ""
            | PError(reason) => reason
            }

        expect(reason) |> toBe(`Expected character a, found b`)
    })

    test("parses an ascii char", () => {
        let p = pChar("a")
        let result =
            switch pRun(p, "a", 0) {
            | PSuccess(_, data) => data.data
            | PError(reason) => reason
            }
        expect(result) |> toBe("a")
    })

    test("parses an extended ascii char", () => {
        let p = pChar(`á`)
        let result =
            switch pRun(p, `á`, 0) {
            | PSuccess(_, data) => data.data
            | PError(reason) => reason
            }
        expect(result) |> toBe(`á`)
    })

    test("parses an unicode char", () => {
        let p = pChar(`テ`)
        let result =
            switch pRun(p, `テ`, 0) {
            | PSuccess(_, data) => data.data
            | PError(reason) => reason
            }
        expect(result) |> toBe(`テ`)
    })
})

describe("Test pStr", () => {
    open Expect
    open Parsers

    test("throws with an empty string", () => {
        expect(() => pStr("")) |> toThrow
    })

    test("returns PError when run with an empty string", () => {
        let p = pStr("a")
        let isError = 
            switch pRun(p, "", 0) {
            | PSuccess(_) => false
            | PError(_) => true
            }

        expect(isError) |> toBe(true)
    })

    test("returns PError when the length of the string to parse is less than the remaining input", () => {
        let p = pStr("hello")
        let errorMessage = 
            switch pRun(p, "hell", 0) {
            | PSuccess(_) => ""
            | PError(reason) => reason
            }

        expect(errorMessage) |> toBe("Expected string \"hello\", not enough input found")
    })

    test("returns PError when doesn't find the required string", () => {
        let p = pStr("a")
        let errorMessage = 
            switch pRun(p, "b", 0) {
            | PSuccess(_) => ""
            | PError(reason) => reason
            }

        expect(errorMessage) |> toBe(`Expected string "a", found "b"`)
    })

    test("parses a string", () => {
        let p = pStr("hello")
        let result =
            switch pRun(p, "hello world", 0) {
            | PSuccess(_, data) => data.data
            | PError(reason) => reason
            }
        expect(result) |> toBe("hello")
    })

    test("parses a string and returns the next position", () => {
        let p = pStr("hello")
        let result =
            switch pRun(p, "hello world", 0) {
            | PSuccess(pos, _) => pos
            | PError(_) => -1
            }
        expect(result) |> toBe(5)
    })
})

describe("Test pThen", () => {
    open Expect
    open Parsers

    let p1 = pChar("x")
    let p2 = pStr("ray")

    test("fails if parser1 fails", () => {
        let p = pThen(p1 , p2)
        expect(true) |> toBe(false)
    })
})
