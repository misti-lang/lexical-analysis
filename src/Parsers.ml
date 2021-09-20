
exception IllegalArgument of string

(**
   Contains data parsed by a parser
 *)
type 'a parserSuccess = {
    data: 'a;
    startPos: int;
    endPos: int;
}

(**
   Contains the result of a parsing operation
*)
type 'a result =
| PSuccess of int * 'a parserSuccess
| PError of string

(**
   A parser takes an input and position, and returs a result
*)
type 'a parser = Parser of (string -> int -> 'a result)


(**
   Runs a parser with an input and a start position
   @param parser The parser to run
   @param input The input
   @param start The position from which start to parse
   @raise IllegalArgument - If start is less than 0
*)
let pRun parser input start =
    if start < 0 then
        raise (IllegalArgument "Tried to parse from negative position")
    else if start > Js.String.length input then
        PError "EOF"
    else
        let Parser(p) = parser in
        p input start


(**
   Parses a single character
   @param character A string with length 1 to parse
   @raise IllegalArgument If character is not a string of length 1
*)
let pChar character =
    if Js.String.length character <> 1 then
        raise (IllegalArgument "The parameter is not a string of length 1")
    else
        (* Precondition: start is a valid position *)
        Parser (fun input start -> 
            let c = Js.String.charAt start input in
            if c = character then
                let endPos = start + 1 in
                PSuccess (endPos, {
                    data = c;
                    startPos = start;
                    endPos = endPos;
                })
            else
                PError ("Expected character " ^ character ^ ", found " ^ c)
        )


(**
   Parses a string
   @param str The string to parse, of length > 0
   @raise IllegalArgument If str has a length of 0
*)
let pStr str =
    let strLength = Js.String.length str in
    if strLength == 0 then 
        raise (IllegalArgument "The string to parse is empty")
    else
        Parser (fun input start ->
            let remainingInput = Js.String.length input - start in
            if remainingInput < strLength then
                PError ("Expected string \"" ^ str ^ "\", not enough input found")
            else
                let testStr = Js.String.substring ~from:start ~to_:(start + strLength) input in
                if testStr = str then
                    let endPos = start + strLength in
                    PSuccess (endPos, {
                        data = testStr;
                        startPos = start;
                        endPos = endPos;
                    })
                else
                    PError ("Expected string \"" ^ str ^ "\", found \"" ^ testStr ^ "\"")
        )

(**
   Parses p1 and then p2. If any fail, the whole parser fails.
   @param p1 First parser
   @param p2 Second parser
*)
let pThen p1 p2 =
    Parser (fun input start ->
        match pRun p1 input start with
        | PError(reason) -> PError(reason)
        | PSuccess(next, data1) ->
            match pRun p2 input next with
            | PError(reason) -> PError(reason)
            | PSuccess(next, data2) -> PSuccess(next, {
                data = (data1.data, data2.data);
                startPos = start;
                endPos = next;
            })
    )

