import XMonad hiding (screenCount)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)

import System.IO
import Graphics.X11.Xinerama(getScreenInfo)
import Data.List(isSuffixOf,inits, foldl1')
import Data.Char(isAlphaNum)


main = do
    xmprocTop0 <- spawnPipe "xmobar -x 0 ~/.xmobarrcTop"
    xmprocTop1 <- spawnPipe "xmobar -x 1 ~/.xmobarrcTop"
    xmprocBot0 <- spawnPipe "xmobar -x 0 ~/.xmobarrcBottom"
    xmprocBot1 <- spawnPipe "xmobar -x 1 ~/.xmobarrcBottom"

    xmonad $ defaultConfig
      { manageHook  = myManageHook
      , layoutHook  = avoidStruts $ layoutHook defaultConfig
      , logHook     = dynamicLogWithPP $ defaultPP
        { ppCurrent = xmobarColor "white" "black"
        , ppTitle   = xmobarColor "#00ee00" "" . dropChromium . shortenKeepWords 50
        , ppOutput  = \x -> hPutStrLn xmprocTop0 x  >> hPutStrLn xmprocTop1 x
        , ppUrgent  = xmobarColor "orange" "" . xmobarStrip
        } 
      , terminal    = "urxvt -fg Green -bg Black"
      , workspaces  = myWorkspaces
      , modMask     = mod4Mask -- Rebind Mod to the Windows key
      } 
       `additionalKeysP` audioKeys
       `additionalKeysP` launchKeys

audioKeys  =
    [("<XF86AudioRaiseVolume>", spawn "amixer -- sset Master Playback 5%+")
    ,("<XF86AudioLowerVolume>", spawn "amixer -- sset Master Playback 5%-")
    ,("<XF86AudioMute>",        spawn "amixer -- sset Master toggle")
    ,("M-<Up>",                 spawn "amixer -- sset Master Playback 5%+")
    ,("M-<Down>",               spawn "amixer -- sset Master Playback 5%-")
    ]

launchKeys =
    [("M-f",                    spawn "rhythmbox-client --no-start --no-present --next")
    ,("M-b",                    spawn "rhythmbox-client --no-start --no-present --previous")
    ,("M-x",                    spawn "rhythmbox-client --no-start --no-present --play-pause")
    ,("M-c",                    spawn "chromium")
    ,("M-p",                    spawn "dmenu_run")
    ]

myWorkspaces = map show [1..5] ++ ["Emacs", "Chat", "Music", "Web"]

myManageHook = composeAll 
               [ className =? "Rhythmbox"        --> doShift "Music"
               , className =? "Chromium"         --> doShift "Web"
               , className =? "Pidgin"           --> doShift "Chat"
               , className =? "Emacs"            --> doShift "Emacs"
               , manageDocks
               ]
               
dropChromium :: String -> String
dropChromium s'
    | " - Chromium" `isSuffixOf` s = take (length s - l) s
    | otherwise = s
    where
      s = trim s'
      l = length " - Chromium"


--Given a number n and a string s, make the longest prefix of s that consists of whole words,
--is no longer than n chars long, and whose last word contains at least one alphaNumeric char
shortenKeepWords :: Int -> String -> String
shortenKeepWords n s =  unwords $ reverse . dropWhile (not.any isAlphaNum) . reverse $ inits ws !! longest
    where
      ws = words s
      runningLength = scanl1 (+).map ((+1).length) $ ws -- +1 accounts for spaces lost from using 'words'
      longest = length $ takeWhile (<=n) runningLength --find longest 'whole word' prefix of s with length < n

screenCount :: X Int
screenCount = withDisplay (io.fmap length.getScreenInfo)


makeXMobars :: X [Handle]
makeXMobars = screenCount >>= (io.mapM spawnPipe.commandHandles )
  where
    commandHandles n = map ((\x -> "xmobar -x " ++ x).unwords) $ commandNames n
    commandNames n = sequence [map show [0..n], map (\x -> "~/.xmobarrc" ++ x) ["Top", "Bottom"]]
    

myLogHook :: X ()
myLogHook  = do
  handles <- makeXMobars
  dynamicLogWithPP $ defaultPP                                                                   
        { ppCurrent = xmobarColor "white" "black" 
        , ppTitle   = xmobarColor "#00ee00" "" . dropChromium . shortenKeepWords 50 
        , ppOutput  = \x -> mapM_ (`hPutStrLn` x) handles
        , ppOrder   = \(ws:_:t:_) -> [ws,t] 
        , ppUrgent  = xmobarColor "#ee9a00" "" . xmobarStrip
        } 

