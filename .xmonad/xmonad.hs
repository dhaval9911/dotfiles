-- IMPORTS

  -- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.PhysicalScreens
import Data.Default
    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.ManageDocks 
    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Layout.IndependentScreens
import Graphics.X11.ExtraTypes.XF86


-- terminal variable
myTerminal      = "xfce4-terminal"

-- Whether focus follows the mouse pointer.
myClickJustFocuses :: Bool
myClickJustFocuses  = True

-- Width of the window border in pixels.
myBorderWidth   = 2

-- MODEKEY
myModMask       = mod4Mask

-- windowCount
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


-- My Workspaces
myWorkspaces    =  ["1","2","3","4","5","6","7","8","9"] 
-- myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

-- fonts 
myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:bold:size=10:antialias=true:hinting=true"

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor  = "#343536"
myFocusedBorderColor = "#0565ff"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
myAddKeys :: [(String, X ())]
myAddKeys =
    -- Xmonad
        [ 
         ("<XF86AudioMute>",         spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle" )
        ,("<XF86AudioLowerVolume>",  spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
        ,("<XF86AudioRaiseVolume>",  spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")
        ,("<XF86MonBrightnessUp>",   spawn "xbacklight -inc 10")
        ,("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10")

    -- Increase/decrease spacing (gaps)
        , ("C-M1-j", decWindowSpacing 4)         -- Decrease window spacing
        , ("C-M1-k", incWindowSpacing 4)         -- Increase window spacing
        , ("C-M1-h", decScreenSpacing 4)         -- Decrease screen spacing
        , ("C-M1-l", incScreenSpacing 4)         -- Increase screen spacing

        ]

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

   -- launch a terminal
    [ ((modm,  xK_x), spawn $ XMonad.terminal conf)
    -- launch browser
    , ((modm .|. mod1Mask,  xK_b     ), spawn "brave-nightly")
   -- launch file manager 
    , ((modm .|. mod1Mask,  xK_n     ), spawn "thunar")
    -- launch pavucontrol
    , ((modm .|. mod1Mask,  xK_c     ), spawn "pavucontrol")
    -- launch rofi 
    , ((modm,  xK_d     ), spawn "/home/lucifer/.config/rofi_themes/launcher/launcher.sh")
   -- launch other menu 
   , ((modm .|. shiftMask,  xK_d     ), spawn "/home/lucifer/.config/rofi_themes/launcher/launcher2.sh")
    -- close focused window
    , ((modm,  xK_q     ), kill)
     -- Rotate through the available layout algorithms
    , ((modm, xK_Tab ), sendMessage NextLayout)
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
    -- Push window back into tiling
    , ((modm  .|. shiftMask,   xK_space     ), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
    , ((modm , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ((modm  , xK_period), sendMessage (IncMasterN (-1)))
    -- Toggle the status bar gap
    , ((modm, xK_b), sendMessage(MT.Toggle NBFULL) >> sendMessage ToggleStruts)
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q), io exitSuccess)
    -- focus next monitor
    , ((modm, xK_space), onPrevNeighbour def W.view)
    -- shift window to next monitor
    , ((modm, xK_o), onPrevNeighbour def W.shift)
    , ((modm, xK_n), nextWS)
    , ((modm, xK_m), prevWS)
    
    -- Restart xmonad
    , ((modm  .|. shiftMask, xK_p), spawn "xmonad --recompile &&  xmonad --restart")
    ]
    ++
    --switch workspaces
      [ ((m .|. modm, k), windows $ onCurrentScreen f i)
        | (i ,k) <- zip (workspaces' conf) [xK_1 .. xK_9]
        , (f , m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    ]

------------------------------------------------------------------------

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True


-- MY LAYOUTS

-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 4
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 4
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 4
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 4
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }


-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }


-- The layoutHook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion
--------------------------------------------------------------------------
-- Window rules:

myManageHook = composeAll $ 
    [ className =? "Polybar"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ] 

------------------------------------------------------------------------
myEventHook = mempty

------------------------------------------------------------------------

myLogHook :: X ()
myLogHook = return ()
------------------------------------------------------------------------

myStartupHook = do
            spawnOnce  "nitrogen --restore &"
            spawnOnce  "picom &"

------------------------------------------------------------------------

main = do 
        nScreens <- countScreens
        xmproc0 <- spawnPipe "xmobar -x 0 /home/lucifer/.config/xmobar/xmobarrc0 -A 200" -- xmobar screen 0
        xmproc1 <- spawnPipe "xmobar -x 1 /home/lucifer/.config/xmobar/xmobarrc1 -A 200" -- xmobar screen 1
        xmonad $ ewmh $ docks def {

        workspaces = withScreens 2 ["1","2","3","4","5","6","7","8","9"],  -- workspaces independent way 
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myClickJustFocuses,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
      -- hooks, layouts
        layoutHook         = showWName' myShowWNameTheme $ myLayoutHook,
        manageHook =  myManageHook <+> manageDocks,
        handleEventHook    = myEventHook,
        logHook = myLogHook <+> dynamicLogWithPP xmobarPP
                         { ppOutput = \x -> hPutStrLn xmproc0 x
                                        >> hPutStrLn xmproc1 x
                         , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"     -- Current workspace 
                         , ppTitle = xmobarColor "#b3afc2" "" . shorten 60         -- Window Title 
                         , ppExtras  = [windowCount]                               -- # of windows current workspace
                         , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]              -- order of things in xmobar
                        },
                           startupHook        = myStartupHook
                        } `additionalKeysP` myAddKeys
