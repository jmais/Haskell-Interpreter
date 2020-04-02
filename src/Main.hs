module Main where

import Pascal
import System.Environment
import qualified Data.Map.Strict as Map

main :: IO ()
main = do
    (fileName:_) <- getArgs
    contents <- readFile fileName
    case parseString contents of 
        Left err -> print $ show err
        Right ast -> putStrLn $ interpret ast

