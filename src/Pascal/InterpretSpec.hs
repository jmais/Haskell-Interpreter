main :: IO ()
main = hspec $ do
  describe "intExp" $ do
    context "*" $ do
        
        it "multiplies floats" $ do
            intExp "*" [Real 4.0, Real 3.0] `shouldBe` [Real 12.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "*" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "*" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"

    context "+" $ do
        
        it "adds floats" $ do
            intExp "+" [Real 4.0, Real 3.0] `shouldBe` [Real 7.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "+" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "+" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"

    context "-" $ do
        
        it "subtracts floats" $ do
            intExp "-" [Real 4.0, Real 3.0] `shouldBe` [Real 1.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "-" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"
        
    context "/" $ do
        it "divides floats" $ do
            intExp "/" [Real 7.5, Real 3.0] `shouldBe` [Real 2.5]

        it "errors on too few arguments" $ do   
            evaluate (intExp "/" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "/" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"
    
    context "ln" $ do
        it "ln floats" $ do
            intExp "ln" [Real 1.0] `shouldBe` [Real 0.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "/" []) `shouldThrow` errorCall "Stack underflow"
    
    context "sin" $ do
        it "sin floats" $ do
            intExp "sin" [Real 0.0] `shouldBe` [Real 0.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "/" []) `shouldThrow` errorCall "Stack underflow"

    context "cos" $ do
        it "cos floats" $ do
            intExp "cos" [Real 0.0] `shouldBe` [Real 1.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "/" []) `shouldThrow` errorCall "Stack underflow"

    context "sqrt" $ do
        it "sqrt floats" $ do
            intExp "sqrt" [Real 4.0] `shouldBe` [Real 2.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "/" []) `shouldThrow` errorCall "Stack underflow"

    context "exp" $ do
        it "exp floats" $ do
            intExp "exp" [Real 2.0] `shouldBe` [Real 4.0]

        it "errors on too few arguments" $ do   
            evaluate (intExp "/" []) `shouldThrow` errorCall "Stack underflow"

  describe "boolExp" $ do
    context "and" $ do
        
        it "and boolean" $ do
            boolExp "and" [Boolean True, Boolean True] `shouldBe` [Boolean True]
            boolExp "and" [Boolean True, Boolean False] `shouldBe` [Boolean False]

        it "errors on too few arguments" $ do   
            evaluate (intExp "*" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "*" [Boolean True]) `shouldThrow` errorCall "Stack underflow"

    context "or" $ do
        
        it "or boolean" $ do
            boolExp "or" [Boolean True, Boolean False] `shouldBe` [Boolean True]
            boolExp "or" [Boolean False, Boolean False] `shouldBe` [Boolean False]

        it "errors on too few arguments" $ do   
            evaluate (intExp "+" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "+" [Boolean False]) `shouldThrow` errorCall "Stack underflow"

    context "<" $ do
        
        it "less than floats" $ do
            boolExp "<" [Real 4.0, Real 3.0] `shouldBe` [Boolean False]
            boolExp "<" [Real 3.0, Real 4.0] `shouldBe` [Boolean True]

        it "errors on too few arguments" $ do   
            evaluate (intExp "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "-" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"
        
    context ">" $ do
        
        it "greater than floats" $ do
            boolExp ">" [Real 4.0, Real 3.0] `shouldBe` [Boolean True]
            boolExp ">" [Real 3.0, Real 4.0] `shouldBe` [Boolean False]

        it "errors on too few arguments" $ do   
            evaluate (intExp "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "-" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"

    context "<=" $ do
        
        it "less than or equal to floats" $ do
            boolExp "<=" [Real 4.0, Real 3.0] `shouldBe` [Boolean False]
            boolExp "<=" [Real 3.0, Real 4.0] `shouldBe` [Boolean True]
            boolExp "<=" [Real 3.0, Real 3.0] `shouldBe` [Boolean True]

        it "errors on too few arguments" $ do   
            evaluate (intExp "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "-" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"
        
    context ">=" $ do
        
        it "greater than floats" $ do
            boolExp ">=" [Real 4.0, Real 3.0] `shouldBe` [Boolean True]
            boolExp ">=" [Real 3.0, Real 4.0] `shouldBe` [Boolean False]
             boolExp ">=" [Real 3.0, Real 3.0] `shouldBe` [Boolean True]

        it "errors on too few arguments" $ do   
            evaluate (intExp "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "-" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"
    
    context "=" $ do
        
        it "equal to floats" $ do
            boolExp "=" [Real 4.0, Real 3.0] `shouldBe` [Boolean False]
            boolExp "=" [Real 3.0, Real 3.0] `shouldBe` [Boolean True]

        it "errors on too few arguments" $ do   
            evaluate (intExp "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "-" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"
        
    context "<>" $ do
        
        it "not equal to floats" $ do
            boolExp "<>" [Real 4.0, Real 3.0] `shouldBe` [Boolean True]
             boolExp "<>" [Real 3.0, Real 3.0] `shouldBe` [Boolean False]

        it "errors on too few arguments" $ do   
            evaluate (intExp "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (intExp "-" [Real 2.0]) `shouldThrow` errorCall "Stack underflow"