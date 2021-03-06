module ParserSpec
    ( parser
    ) where

import Control.Exception
import Test.Hspec

import Parser
import Lexer

parser = describe "parser" $ do
    expression
    statement
    program

expression = describe "Expression_" $ do
    describe "literal integer" $ do
        it "should return an integer expression" $ do
            let res = parseExpression . scanTokens $
                    "123"
            res `shouldBe` SappExpLitInteger 123

    describe "literal boolean" $ do
        it "should return a True boolean expression" $ do
            let res = parseExpression . scanTokens $
                    "true"
            res `shouldBe` SappExpLitBoolean True

        it "should return a False boolean expression" $ do
            let res = parseExpression . scanTokens $
                    "false"
            res `shouldBe` SappExpLitBoolean False

    describe "variable" $ do
        it "should parse a variable as an expression" $ do
            let res = parseExpression . scanTokens $
                    "flag"
            res `shouldBe` SappExpVariable (SappVar "flag")

    describe "parentheses" $ do
        it "should ignore parentheses" $ do
            let res = parseExpression . scanTokens $
                    "(84)"
            res `shouldBe` SappExpLitInteger 84

        it "should reject an unmatched left parenthesis" $ do
            let res = parseExpression . scanTokens $
                    "(84"
            evaluate res `shouldThrow` anyErrorCall

        it "should reject an unmatched right parenthesis" $ do
            let res = parseExpression . scanTokens $
                    "84)"
            evaluate res `shouldThrow` anyErrorCall

    describe "operators" $ do
        describe "addition" $ do
            it "should parse an addition as an expression" $ do
                let res = parseExpression . scanTokens $
                        "+ left right"
                res `shouldBe` SappExpAddition (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate integer literals" $ do
                let res = parseExpression . scanTokens $
                        "+ 7 3"
                res `shouldBe` SappExpLitInteger 10

        describe "substraction" $ do
            it "should parse a substraction as an expression" $ do
                let res = parseExpression . scanTokens $
                        "- left right"
                res `shouldBe` SappExpSubtraction (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate integer literals" $ do
                let res = parseExpression . scanTokens $
                        "- 7 3"
                res `shouldBe` SappExpLitInteger 4

        describe "multiplication" $ do
            it "should parse a multiplication as an expression" $ do
                let res = parseExpression . scanTokens $
                        "* left right"
                res `shouldBe` SappExpMultiplication (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate integer literals" $ do
                let res = parseExpression . scanTokens $
                        "* 7 3"
                res `shouldBe` SappExpLitInteger 21

        describe "division" $ do
            it "should parse a division as an expression" $ do
                let res = parseExpression . scanTokens $
                        "/ left right"
                res `shouldBe` SappExpDivision (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate integer literals" $ do
                let res = parseExpression . scanTokens $
                        "/ 7 3"
                res `shouldBe` SappExpLitInteger 2

            it "should not evaluate literals when right operand is 0" $ do
                let res = parseExpression . scanTokens $
                        "/ 7 0"
                res `shouldBe` SappExpDivision (SappExpLitInteger 7) (SappExpLitInteger 0)

        describe "modulo" $ do
            it "should parse a modulo as an expression" $ do
                let res = parseExpression . scanTokens $
                        "% left right"
                res `shouldBe` SappExpModulo (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate integer literals" $ do
                let res = parseExpression . scanTokens $
                        "% 7 3"
                res `shouldBe` SappExpLitInteger 1

            it "should not evaluate literals when right operand is 0" $ do
                let res = parseExpression . scanTokens $
                        "% 7 0"
                res `shouldBe` SappExpModulo (SappExpLitInteger 7) (SappExpLitInteger 0)

        describe "exponentiation" $ do
            it "should parse an exponentiation as an expression" $ do
                let res = parseExpression . scanTokens $
                        "^ left right"
                res `shouldBe` SappExpExponentiation (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate integer literals" $ do
                let res = parseExpression . scanTokens $
                        "^ 7 3"
                res `shouldBe` SappExpLitInteger 343

            it "should not evaluate literals when right operand is negative" $ do
                let res = parseExpression . scanTokens $
                        "^ 7 ~ 2"
                res `shouldBe` SappExpExponentiation (SappExpLitInteger 7) (SappExpLitInteger (-2))

        describe "integer negation" $ do
            it "should parse a negation as an expression" $ do
                let res = parseExpression . scanTokens $
                        "~ val"
                res `shouldBe` SappExpIntNegation (SappExpVariable (SappVar "val"))

            it "should evaluate positive literal" $ do
                let res = parseExpression . scanTokens $
                        "~ 5"
                res `shouldBe` SappExpLitInteger (-5)
            it "should evaluate negated literal" $ do
                let res = parseExpression . scanTokens $
                        "~ ~ 5"
                res `shouldBe` SappExpLitInteger 5

        describe "conjuction" $ do
            it "should parse a conjuction as an expression" $ do
                let res = parseExpression . scanTokens $
                        "or left right"
                res `shouldBe` SappExpConjuction (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate boolean literals" $ do
                let res = parseExpression . scanTokens $
                        "or false true"
                res `shouldBe` SappExpLitBoolean True

        describe "disjunction" $ do
            it "should parse a disjunction as an expression" $ do
                let res = parseExpression . scanTokens $
                        "and left right"
                res `shouldBe` SappExpDisjunction (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate boolean literals" $ do
                let res = parseExpression . scanTokens $
                        "and false true"
                res `shouldBe` SappExpLitBoolean False

        describe "negation" $ do
            it "should parse a negation as an expression" $ do
                let res = parseExpression . scanTokens $
                        "not val"
                res `shouldBe` SappExpNegation (SappExpVariable (SappVar "val"))

            it "should evaluate true literal" $ do
                let res = parseExpression . scanTokens $
                        "not true"
                res `shouldBe` SappExpLitBoolean False
            it "should evaluate false literal" $ do
                let res = parseExpression . scanTokens $
                        "not false"
                res `shouldBe` SappExpLitBoolean True

        describe "equals to" $ do
            it "should parse an equals to as an expression" $ do
                let res = parseExpression . scanTokens $
                        "= left right"
                res `shouldBe` SappExpEqualsTo (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            describe "should evaluate integer literals" $ do
                it "should evaluate equals to true" $ do
                    let res = parseExpression . scanTokens $
                            "= 1 1"
                    res `shouldBe` SappExpLitBoolean True

                it "should evaluate unequals to false" $ do
                    let res = parseExpression . scanTokens $
                            "= 1 2"
                    res `shouldBe` SappExpLitBoolean False

            describe "should evaluate boolean literals" $ do
                it "should evaluate equals to true" $ do
                    let res = parseExpression . scanTokens $
                            "= false false"
                    res `shouldBe` SappExpLitBoolean True

                it "should evaluate unequals to false" $ do
                    let res = parseExpression . scanTokens $
                            "= true false"
                    res `shouldBe` SappExpLitBoolean False

        describe "different from" $ do
            it "should parse an different from as an expression" $ do
                let res = parseExpression . scanTokens $
                        "/= left right"
                res `shouldBe` SappExpDifferentFrom (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            describe "should evaluate integer literals" $ do
                it "should evaluate unequals to true" $ do
                    let res = parseExpression . scanTokens $
                            "/= 1 2"
                    res `shouldBe` SappExpLitBoolean True

                it "should evaluate equals to false" $ do
                    let res = parseExpression . scanTokens $
                            "/= 1 1"
                    res `shouldBe` SappExpLitBoolean False

            describe "should evaluate boolean literals" $ do
                it "should evaluate equals to true" $ do
                    let res = parseExpression . scanTokens $
                            "/= false true"
                    res `shouldBe` SappExpLitBoolean True

                it "should evaluate unequals to false" $ do
                    let res = parseExpression . scanTokens $
                            "/= true true"
                    res `shouldBe` SappExpLitBoolean False

        describe "greater than" $ do
            it "should parse an greater than as an expression" $ do
                let res = parseExpression . scanTokens $
                        "> left right"
                res `shouldBe` SappExpGreaterThan (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            describe "should evaluate integer literals" $ do
                it "should evaluate greater to true" $ do
                    let res = parseExpression . scanTokens $
                            "> 2 1"
                    res `shouldBe` SappExpLitBoolean True

                it "should evaluate equal to false" $ do
                    let res = parseExpression . scanTokens $
                            "> 1 1"
                    res `shouldBe` SappExpLitBoolean False

                it "should evaluate less to false" $ do
                    let res = parseExpression . scanTokens $
                            "> 0 1"
                    res `shouldBe` SappExpLitBoolean False

        describe "greater than or equal to" $ do
            it "should parse an greater than or equal to as an expression" $ do
                let res = parseExpression . scanTokens $
                        ">= left right"
                res `shouldBe` SappExpGreaterThanOrEqualsTo (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            describe "should evaluate integer literals" $ do
                it "should evaluate greater to true" $ do
                    let res = parseExpression . scanTokens $
                            ">= 2 1"
                    res `shouldBe` SappExpLitBoolean True

                it "should evaluate equal to true" $ do
                    let res = parseExpression . scanTokens $
                            ">= 1 1"
                    res `shouldBe` SappExpLitBoolean True

                it "should evaluate less to false" $ do
                    let res = parseExpression . scanTokens $
                            ">= 0 1"
                    res `shouldBe` SappExpLitBoolean False

        describe "less than" $ do
            it "should parse an less than as an expression" $ do
                let res = parseExpression . scanTokens $
                        "< left right"
                res `shouldBe` SappExpLessThan (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate less to true" $ do
                let res = parseExpression . scanTokens $
                        "< 0 1"
                res `shouldBe` SappExpLitBoolean True

            it "should evaluate equal to false" $ do
                let res = parseExpression . scanTokens $
                        "< 1 1"
                res `shouldBe` SappExpLitBoolean False

            it "should evaluate greater to false" $ do
                let res = parseExpression . scanTokens $
                        "< 2 1"
                res `shouldBe` SappExpLitBoolean False

        describe "less than or equal to" $ do
            it "should parse an less than or equal to as an expression" $ do
                let res = parseExpression . scanTokens $
                        "<= left right"
                res `shouldBe` SappExpLessThanOrEqualsTo (SappExpVariable (SappVar "left")) (SappExpVariable (SappVar "right"))

            it "should evaluate less to true" $ do
                let res = parseExpression . scanTokens $
                        "<= 0 1"
                res `shouldBe` SappExpLitBoolean True

            it "should evaluate equal to true" $ do
                let res = parseExpression . scanTokens $
                        "<= 1 1"
                res `shouldBe` SappExpLitBoolean True

            it "should evaluate greater to false" $ do
                let res = parseExpression . scanTokens $
                        "<= 2 1"
                res `shouldBe` SappExpLitBoolean False

statement = describe "Statement_" $ do
    describe "block" $ do
        it "should parse an empty block" $ do
            let res = parseStatement . scanTokens $
                    "begin end"
            res `shouldBe` SappStmtBlock []

        it "should parse nested blocks" $ do
            let res = parseStatement . scanTokens $
                    "begin\n" ++
                    "  begin\n" ++
                    "    begin end;" ++
                    "  end;\n" ++
                    "end"
            res `shouldBe` SappStmtBlock [ SappStmtBlock [ SappStmtBlock [] ] ]

        it "should parse multiple statements" $ do
            let res = parseStatement . scanTokens $
                    "begin\n" ++
                    "  write \"Hello world\";\n" ++
                    "  write \"Hello again!\";\n" ++
                    "end"
            res `shouldSatisfy` (\res -> case res of
                    SappStmtBlock stms -> length stms == 2
                    _ -> False
                )

        it "should reject statements without an ending ';'" $ do
            let res = parseStatement . scanTokens $
                    "begin\n" ++
                    "  write \"Hello world\"\n" ++
                    "end"
            evaluate res `shouldThrow` anyErrorCall

    describe "variable declaration" $ do
        it "should parse an integer variable declaration" $ do
            let res = parseStatement . scanTokens $
                    "integer num"
            res `shouldBe` SappStmtVariableDeclaration SappDTInteger "num"

        it "should parse a boolean variable declaration" $ do
            let res = parseStatement . scanTokens $
                    "boolean flag"
            res `shouldBe` SappStmtVariableDeclaration SappDTBoolean "flag"

        it "should reject a variable declaration with multiple variables" $ do
            let res = parseStatement . scanTokens $
                    "integer year, height, width"
            evaluate res `shouldThrow` anyErrorCall

    describe "assignment" $ do
        it "should parse an expression assignment" $ do
            let res = parseStatement . scanTokens $
                    "num := 42"
            res `shouldBe` SappStmtAssignment (SappVar "num") (SappExpLitInteger 42)

        it "should reject a multiple variables assignment" $ do
            let res = parseStatement . scanTokens $
                    "year, month, day := 1992, 5, 22"
            evaluate res `shouldThrow` anyErrorCall

    describe "read" $ do
        it "should parse a read for an identifier" $ do
            let res = parseStatement . scanTokens $
                    "read num"
            res `shouldBe` SappStmtRead (SappVar "num")

        it "should reject a read for an expression" $ do
            let res = parseStatement . scanTokens $
                    "read 3"
            evaluate res `shouldThrow` anyErrorCall

        it "should reject a read for multiple identifiers" $ do
            let res = parseStatement . scanTokens $
                    "read num, nam"
            evaluate res `shouldThrow` anyErrorCall

    describe "write" $ do
        it "should accept a string" $ do
            let res = parseStatement . scanTokens $
                    "write \"Hello world\""
            res `shouldBe` SappStmtWrite [Left "Hello world"]

        it "should accept multiple strings" $ do
            let res = parseStatement . scanTokens $
                    "write \"Hello world\", \"Hello again!\""
            res `shouldBe` SappStmtWrite [Left "Hello world", Left "Hello again!"]

        it "should accept an expression" $ do
            let res = parseStatement . scanTokens $
                    "write 4"
            res `shouldBe` SappStmtWrite [Right (SappExpLitInteger 4)]

        it "should accept multiple expressions" $ do
            let res = parseStatement . scanTokens $
                    "write 4, true, 5"
            res `shouldBe` SappStmtWrite [Right (SappExpLitInteger 4), Right (SappExpLitBoolean True), Right (SappExpLitInteger 5)]

        it "should accept mixed expressions and strings" $ do
            let res = parseStatement . scanTokens $
                    "write \"A number:\", 6"
            res `shouldBe` SappStmtWrite [Left "A number:", Right (SappExpLitInteger 6)]

    describe "if" $ do
        it "should accept an if-then statement" $ do
            let res = parseStatement . scanTokens $
                    "if true\n" ++
                    "then write \"Hello world\""
            res `shouldSatisfy` (\res -> case res of
                    SappStmtIf expr tStmt Nothing -> True
                    _ -> False
                )

        it "should accept an if-then-else statement" $ do
            let res = parseStatement . scanTokens $
                    "if true\n" ++
                    "then write \"Hello world\"\n" ++
                    "else write \"Goodbye world\""
            res `shouldSatisfy` (\res -> case res of
                    SappStmtIf expr tStmt (Just eStmt) -> True
                    _ -> False
                )

        it "should parse if-then-if-then-else case as if-then(if-then-else)" $ do
            let res = parseStatement . scanTokens $
                    "if true\n" ++
                    "then if false\n" ++
                        "then write \"Hello world\"\n" ++
                        "else write \"Goodbye world\""
            res `shouldSatisfy` (\res -> case res of
                    SappStmtIf oExpr (SappStmtIf iExpr tStmt (Just eStmt)) Nothing -> True
                    _ -> False
                )


program = describe "Program_" $ do
    it "should parse an empty program" $ do
        let res = parseProgram . scanTokens $
                "main end"
        res `shouldBe` SappStmtBlock []

    it "should parse a program with statemets" $ do
        let res = parseProgram . scanTokens $
                "main\n" ++
                "  write \"Hello world\";\n" ++
                "  write \"Hello again!\";\n" ++
                "end"
        res `shouldSatisfy` (\res -> case res of
                SappStmtBlock stms -> length stms == 2
                _ -> False
            )
