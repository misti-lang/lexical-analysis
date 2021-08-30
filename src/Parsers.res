
exception IllegalArgument(string)

/**
 * Contains data parsed by a parser
 */
type parserSuccess<'a> = {
    data: 'a,
    startPos: int,
    endPos: int,
}


/**
 * Contains the result of a parsing operation.
 */
type result<'a> =
| PSuccess('a)
| PError(string)


/**
 * A parser is a function that takes an input and a position
 * from where to start parsing, and returns a result
 */
type parser<'a> = Parser((string, int) => result<'a>)


/**
 * Runs a parser with an input and a start position
 * @param parser: parser - The parser to run
 * @param input: string - The string to parse
 * @param start: int - The position from where to parse. Must be >= 0
 * @throws IllegalArgument - If start is not >= 0
 */
let runP = (parser, input, start) => {
    if start < 0 {
        raise(IllegalArgument("Tried to parse from negative position."))
    }
    let Parser(p) = parser
    p(input, start)
}


/**
 * Parses a single character
 * @param character: string - A string with length 1 to parse
 * @returns A parser which parses a single character from a string
 * @throws IllegalArgument - If character is not a string of length 1
 */
let parseCharacter = (character) => {
    if Js.String.length(character) != 1 {
        raise(IllegalArgument("The parameter character is not a string of length 1."))
    }
    Parser((_, _) => {
        PError("stub")
    })
}

