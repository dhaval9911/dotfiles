  -- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
-- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.SpawnOn
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Operations
import qualified XMonad.Actions.Search as S
    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Ratio
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks 
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..), SetStruts)
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat,doRectFloat,isDialog )
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

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
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.Loggers
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.EZConfig 
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:Source Code Pro :SemiBold:size=10:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask        -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "xfce4-terminal"    -- Sets default terminal

alacritty :: String
alacritty = "alacritty"

myBrowser :: String
myBrowser = "brave"  -- Sets qutebrowser as browser


rofi_launcher = spawn "~/.config/openbox/rofi/bin/launcher"
rofi_runner = spawn  "~/.config/openbox/rofi/bin/runner"

gplayer :: String
gplayer = "playmymusic"


myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' "  -- Makes emacs keybindings easier to type

myEditor :: String
myEditor = myTerminal ++ " -e nvim "    -- Sets nvim as editor

myBorderWidth :: Dimension
myBorderWidth = 1           -- Sets border width for windows

myNormColor :: String
myNormColor   = "#282c34"   -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#46d9ff"   -- Border color of focused windows

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
   -- spawnOnce "lxsession &"
  --  spawnOnce "compton &"
    spawnOn "www" "brave"
    spawnOn  ( myWorkspaces !! 1 ) "alacritty"
    spawnOnce "mpd &"
    spawnOnce "mpd &"
    spawn "bash ~/.xmonad/bin/startup.sh"
  --  spawnOnce "xargs xwallpaper --stretch < ~/.xwallpaper"  -- set last saved with xwallpaper
    -- spawnOnce "/bin/ls ~/wallpapers | shuf -n 1 | xargs xwallpaper --stretch"  -- set random xwallpaper
    -- spawnOnce "~/.fehbg &"  -- set last saved feh wallpaper
   -- spawnOnce "picom &"
    -- spawnOnce "feh --randomize --bg-fill ~/wallpapers/*"  -- feh set random wallpaper
   -- spawnOnce "nitrogen --restore &"   -- if you prefer nitrogen to feh
    setWMName "LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x2c,0x34) -- lowest inactive bg
                  (0x28,0x2c,0x34) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myAppGrid = [ ("Audacity", "audacity")
                 , ("Deadbeef", "deadbeef")
                 , ("Emacs", "emacsclient -c -a emacs")
                 , ("Firefox", "firefox")
                 , ("Geany", "geany")
                 , ("Geary", "geary")
                 , ("Gimp", "gimp")
                 , ("Kdenlive", "kdenlive")
                 , ("LibreOffice Impress", "loimpress")
                 , ("LibreOffice Writer", "lowriter")
                 , ("OBS", "obs")
                 , ("PCManFM", "pcmanfm")
                 ]

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
  where
    spawnTerm  = alacritty ++ " --class=scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = alacritty ++ " -t mocp -e mocp"
    findMocp   = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w 
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ avoidStruts
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
           $ smartBorders 
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
-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
                $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| noBorders tabs
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow
                                 ||| tallAccordion
                                 ||| wideAccordion

--myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
myWorkspaces = [" code ", " www ", " file ", " doc ", " vbox ", " note ", " vid ", " chat ", " misc "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"                   --> doFloat
     , isDialog                                 --> doCenterFloat
     , isDialog                                 --> hasBorder False 
     , title =? "File Operation Progress"       --> doCenterFloat
     , className =? "Thunar"                    --> hasBorder False
     , className =? "Thunar"                    --> doRectFloat (W.RationalRect 0.05 0.07 0.9 0.9)
     , className =? "Org.gnome.Nautilus"        --> doRectFloat (W.RationalRect 0.05 0.07 0.9 0.9)
     , className =? "viewnior"                  --> doCenterFloat
     , className =? "file_progress"             --> doCenterFloat
     , className =? "Viewnior"                  --> doCenterFloat
     , className =? "xfce4-appfinder"           --> doFloat
     , className =? "nitrogen"                  --> doCenterFloat   
     , className =? "Nitrogen"                  --> doCenterFloat   
     , className =? "Xfce4-appfinder"           --> doFloat
     , className =? "dialog"                    --> doCenterFloat
     , className =? "download"                  --> doCenterFloat
     , className =? "error"                     --> doCenterFloat
     , className =? "Trayer"                    --> doFloat
     , className =? "Gimp"                      --> doFloat
     , className =? "notification"              --> doFloat
     , className =? "scratchpad"                --> doFloat
     , className =? "rofi"                      --> doCenterFloat
     , className =? "Xfce-polkit"               --> doCenterFloat
     , className =? "pinentry-gtk-2"            --> doFloat
     , className =? "splash"                    --> doFloat
     , className =? "Yad"                       --> doCenterFloat
     , className =? "toolbar"                   --> doFloat
     , title =? "Virtual Media Manager"         --> doFloat
     , title =? "Host Network Manager"          --> doFloat
     , className =? "mpv"                       --> doShift ( myWorkspaces !! 7 )
     , className =? "Brave-browser"             --> doShift ( myWorkspaces !! 1 )
     , className =? "obs"                       --> doShift ( myWorkspaces !! 8 )
     , className =? "VirtualBox Manager"        --> doShift  ( myWorkspaces !! 4 )
     , className =? "Vmware"        --> doShift  ( myWorkspaces !! 4 )
     , className =? "VirtualBox Manager"        --> doRectFloat (W.RationalRect 0.05 0.07 0.9 0.9)
     , className =? "vmware"        --> doRectFloat (W.RationalRect 0.05 0.07 0.9 0.9)
     , className =? "pdf"                       --> doShift ( myWorkspaces !! 3 ) 
     , className =? "Notion"                    --> doShift  ( myWorkspaces !! 5 )
     , className =? "Zathura"                   --> doShift  ( myWorkspaces !! 3 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
     ] <+> namedScratchpadManageHook myScratchPads

-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
      -- KB_GROUP Xmonad
        [ ("M-S-p", spawn "xmonad --recompile && xmonad --restart")    -- Restarts xmonad
        , ("M-S-q", io exitSuccess)              -- Quits xmonad
        , ("M-M1-n", spawn "thunar")
        , ("M-M1-c", spawn "pavucontrol")

-- NEW KEYBINDING FOR LAUNCHERS 
        , ("M-x", spawn "~/.config/openbox/rofi/bin/powermenu")
        , ("M-i", spawn "~/.config/openbox/rofi/bin/mpd")
        , ("M-S-b", spawn "~/.config/openbox/rofi/bin/network")
        , ("M-M1-s", spawn "~/.config/openbox/rofi/bin/screenshot")
        , ("M-M1-l", spawn "betterlockscreen -s blur")
    -- Run Prompt
        , ("M1-<F1>", rofi_launcher)
    -- Runner 
          , ("M-r", rofi_runner)
        ,("M1-<Tab>", spawn "rofi -show window -theme /home/lucifer/.config/openbox/rofi/default/launcher.rasi") -- Dmenu
    --
    -- Other Dmenu Prompts
    -- In Xmonad and many tiling window managers, M-p is the default keybinding to
    -- launch dmenu_run, so I've decided to use M-p plus KEY for these dmenu scripts.
        , ("M-p a", spawn "dm-sounds")    -- choose an ambient background
        , ("M-p b", spawn "dm-setbg")     -- set a background
        , ("M-p c", spawn "dm-colpick")   -- pick color from our scheme
        , ("M-p e", spawn "dm-confedit")  -- edit config files
        , ("M-p i", spawn "dm-maim")      -- screenshots (images)
        , ("M-p k", spawn "dm-kill")      -- kill processes
        , ("M-p m", spawn "dm-man")       -- manpages p
        , ("M-p o", spawn "dm-bookman")   -- qutebrowser bookmarks/history
        , ("M-p p", spawn "passmenu")     -- passmenu
        , ("M-p q", spawn "dm-logout")    -- logout menu
        , ("M-p r", spawn "dm-reddit")    -- reddio (a reddit viewer)
        , ("M-p s", spawn "dm-websearch") -- search various search engines

    -- Useful programs to have a keybinding for launch
        , ("M-<Return>", spawn (myTerminal))
        , ("M-M1-b", spawn (myBrowser ))
        , ("M-M1-h", spawn (myTerminal ++ " -e htop"))

    -- Kill windows
        , ("M-q",   kill1)     -- Kill the currently focused client
        , ("M-S-a", killAll)   -- Kill all windows on current workspace

    -- Workspaces
    , ("M-<Space>", nextScreen)  -- Switch focus to next monitor
        , ("M-S-.", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
        , ("M-S-,", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws
    
    --Swiching between workspaces prev and next
        , ("M-n" , nextWS)
        , ("M-m" , prevWS)

    -- Floating windows
        , ("M-e", sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile

    -- Increase/decrease spacing (gaps)
        , ("C-M1-j", decWindowSpacing 4)         -- Decrease window spacing
        , ("C-M1-k", incWindowSpacing 4)         -- Increase window spacing
        , ("C-M1-h", decScreenSpacing 4)         -- Decrease screen spacing
        , ("C-M1-l", incScreenSpacing 4)         -- Increase screen spacing

    -- Grid Select (CTR-g followed by a key)
        , ("C-g g", spawnSelected' myAppGrid)                 -- grid select favorite apps
        , ("C-g t", goToSelected $ mygridConfig myColorizer)  -- goto selected window
        , ("C-g b", bringSelected $ mygridConfig myColorizer) -- bring selected window

    -- Windows navigation
        , ("M-j", windows W.focusDown)    -- Move focus to the next window
        , ("M-k", windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
        , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- Layouts
        , ("M-<Tab>", sendMessage NextLayout)                                  -- Switch to next layout
        , ("M-f", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)  -- Toggles noborder/full
        , ("M-b", sendMessage ToggleStruts)                                    -- Show/Hide xmobar
        , ("M-M1-g",  sendMessage (MT.Toggle NOBORDERS ))                      -- Remove Borders From Windows

    -- Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase # of clients master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease # of clients master pane
        , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
        , ("M-C-<Down>", decreaseLimit)                 -- Decrease # of windows

    -- Window resizing
        , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-k", sendMessage MirrorExpand)          -- Expand vert window width

    -- Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        , ("M-C-h", sendMessage $ pullGroup L)
        , ("M-C-l", sendMessage $ pullGroup R)
        , ("M-C-k", sendMessage $ pullGroup U)
        , ("M-C-j", sendMessage $ pullGroup D)
        , ("M-w", withFocused (sendMessage . MergeAll))
      --, ("M-C-u", withFocused (sendMessage . UnMerge))
        , ("M-C-/", withFocused (sendMessage . UnMergeAll))
        , ("M-C-.", onGroup W.focusUp')    -- Switch focus to next tab
        , ("M-C-,", onGroup W.focusDown')  -- Switch focus to prev tab

    -- Scratchpads
    -- Toggle show/hide these programs.  They run on a hidden workspace.
    -- When you toggle them to show, it brings them to your current workspace.
    -- Toggle them to hide and it sends them back to hidden workspace (NSP).
        , ("C-s t", namedScratchpadAction myScratchPads "terminal")
        , ("C-s m", namedScratchpadAction myScratchPads "mocp")
        , ("C-s c", namedScratchpadAction myScratchPads "calculator")

    -- Set wallpaper with 'feh'. Type 'SUPER+F1' to launch sxiv in the wallpapers directory.
    -- Then in sxiv, type 'C-x w' to set the wallpaper that you choose.
        , ("M-<F1>", spawn "sxiv -r -q -t -o ~/wallpapers/*")
        , ("M-<F2>", spawn "/bin/ls ~/wallpapers | shuf -n 1 | xargs xwallpaper --stretch")
        --, ("M-<F2>", spawn "feh --randomize --bg-fill ~/wallpapers/*")

    -- Controls for mocp music player (SUPER-u followed by a key)
        , ("M-u p", spawn "mocp --play")
        , ("M-u n", spawn "mocp --next")
        , ("M-u m", spawn "mocp --previous")
        , ("M-u <Space>", spawn "mocp --toggle-pause")

    -- Emacs (CTRL-e followed by a key)
        -- , ("C-e e", spawn myEmacs)                 -- start emacs
        , ("C-e e", spawn (myEmacs ++ ("--eval '(dashboard-refresh-buffer)'")))   -- emacs dashboard
        , ("C-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'")))   -- list buffers
        , ("C-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))) -- dired
        , ("C-e i", spawn (myEmacs ++ ("--eval '(erc)'")))       -- erc irc client
        , ("C-e m", spawn (myEmacs ++ ("--eval '(mu4e)'")))      -- mu4e email
        , ("C-e n", spawn (myEmacs ++ ("--eval '(elfeed)'")))    -- elfeed rss
        , ("C-e s", spawn (myEmacs ++ ("--eval '(eshell)'")))    -- eshell
        , ("C-e t", spawn (myEmacs ++ ("--eval '(mastodon)'")))  -- mastodon.el
        -- , ("C-e v", spawn (myEmacs ++ ("--eval '(vterm nil)'"))) -- vterm if on GNU Emacs
        , ("C-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))) -- vterm if on Doom Emacs
        -- , ("C-e w", spawn (myEmacs ++ ("--eval '(eww \"distrotube.com\")'"))) -- eww browser if on GNU Emacs
        , ("C-e w", spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"distrotube.com\"))'"))) -- eww browser if on Doom Emacs
        -- emms is an emacs audio player. I set it to auto start playing in a specific directory.
        , ("C-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/Non-Classical/70s-80s/\")'")))

    -- Multimedia Keys
        , ("<XF86AudioPlay>", spawn ("mpc toggle"))
        , ("<XF86AudioPrev>", spawn ("mpc prev"))
        , ("<XF86AudioNext>", spawn ("mpc next"))
        , ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle && exec notify-send Mute -t 500")
        , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +10% && notify-send Volume:$(pactl list sinks | grep Volume | awk '{print $3}'  | head -n 1 | cut -c1-2) -t 500")
        , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -10% && notify-send Volume:$(pactl list sinks | grep Volume | awk '{print $3}'  | head -n 1 | cut -c1-2) -t 500")
        , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10 && notify-send Brightness:$(xbacklight | cut -f1 -d '.')  -t 500")
        , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10 && notify-send Brightness:$(xbacklight | cut -f1 -d '.') -t 500")
        , ("<XF86HomePage>", spawn "qutebrowser https://www.youtube.com/c/DistroTube")
        , ("<XF86Search>", spawn "dmsearch")
        , ("<XF86Mail>", runOrRaise "thunderbird" (resource =? "thunderbird"))
        , ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
        , ("<XF86Eject>", spawn "toggleeject")
        , ("<Print>", spawn "dmscrot")
        ]
    -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

-- END_KEYS
main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
    -- the xmonad, ya know...what the WM is named after!
    xmonad $ ewmh def
        { manageHook         = myManageHook <+> manageDocks
        , handleEventHook    = docksEventHook
                               -- Uncomment this line to enable fullscreen support on things like YouTube/Netflix.
                               -- This works perfect on SINGLE monitor systems. On multi-monitor systems,
                               -- it adds a border around the window if screen does not have focus. So, my solution
                               -- is to use a keybinding to toggle fullscreen noborders instead.  (M-<Space>)
                               -- <+> fullscreenEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
              -- the following variables beginning with 'pp' are settings for xmobar.
              { ppOutput = \x -> hPutStrLn xmproc0 x                          -- xmobar on monitor 1
                            >> hPutStrLn xmproc1 x                          -- xmobar on monitor 2
             , ppCurrent = xmobarColor "#c792ea" "" . wrap "<box type=Bottom width=2 mb=2 color=#c792ea>" "</box>"         -- Current workspace
             -- , ppCurrent = xmobarColor "#98be65" "" . wrap "(" ")"           -- Current workspace
              , ppVisible = xmobarColor "#c792ea" "" . clickable              -- Visible but not current workspace
              , ppHidden = xmobarColor "#46d9ff" "" . wrap "*" "" . clickable -- Hidden workspaces
              , ppHiddenNoWindows = xmobarColor "#b3afc2" ""  . clickable     -- Hidden workspaces (no windows)
              , ppTitle = xmobarColor "#b3afc2" "" . shorten 60               -- Title of active window
              , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"                    -- Separator character
              , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
              , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
              }
        } `additionalKeysP` myKeys
