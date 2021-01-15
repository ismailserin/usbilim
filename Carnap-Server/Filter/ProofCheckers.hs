{-# LANGUAGE OverloadedStrings #-}
module Filter.ProofCheckers (makeProofChecker) where

import Text.Pandoc
import Data.Map (Map, unions, fromList, toList)
import qualified Data.Text as T
import Data.Text (Text)
import Filter.Util (numof, intoChunks, formatChunk, unlines', exerciseWrapper)
import Prelude

makeProofChecker :: Block -> Block
makeProofChecker cb@(CodeBlock (_,classes,extra) contents)
    | "ProofChecker" `elem` classes = Div ("",[],[]) $ map (activate classes extra) $ intoChunks contents
    | "Playground" `elem` classes = Div ("",[],[]) [toPlayground classes extra contents]
    | otherwise = cb
makeProofChecker x = x

activate :: [Text] -> [(Text, Text)] -> Text -> Block
activate cls extra chunk
    | "Prop"             `elem` cls = exTemplate [("system", "prop"),("guides","montague"),("options","resize")]
    | "FirstOrder"       `elem` cls = exTemplate [("system", "firstOrder"),("guides","montague"),("options","resize")]
    | "SecondOrder"      `elem` cls = exTemplate [("system", "secondOrder")]
    | "PolySecondOrder"  `elem` cls = exTemplate [("system", "polyadicSecondOrder")]
    | "ElementaryST"     `elem` cls = exTemplate [("system", "elementarySetTheory"),("options","resize render")]
    | "SeparativeST"     `elem` cls = exTemplate [("system", "separativeSetTheory"),("options","resize render")]
    | "MontagueSC"       `elem` cls = exTemplate [("system", "montagueSC"),("options","resize")]
    | "MontagueQC"       `elem` cls = exTemplate [("system", "montagueQC"),("options","resize")]
    | "LogicBookSD"      `elem` cls = exTemplate [("system", "LogicBookSD")]
    | "LogicBookSDPlus"  `elem` cls = exTemplate [("system", "LogicBookSDPlus")]
    | "LogicBookPD"      `elem` cls = exTemplate [("system", "LogicBookPD")]
    | "LogicBookPDPlus"  `elem` cls = exTemplate [("system", "LogicBookPDPlus")]
    | "LogicBookPDE"     `elem` cls = exTemplate [("system", "LogicBookPDE")]
    | "LogicBookPDEPlus" `elem` cls = exTemplate [("system", "LogicBookPDEPlus")]
    | "HausmanSL"        `elem` cls = exTemplate [("system", "hausmanSL"), ("guides","hausman"), ("options", "resize fonts") ]
    | "HausmanPL"        `elem` cls = exTemplate [("system", "hausmanPL"), ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutMPND"        `elem` cls = exTemplate [("system", "gamutMPND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutIPND"        `elem` cls = exTemplate [("system", "gamutIPND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutPND"         `elem` cls = exTemplate [("system", "gamutPND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutPNDPlus"     `elem` cls = exTemplate [("system", "gamutPNDPlus"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutND"          `elem` cls = exTemplate [("system", "gamutND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutNDPlus"      `elem` cls = exTemplate [("system", "gamutNDPlus"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutNDDesc"      `elem` cls = exTemplate [("system", "gamutNDDesc"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "HowardSnyderSL"   `elem` cls = exTemplate [("system", "howardSnyderSL"), ("guides","howardSnyder"), ("options", "resize fonts") ]
    | "HowardSnyderPL"   `elem` cls = exTemplate [("system", "howardSnyderPL"), ("guides","howardSnyder"), ("options", "resize fonts") ]
    | "AllenSL"          `elem` cls = exTemplate [("system", "allenSL")]
    | "AllenSLPlus"      `elem` cls = exTemplate [("system", "allenSLPlus")]
    | "HurleySL"         `elem` cls = exTemplate [("system", "hurleySL"), ("guides", "hurley"), ("options", "resize")]
    | "HurleyPL"         `elem` cls = exTemplate [("system", "hurleyPL"), ("guides", "hurley"), ("options", "resize")]
    | "ForallxSL"        `elem` cls = exTemplate [("system", "magnusSL"), ("options","render")]
    | "ForallxSLPlus"    `elem` cls = exTemplate [("system", "magnusSLPlus"), ("options","render")]
    | "ForallxQL"        `elem` cls = exTemplate [("system", "magnusQL"), ("options","render")]
    | "ForallxQLPlus"    `elem` cls = exTemplate [("system", "magnusQLPlus"), ("options","render")]
    | "IchikawaJenkinsSL"`elem` cls = exTemplate [("system", "ichikawaJenkinsSL"), ("options","render")]
    | "IchikawaJenkinsQL"`elem` cls = exTemplate [("system", "ichikawaJenkinsQL"), ("options","render")]
    | "TomassiPL"        `elem` cls = exTemplate [("system", "tomassiPL"), ("options","resize render hideNumbering")]
    | "TomassiQL"        `elem` cls = exTemplate [("system", "tomassiQL"), ("options","resize render hideNumbering")]
    | "GoldfarbPropND"   `elem` cls = exTemplate [("system", "goldfarbPropND")]
    | "GoldfarbND"       `elem` cls = exTemplate [("system", "goldfarbND")]
    | "GoldfarbAltND"    `elem` cls = exTemplate [("system", "goldfarbAltND")]
    | "GoldfarbNDPlus"   `elem` cls = exTemplate [("system", "goldfarbNDPlus")]
    | "GoldfarbAltNDPlus"`elem` cls = exTemplate [("system", "goldfarbAltNDPlus")]
    | "ZachTFL"          `elem` cls = exTemplate [("system", "thomasBolducAndZachTFL"), ("options","render")]
    | "ZachTFLCore"      `elem` cls = exTemplate [("system", "thomasBolducAndZachTFLCore"), ("options","render")]
    | "ZachTFL2019"      `elem` cls = exTemplate [("system", "thomasBolducAndZachTFL2019"), ("options","render")]
    | "ZachFOL"          `elem` cls = exTemplate [("system", "thomasBolducAndZachFOL"), ("options","render")]
    | "ZachFOLCore"      `elem` cls = exTemplate [("system", "thomasBolducAndZachFOLCore"), ("options","render")]
    | "ZachFOL2019"      `elem` cls = exTemplate [("system", "thomasBolducAndZachFOL2019"), ("options","render")]
    | "ZachFOLPlus2019"  `elem` cls = exTemplate [("system", "thomasBolducAndZachFOLPlus2019"), ("options","render")]
    | "ZachPropEq"       `elem` cls = exTemplate [("system", "zachPropEq")]
    | "ZachFOLEq"        `elem` cls = exTemplate [("system", "zachFOLEq")]
    | "GallowSL"         `elem` cls = exTemplate [("system", "gallowSL"), ("options","render")]
    | "GallowSLPlus"     `elem` cls = exTemplate [("system", "gallowSLPlus"), ("options","render")]
    | "GallowPL"         `elem` cls = exTemplate [("system", "gallowPL"), ("options","render")]
    | "GallowPLPlus"     `elem` cls = exTemplate [("system", "gallowPLPlus"), ("options","render")]
    | "EbelsDugganTFL"   `elem` cls = exTemplate [("system", "ebelsDugganTFL"), ("guides", "fitch"), ("options", "fonts resize")]
    | "EbelsDugganFOL"   `elem` cls = exTemplate [("system", "ebelsDugganFOL"), ("guides", "fitch"), ("options", "fonts resize")]
    | "WinklerTFL"       `elem` cls = exTemplate [("system", "winklerTFL"), ("guides", "fitch"), ("options", "resize")]
    | "BonevacSL"        `elem` cls = exTemplate [("system", "bonevacSL"), ("guides", "montague"), ("options", "fonts resize")]
    | "BonevacQL"        `elem` cls = exTemplate [("system", "bonevacQL"), ("guides", "montague"), ("options", "fonts resize")]
    | "HardegreeSL"      `elem` cls = exTemplate [("system", "hardegreeSL"),  ("options", "render")]
    | "HardegreeSL2006"  `elem` cls = exTemplate [("system", "hardegreeSL2006"),  ("options", "render")]
    | "HardegreePL"      `elem` cls = exTemplate [("system", "hardegreePL"),  ("options", "render")]
    | "HardegreePL2006"  `elem` cls = exTemplate [("system", "hardegreePL2006"),  ("options", "render")]
    | "HardegreeWTL"     `elem` cls = exTemplate [("system", "hardegreeWTL"), ("guides", "montague"), ("options", "render fonts")]
    | "HardegreeL"       `elem` cls = exTemplate [("system", "hardegreeL"), ("guides", "montague"),   ("options", "fonts")]
    | "HardegreeK"       `elem` cls = exTemplate [("system", "hardegreeK"), ("guides", "montague"),   ("options", "fonts")]
    | "HardegreeT"       `elem` cls = exTemplate [("system", "hardegreeT"), ("guides", "montague"),   ("options", "fonts")]
    | "HardegreeB"       `elem` cls = exTemplate [("system", "hardegreeB"), ("guides", "montague"),   ("options", "fonts")]
    | "HardegreeD"       `elem` cls = exTemplate [("system", "hardegreeD"), ("guides", "montague"),   ("options", "fonts")]
    | "Hardegree4"       `elem` cls = exTemplate [("system", "hardegree4"), ("guides", "montague"),   ("options", "fonts")]
    | "Hardegree5"       `elem` cls = exTemplate [("system", "hardegree5"), ("guides", "montague"),   ("options", "fonts")]
    | "HardegreeMPL"     `elem` cls = exTemplate [("system", "hardegreeMPL"), ("guides", "montague"), ("options", "fonts")]
    | otherwise = exTemplate []
    where seqof = T.dropWhile (/= ' ')
          (h:t) = formatChunk chunk
          fixed = [("type","proofchecker"),("goal",seqof h),("submission", T.concat ["saveAs:", numof h])]
          exTemplate opts = template (unions [fromList extra, fromList opts, fromList fixed]) (numof h) (unlines' t)

toPlayground :: [Text] -> [(Text, Text)] -> Text -> Block
toPlayground cls extra content
    | "Prop"             `elem` cls = playTemplate [("system", "prop")]
    | "FirstOrder"       `elem` cls = playTemplate [("system", "firstOrder")]
    | "SecondOrder"      `elem` cls = playTemplate [("system", "secondOrder")]
    | "PolySecondOrder"  `elem` cls = playTemplate [("system", "polyadicSecondOrder")]
    | "ElementaryST"     `elem` cls = playTemplate [("system", "elementarySetTheory"), ("options","resize render")]
    | "SeparativeST"     `elem` cls = playTemplate [("system", "separativeSetTheory"), ("options","resize render")]
    | "MontagueSC"       `elem` cls = playTemplate [("system", "montagueSC"),("options","resize")]
    | "MontagueQC"       `elem` cls = playTemplate [("system", "montagueQC"),("options","resize")]
    | "LogicBookSD"      `elem` cls = playTemplate [("system", "LogicBookSD")]
    | "LogicBookSDPlus"  `elem` cls = playTemplate [("system", "LogicBookSDPlus")]
    | "LogicBookPD"      `elem` cls = playTemplate [("system", "LogicBookPD")]
    | "LogicBookPDPlus"  `elem` cls = playTemplate [("system", "LogicBookPDPlus")]
    | "LogicBookPDE"     `elem` cls = playTemplate [("system", "LogicBookPDE")]
    | "LogicBookPDEPlus" `elem` cls = playTemplate [("system", "LogicBookPDEPlus")]
    | "HausmanSL"        `elem` cls = playTemplate [("system", "hausmanSL"), ("guides","hausman"), ("options","fonts resize")]
    | "HausmanPL"        `elem` cls = playTemplate [("system", "hausmanPL"), ("guides","hausman"), ("options","fonts resize")]
    | "GamutMPND"        `elem` cls = playTemplate [("system", "gamutMPND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutIPND"        `elem` cls = playTemplate [("system", "gamutIPND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutPND"         `elem` cls = playTemplate [("system", "gamutPND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutPNDPlus"     `elem` cls = playTemplate [("system", "gamutPNDPlus"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutND"          `elem` cls = playTemplate [("system", "gamutND"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutNDPlus"      `elem` cls = playTemplate [("system", "gamutNDPlus"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "GamutNDDesc"      `elem` cls = playTemplate [("system", "gamutNDDesc"),  ("guides","hausman"), ("options", "resize fonts") ]
    | "HowardSnyderSL"   `elem` cls = playTemplate [("system", "howardSnyderSL"), ("guides","howardSnyder"), ("options","fonts resize")]
    | "HowardSnyderPL"   `elem` cls = playTemplate [("system", "howardSnyderPL"), ("guides","howardSnyder"), ("options","fonts resize")]
    | "AllenSL"          `elem` cls = playTemplate [("system", "allenSL")]
    | "AllenSLPlus"      `elem` cls = playTemplate [("system", "allenSLPlus")]
    | "HurleySL"         `elem` cls = playTemplate [("system", "hurleySL"), ("guides", "hurley"), ("options", "resize")]
    | "HurleyPL"         `elem` cls = playTemplate [("system", "hurleyPL"), ("guides", "hurley"), ("options", "resize")]
    | "ForallxSL"        `elem` cls = playTemplate [("system", "magnusSL"), ("options","render")]
    | "ForallxSLPlus"    `elem` cls = playTemplate [("system", "magnusSLPlus"), ("options","render")]
    | "ForallxQL"        `elem` cls = playTemplate [("system", "magnusQL"), ("options","render")]
    | "ForallxQLPlus"    `elem` cls = playTemplate [("system", "magnusQLPlus"), ("options","render")]
    | "IchikawaJenkinsSL"`elem` cls = playTemplate [("system", "ichikawaJenkinsSL"), ("options","render")]
    | "IchikawaJenkinsQL"`elem` cls = playTemplate [("system", "ichikawaJenkinsQL"), ("options","render")]
    | "TomassiPL"        `elem` cls = playTemplate [("system", "tomassiPL"), ("options","resize render hideNumbering")]
    | "TomassiQL"        `elem` cls = playTemplate [("system", "tomassiQL"), ("options","resize render hideNumbering")]
    | "GoldfarbPropND"   `elem` cls = playTemplate [("system", "goldfarbPropND"),("options","resize")]
    | "GoldfarbND"       `elem` cls = playTemplate [("system", "goldfarbND"),("options","resize")]
    | "GoldfarbAltND"    `elem` cls = playTemplate [("system", "goldfarbAltND"),("options","resize")]
    | "GoldfarbNDPlus"   `elem` cls = playTemplate [("system", "goldfarbNDPlus"),("options","resize")]
    | "GoldfarbAltNDPlus"`elem` cls = playTemplate [("system", "goldfarbAltNDPlus"),("options","resize")]
    | "ZachTFL"          `elem` cls = playTemplate [("system", "thomasBolducAndZachTFL"), ("options","render")]
    | "ZachTFLCore"      `elem` cls = playTemplate [("system", "thomasBolducAndZachTFLCore"), ("options","render")]
    | "ZachTFL2019"      `elem` cls = playTemplate [("system", "thomasBolducAndZachTFL2019"), ("options","render")]
    | "ZachFOL"          `elem` cls = playTemplate [("system", "thomasBolducAndZachFOL"), ("options","render")]
    | "ZachFOLCore"      `elem` cls = playTemplate [("system", "thomasBolducAndZachFOLCore"), ("options","render")]
    | "ZachFOL2019"      `elem` cls = playTemplate [("system", "thomasBolducAndZachFOL2019"), ("options","render")]
    | "ZachFOLPlus2019"  `elem` cls = playTemplate [("system", "thomasBolducAndZachFOLPlus2019"), ("options","render")]
    | "ZachPropEq"       `elem` cls = playTemplate [("system", "zachPropEq")]
    | "ZachFOLEq"        `elem` cls = playTemplate [("system", "zachFOLEq")]
    | "GallowSL"         `elem` cls = playTemplate [("system", "gallowSL"), ("options","render")]
    | "GallowSLPlus"     `elem` cls = playTemplate [("system", "gallowSLPlus"), ("options","render")]
    | "GallowPL"         `elem` cls = playTemplate [("system", "gallowPL"), ("options","render")]
    | "GallowPLPlus"     `elem` cls = playTemplate [("system", "gallowPLPlus"), ("options","render")]
    | "EbelsDugganTFL"   `elem` cls = playTemplate [("system", "ebelsDugganTFL"), ("guides", "fitch"), ("options", "fonts resize")]
    | "EbelsDugganFOL"   `elem` cls = playTemplate [("system", "ebelsDugganFOL"), ("guides", "fitch"), ("options", "fonts resize")]
    | "WinklerTFL"       `elem` cls = playTemplate [("system", "winklerTFL"), ("guides", "fitch"), ("options", "resize")]
    | "BonevacSL"        `elem` cls = playTemplate [("system", "bonevacSL"), ("guides", "montague"), ("options", "fonts resize")]
    | "BonevacQL"        `elem` cls = playTemplate [("system", "bonevacQL"), ("guides", "montague"), ("options", "fonts resize")]
    | "HardegreeSL"      `elem` cls = playTemplate [("system", "hardegreeSL"),  ("options", "render")]
    | "HardegreeSL2006"  `elem` cls = playTemplate [("system", "hardegreeSL2006"),  ("options", "render")]
    | "HardegreePL"      `elem` cls = playTemplate [("system", "hardegreePL"),  ("options", "render")]
    | "HardegreePL2006"  `elem` cls = playTemplate [("system", "hardegreePL2006"),  ("options", "render")]
    | "HardegreeWTL"     `elem` cls = playTemplate [("system", "hardegreeWTL"), ("guides", "montague"), ("options", "render fonts")]
    | "HardegreeL"       `elem` cls = playTemplate [("system", "hardegreeL"),  ("guides", "montague"), ("options", "fonts")]
    | "HardegreeK"       `elem` cls = playTemplate [("system", "hardegreeK"), ("guides", "montague"), ("options", "fonts")]
    | "HardegreeT"       `elem` cls = playTemplate [("system", "hardegreeT"), ("guides", "montague"), ("options", "fonts")]
    | "HardegreeB"       `elem` cls = playTemplate [("system", "hardegreeB"), ("guides", "montague"), ("options", "fonts")]
    | "HardegreeD"       `elem` cls = playTemplate [("system", "hardegreeD"), ("guides", "montague"), ("options", "fonts")]
    | "Hardegree4"       `elem` cls = playTemplate [("system", "hardegree4"), ("guides", "montague"), ("options", "fonts")]
    | "Hardegree5"       `elem` cls = playTemplate [("system", "hardegree5"), ("guides", "montague"), ("options", "fonts")]
    | "HardegreeMPL"     `elem` cls = playTemplate [("system", "hardegreeMPL"), ("guides", "montague"), ("options", "fonts")]
    | otherwise = playTemplate []
    where fixed = [("type","proofchecker")]
          playTemplate opts = template (unions [fromList extra, fromList opts, fromList fixed]) "Playground" (unlines' $ formatChunk content)

template :: Map Text Text -> Text -> Text -> Block
template opts header content = exerciseWrapper (toList opts) header $ RawBlock "html"
        --Need rawblock here to get the linebreaks right.
        $ T.concat ["<div", optString, ">", content, "</div>"]
    where optString = T.concat $ map (\(x,y) -> (T.concat [" data-carnap-", x, "=\"", y, "\""])) (toList opts)
