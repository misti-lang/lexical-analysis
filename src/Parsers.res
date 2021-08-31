
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
 * PSuccess(position, data) - the data 'a and the next position in the input
 * PError(reason) - reason for failure
 */
type result<'a> =
| PSuccess(int, 'a)
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
 * @throws IllegalArgument - If start is less than 0
 */
let runP = (parser, input, start) => {
    if start < 0 {
        raise(IllegalArgument("Tried to parse from negative position."))
    } else if (start > String.length(input)) {
        PError("EOF")
    } else {
        let Parser(p) = parser
        p(input, start)
    }
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
    // Precondition: start is a valid position
    Parser((input, start) => {
        let c = Js.String.charAt(start, input)
        if c == character {
            PSuccess(start + 1, {
                data: c,
                startPos: start,
                endPos: start + 1,
            })
        } else {
            PError(`Expected character ${character}, found ${c}`)
        }
    })
}

