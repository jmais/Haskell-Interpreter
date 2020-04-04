import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)
import Pascal.Data
import Pascal.Interpret
import qualified Data.Map.Strict as Map




main :: IO ()
main = hspec $ do

  describe "intExp" $ do
    context "adding" $ do
        it "tests addition of two positives" $ do
            intExp (Op2 "+" (Real 1.0) (Real 1.0)) ([Map.fromList [("string",R 1.0)]]) `shouldBe` (R 2.0)