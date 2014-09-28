module Main where

import           Parser
import           SappMonad
import           Definition
import           TypeChecker
import           SizeOffset

import           Control.Monad       (when)
import           Data.Foldable      (mapM_)
import           Data.Sequence      as DS (null)
import           Prelude            as P hiding (mapM_, null)
import qualified Prelude            as P (null)
import           System.Environment (getArgs)

main :: IO ()
main = do
    args <- getArgs
    input <- if P.null args
        then getContents
        else readFile $ head args
    let (readW, prog) = parseProgram input
    mapM_ print readW
    -- When there are no Lexing/Parsing errors
    when (null readW) $ do
        let (defS, defW) = processDefinition readW prog
        mapM_ print defW
        -- When there are no Definition errors
        when (null defW) $ do
            let (typS, typW) = processTypeChecker defW (getTable defS) (getAst defS)
            mapM_ print typW
            when (null typW) $ do
                let (sizS, sizW) = processSizeOffset typW (getTable typS) (getAst typS)
                print sizS
                mapM_ print sizW
    putStrLn "done."


--printProgram :: Checker () -> IO ()
--printProgram chk = do
--    let (state, writer) = runProgramChecker chk
--        CheckState stTable _ _ stAst _ _ _ = state
--    -- TEMPORAL
--    print state
--    let (lexE, parseE, staticE, afterW) = getErrors writer
--    mapM_ print lexE
--    mapM_ print parseE
--    mapM_ print staticE
--    mapM_ print afterW
--    --putStrLn "#################################################################\n"
--    ---- /TEMPORAL
--    --if null writer
--    --    then print stAst
--    --    else do
--    --        let (lexErrors,parseErrors,staticErrors,warnings) = getErrors writer
--    --        -- Only print errors if there are no errors of more basic type
--    --        void $ runMaybeT $ do
--    --            lift $ mapM_ print lexErrors

--    --            guard $ null lexErrors
--    --            lift $ mapM_ print parseErrors

--    --            guard $ null parseErrors
--    --            lift $ mapM_ print staticErrors

--    --            guard $ null staticErrors
--    --            lift $ mapM_ print warnings
