@echo off
setlocal enabledelayedexpansion

:: ======================================================
::   ASENA'S FILE ORGANIZER v1.1
::   Features: File sorting, Duplicate detection,
::             Dry-run mode, Undo last run,
::             Collision-safe renaming, Change logs
:: ======================================================

title Asena's File Organizer v1.1

echo.
echo    ###      ######  ######## ##    ##    ###
echo  ##   ##   ##    ## ##       ###   ##   ## ##
echo ##     ##  ##       ##       ####  ##  ##   ##
echo ##     ##  ######   ######   ## ## ## ##     ##
echo #########       ##  ##       ##  #### #########
echo ##     ## ##    ##  ##       ##   ### ##     ##
echo ##     ##  ######   ######## ##    ## ##     ##
echo.
echo            FILE ORGANIZER  v1.1
echo.

:: ======================================================
:: STEP 1 — Get source path from user
:: ======================================================
set "SOURCE="
set /p "SOURCE=  Enter folder path to organise (e.g. D:\MyFiles): "
echo.

if not exist "%SOURCE%" (
    echo  [ERROR] Folder not found: "%SOURCE%"
    echo  Please check the path and try again.
    pause
    exit /b 1
)

:: ======================================================
:: STEP 2 — Dry-run or real run?
:: ======================================================
set "DRY_RUN=0"
:ask_mode
set "MODE_INPUT="
set /p "MODE_INPUT=  Run mode — [P] Preview (dry-run)  /  [R] Real run: "
if /i "!MODE_INPUT!"=="P" set "DRY_RUN=1"
if /i "!MODE_INPUT!"=="R" set "DRY_RUN=0"
if not "!MODE_INPUT!"=="P" if not "!MODE_INPUT!"=="p" if not "!MODE_INPUT!"=="R" if not "!MODE_INPUT!"=="r" (
    echo  Invalid choice. Please enter P or R.
    goto ask_mode
)

echo.
if "!DRY_RUN!"=="1" (
    echo  [PREVIEW MODE] No files will be moved.
) else (
    echo  [REAL RUN] Files will be moved.
)
echo.

:: ======================================================
:: Setup paths and files
:: ======================================================
set "LOG=%SOURCE%\changelog.txt"
set "UNDO=%SOURCE%\undo_last_run.bat"
set "SCRIPT_FULL=%~f0"
set "LOG_NAME=changelog.txt"
set "UNDO_NAME=undo_last_run.bat"

:: Counters
set /a COUNT_MOVED=0
set /a COUNT_FAILED=0
set /a COUNT_DUPES=0
set /a COUNT_RENAMED=0
set /a COUNT_PREVIEW=0

:: ======================================================
:: Prepare undo script header (real run only)
:: Folders are created on-demand inside processFile
:: ======================================================
if "!DRY_RUN!"=="0" (
    echo @echo off > "%UNDO%"
    echo setlocal enabledelayedexpansion >> "%UNDO%"
    echo echo Undoing last run... >> "%UNDO%"
    echo echo. >> "%UNDO%"
)

:: ======================================================
:: Write changelog header (box style)
:: ======================================================
call :write_log "╔══════════════════════════════════════════════════════════╗"
if "!DRY_RUN!"=="1" (
    call :write_log "║        ASENA'S FILE ORGANIZER v1.1  [PREVIEW MODE]      ║"
) else (
    call :write_log "║        ASENA'S FILE ORGANIZER v1.1                      ║"
)
call :write_log "║        Started : %date%  %time%              ║"
call :write_log "║        Source  : %SOURCE%"
call :write_log "╚══════════════════════════════════════════════════════════╝"
call :write_log ""

:: ======================================================
:: Main file loop — root-level files only
:: ======================================================
for %%f in ("%SOURCE%\*.*") do call :processFile "%%f" "%%~nxf" "%%~xf" "%%~zf" "%%~ff"

:: ======================================================
:: Write changelog footer (summary)
:: ======================================================
call :write_log ""
call :write_log "──────────────────────────────────────────────────────────"
if "!DRY_RUN!"=="1" (
    call :write_log "  PREVIEW  Would move: !COUNT_PREVIEW! files"
) else (
    call :write_log "  SUMMARY  Moved: !COUNT_MOVED!   Renamed: !COUNT_RENAMED!   Duplicates: !COUNT_DUPES!   Failed: !COUNT_FAILED!"
)
call :write_log "  Finished : %date%  %time%"
call :write_log "──────────────────────────────────────────────────────────"

:: Finalise undo script footer
if "!DRY_RUN!"=="0" (
    echo echo. >> "%UNDO%"
    echo echo Undo complete. >> "%UNDO%"
    echo pause >> "%UNDO%"
)

:: ======================================================
:: Print summary to screen
:: ======================================================
echo.
echo  ══════════════════════════════════════════
if "!DRY_RUN!"=="1" (
    echo   PREVIEW complete — !COUNT_PREVIEW! files would be moved.
    echo   No files were touched. Check changelog.txt for details.
) else (
    echo   Run complete!
    echo   Moved     : !COUNT_MOVED!
    echo   Renamed   : !COUNT_RENAMED!
    echo   Duplicates: !COUNT_DUPES!
    echo   Failed    : !COUNT_FAILED!
    echo.
    echo   Log saved at : %LOG%
)
echo  ══════════════════════════════════════════
echo.

:: ======================================================
:: STEP 3 — Undo prompt (real run only)
:: ======================================================
if "!DRY_RUN!"=="0" (
    set "UNDO_INPUT="
    set /p "UNDO_INPUT=  Undo last run? [Y/N]: "
    if /i "!UNDO_INPUT!"=="Y" (
        echo.
        echo  Reversing all moves...
        call "%UNDO%"
        echo  Done. All files returned to "%SOURCE%"
    )
)

echo.
pause
exit /b 0


:: ======================================================
:: SUBROUTINE: write_log
:: Writes a line to the changelog (always, even in dry-run)
:: ======================================================
:write_log
    echo %~1 >> "%LOG%"
exit /b


:: ======================================================
:: SUBROUTINE: processFile
:: Args: full_quoted_path, filename, ext, size, fullpath
:: ======================================================
:processFile
    set "FILEPATH=%~1"
    set "FILE=%~2"
    set "EXT=%~3"
    set "SIZE=%~4"
    set "FULLPATH=%~5"
    set "DEST="

    :: Skip the script itself (by full path), log, and undo script
    if /i "%FULLPATH%"=="%SCRIPT_FULL%"  exit /b
    if /i "%FILE%"=="%LOG_NAME%"         exit /b
    if /i "%FILE%"=="%UNDO_NAME%"        exit /b

    :: -------------------------------------------------------
    :: Duplicate check — filename already exists in Duplicates\
    :: -------------------------------------------------------
    if exist "%SOURCE%\Duplicates\%FILE%" (
        if "!DRY_RUN!"=="1" (
            call :write_log "  [PREVIEW]    %FILE%  ->  Duplicates"
            set /a COUNT_PREVIEW+=1
        ) else (
            if not exist "%SOURCE%\Duplicates" mkdir "%SOURCE%\Duplicates"
            move "%FILEPATH%" "%SOURCE%\Duplicates\" >nul 2>&1
            call :write_log "  [DUPLICATE]  %FILE%  ->  Duplicates"
            set /a COUNT_DUPES+=1
        )
        exit /b
    )

    :: -------------------------------------------------------
    :: IMAGES
    :: -------------------------------------------------------
    if /i "%EXT%"==".jpg"        set "DEST=Images"
    if /i "%EXT%"==".jpeg"       set "DEST=Images"
    if /i "%EXT%"==".png"        set "DEST=Images"
    if /i "%EXT%"==".gif"        set "DEST=Images"
    if /i "%EXT%"==".bmp"        set "DEST=Images"
    if /i "%EXT%"==".webp"       set "DEST=Images"
    if /i "%EXT%"==".heic"       set "DEST=Images"
    if /i "%EXT%"==".heif"       set "DEST=Images"
    if /i "%EXT%"==".tiff"       set "DEST=Images"
    if /i "%EXT%"==".tif"        set "DEST=Images"
    if /i "%EXT%"==".raw"        set "DEST=Images"
    if /i "%EXT%"==".cr2"        set "DEST=Images"
    if /i "%EXT%"==".cr3"        set "DEST=Images"
    if /i "%EXT%"==".nef"        set "DEST=Images"
    if /i "%EXT%"==".arw"        set "DEST=Images"
    if /i "%EXT%"==".dng"        set "DEST=Images"
    if /i "%EXT%"==".orf"        set "DEST=Images"
    if /i "%EXT%"==".rw2"        set "DEST=Images"
    if /i "%EXT%"==".svg"        set "DEST=Images"
    if /i "%EXT%"==".ico"        set "DEST=Images"
    if /i "%EXT%"==".psd"        set "DEST=Images"
    if /i "%EXT%"==".ai"         set "DEST=Images"
    if /i "%EXT%"==".eps"        set "DEST=Images"
    if /i "%EXT%"==".xcf"        set "DEST=Images"
    if /i "%EXT%"==".jfif"       set "DEST=Images"
    if /i "%EXT%"==".avif"       set "DEST=Images"

    :: -------------------------------------------------------
    :: DOCUMENTS
    :: -------------------------------------------------------
    if /i "%EXT%"==".pdf"        set "DEST=Documents"
    if /i "%EXT%"==".doc"        set "DEST=Documents"
    if /i "%EXT%"==".docx"       set "DEST=Documents"
    if /i "%EXT%"==".docm"       set "DEST=Documents"
    if /i "%EXT%"==".dot"        set "DEST=Documents"
    if /i "%EXT%"==".dotx"       set "DEST=Documents"
    if /i "%EXT%"==".txt"        set "DEST=Documents"
    if /i "%EXT%"==".rtf"        set "DEST=Documents"
    if /i "%EXT%"==".odt"        set "DEST=Documents"
    if /i "%EXT%"==".ods"        set "DEST=Documents"
    if /i "%EXT%"==".odp"        set "DEST=Documents"
    if /i "%EXT%"==".xlsx"       set "DEST=Documents"
    if /i "%EXT%"==".xls"        set "DEST=Documents"
    if /i "%EXT%"==".xlsm"       set "DEST=Documents"
    if /i "%EXT%"==".xltx"       set "DEST=Documents"
    if /i "%EXT%"==".pptx"       set "DEST=Documents"
    if /i "%EXT%"==".ppt"        set "DEST=Documents"
    if /i "%EXT%"==".pptm"       set "DEST=Documents"
    if /i "%EXT%"==".csv"        set "DEST=Documents"
    if /i "%EXT%"==".tsv"        set "DEST=Documents"
    if /i "%EXT%"==".xml"        set "DEST=Documents"
    if /i "%EXT%"==".xps"        set "DEST=Documents"
    if /i "%EXT%"==".wps"        set "DEST=Documents"
    if /i "%EXT%"==".wpd"        set "DEST=Documents"
    if /i "%EXT%"==".md"         set "DEST=Documents"
    if /i "%EXT%"==".tex"        set "DEST=Documents"
    if /i "%EXT%"==".pages"      set "DEST=Documents"
    if /i "%EXT%"==".numbers"    set "DEST=Documents"
    if /i "%EXT%"==".key"        set "DEST=Documents"

    :: -------------------------------------------------------
    :: VIDEOS
    :: -------------------------------------------------------
    if /i "%EXT%"==".mp4"        set "DEST=Videos"
    if /i "%EXT%"==".avi"        set "DEST=Videos"
    if /i "%EXT%"==".mkv"        set "DEST=Videos"
    if /i "%EXT%"==".mov"        set "DEST=Videos"
    if /i "%EXT%"==".wmv"        set "DEST=Videos"
    if /i "%EXT%"==".flv"        set "DEST=Videos"
    if /i "%EXT%"==".webm"       set "DEST=Videos"
    if /i "%EXT%"==".m4v"        set "DEST=Videos"
    if /i "%EXT%"==".3gp"        set "DEST=Videos"
    if /i "%EXT%"==".3g2"        set "DEST=Videos"
    if /i "%EXT%"==".mts"        set "DEST=Videos"
    if /i "%EXT%"==".m2ts"       set "DEST=Videos"
    if /i "%EXT%"==".vob"        set "DEST=Videos"
    if /i "%EXT%"==".ogv"        set "DEST=Videos"
    if /i "%EXT%"==".rmvb"       set "DEST=Videos"
    if /i "%EXT%"==".divx"       set "DEST=Videos"
    if /i "%EXT%"==".f4v"        set "DEST=Videos"
    if /i "%EXT%"==".asf"        set "DEST=Videos"

    :: -------------------------------------------------------
    :: AUDIO
    :: -------------------------------------------------------
    if /i "%EXT%"==".mp3"        set "DEST=Audio"
    if /i "%EXT%"==".wav"        set "DEST=Audio"
    if /i "%EXT%"==".flac"       set "DEST=Audio"
    if /i "%EXT%"==".aac"        set "DEST=Audio"
    if /i "%EXT%"==".ogg"        set "DEST=Audio"
    if /i "%EXT%"==".wma"        set "DEST=Audio"
    if /i "%EXT%"==".m4a"        set "DEST=Audio"
    if /i "%EXT%"==".opus"       set "DEST=Audio"
    if /i "%EXT%"==".aiff"       set "DEST=Audio"
    if /i "%EXT%"==".aif"        set "DEST=Audio"
    if /i "%EXT%"==".mid"        set "DEST=Audio"
    if /i "%EXT%"==".midi"       set "DEST=Audio"
    if /i "%EXT%"==".ape"        set "DEST=Audio"
    if /i "%EXT%"==".mka"        set "DEST=Audio"
    if /i "%EXT%"==".dsf"        set "DEST=Audio"
    if /i "%EXT%"==".dsd"        set "DEST=Audio"
    if /i "%EXT%"==".caf"        set "DEST=Audio"

    :: -------------------------------------------------------
    :: ARCHIVES
    :: -------------------------------------------------------
    if /i "%EXT%"==".zip"        set "DEST=Archives"
    if /i "%EXT%"==".rar"        set "DEST=Archives"
    if /i "%EXT%"==".7z"         set "DEST=Archives"
    if /i "%EXT%"==".tar"        set "DEST=Archives"
    if /i "%EXT%"==".gz"         set "DEST=Archives"
    if /i "%EXT%"==".bz2"        set "DEST=Archives"
    if /i "%EXT%"==".xz"         set "DEST=Archives"
    if /i "%EXT%"==".tgz"        set "DEST=Archives"
    if /i "%EXT%"==".cab"        set "DEST=Archives"
    if /i "%EXT%"==".iso"        set "DEST=Archives"
    if /i "%EXT%"==".img"        set "DEST=Archives"
    if /i "%EXT%"==".dmg"        set "DEST=Archives"
    if /i "%EXT%"==".lzma"       set "DEST=Archives"
    if /i "%EXT%"==".zst"        set "DEST=Archives"
    if /i "%EXT%"==".lz4"        set "DEST=Archives"

    :: -------------------------------------------------------
    :: EBOOKS
    :: -------------------------------------------------------
    if /i "%EXT%"==".epub"       set "DEST=Ebooks"
    if /i "%EXT%"==".mobi"       set "DEST=Ebooks"
    if /i "%EXT%"==".azw"        set "DEST=Ebooks"
    if /i "%EXT%"==".azw3"       set "DEST=Ebooks"
    if /i "%EXT%"==".djvu"       set "DEST=Ebooks"
    if /i "%EXT%"==".fb2"        set "DEST=Ebooks"
    if /i "%EXT%"==".lit"        set "DEST=Ebooks"
    if /i "%EXT%"==".cbz"        set "DEST=Ebooks"
    if /i "%EXT%"==".cbr"        set "DEST=Ebooks"

    :: -------------------------------------------------------
    :: CODE / SCRIPTS
    :: -------------------------------------------------------
    if /i "%EXT%"==".py"         set "DEST=Code"
    if /i "%EXT%"==".js"         set "DEST=Code"
    if /i "%EXT%"==".ts"         set "DEST=Code"
    if /i "%EXT%"==".html"       set "DEST=Code"
    if /i "%EXT%"==".htm"        set "DEST=Code"
    if /i "%EXT%"==".css"        set "DEST=Code"
    if /i "%EXT%"==".cpp"        set "DEST=Code"
    if /i "%EXT%"==".c"          set "DEST=Code"
    if /i "%EXT%"==".h"          set "DEST=Code"
    if /i "%EXT%"==".cs"         set "DEST=Code"
    if /i "%EXT%"==".java"       set "DEST=Code"
    if /i "%EXT%"==".kt"         set "DEST=Code"
    if /i "%EXT%"==".swift"      set "DEST=Code"
    if /i "%EXT%"==".go"         set "DEST=Code"
    if /i "%EXT%"==".rs"         set "DEST=Code"
    if /i "%EXT%"==".php"        set "DEST=Code"
    if /i "%EXT%"==".rb"         set "DEST=Code"
    if /i "%EXT%"==".sh"         set "DEST=Code"
    if /i "%EXT%"==".bat"        set "DEST=Code"
    if /i "%EXT%"==".cmd"        set "DEST=Code"
    if /i "%EXT%"==".ps1"        set "DEST=Code"
    if /i "%EXT%"==".lua"        set "DEST=Code"
    if /i "%EXT%"==".r"          set "DEST=Code"
    if /i "%EXT%"==".json"       set "DEST=Code"
    if /i "%EXT%"==".yaml"       set "DEST=Code"
    if /i "%EXT%"==".yml"        set "DEST=Code"
    if /i "%EXT%"==".toml"       set "DEST=Code"
    if /i "%EXT%"==".ini"        set "DEST=Code"
    if /i "%EXT%"==".cfg"        set "DEST=Code"
    if /i "%EXT%"==".sql"        set "DEST=Code"
    if /i "%EXT%"==".vue"        set "DEST=Code"
    if /i "%EXT%"==".jsx"        set "DEST=Code"
    if /i "%EXT%"==".tsx"        set "DEST=Code"
    if /i "%EXT%"==".dart"       set "DEST=Code"
    if /i "%EXT%"==".zig"        set "DEST=Code"
    if /i "%EXT%"==".nim"        set "DEST=Code"
    if /i "%EXT%"==".ex"         set "DEST=Code"
    if /i "%EXT%"==".exs"        set "DEST=Code"
    if /i "%EXT%"==".elm"        set "DEST=Code"
    if /i "%EXT%"==".tf"         set "DEST=Code"
    if /i "%EXT%"==".clj"        set "DEST=Code"

    :: -------------------------------------------------------
    :: EXECUTABLES / INSTALLERS
    :: -------------------------------------------------------
    if /i "%EXT%"==".exe"        set "DEST=Executables"
    if /i "%EXT%"==".msi"        set "DEST=Executables"
    if /i "%EXT%"==".msix"       set "DEST=Executables"
    if /i "%EXT%"==".appx"       set "DEST=Executables"
    if /i "%EXT%"==".apk"        set "DEST=Executables"
    if /i "%EXT%"==".ipa"        set "DEST=Executables"
    if /i "%EXT%"==".deb"        set "DEST=Executables"
    if /i "%EXT%"==".rpm"        set "DEST=Executables"
    if /i "%EXT%"==".pkg"        set "DEST=Executables"
    if /i "%EXT%"==".run"        set "DEST=Executables"
    if /i "%EXT%"==".bin"        set "DEST=Executables"
    if /i "%EXT%"==".com"        set "DEST=Executables"
    if /i "%EXT%"==".dll"        set "DEST=Executables"
    if /i "%EXT%"==".sys"        set "DEST=Executables"
    if /i "%EXT%"==".AppImage"   set "DEST=Executables"
    if /i "%EXT%"==".flatpak"    set "DEST=Executables"
    if /i "%EXT%"==".snap"       set "DEST=Executables"

    :: -------------------------------------------------------
    :: TEMP / JUNK
    :: -------------------------------------------------------
    if /i "%EXT%"==".tmp"        set "DEST=TempCleanup"
    if /i "%EXT%"==".temp"       set "DEST=TempCleanup"
    if /i "%EXT%"==".bak"        set "DEST=TempCleanup"
    if /i "%EXT%"==".old"        set "DEST=TempCleanup"
    if /i "%EXT%"==".crdownload" set "DEST=TempCleanup"
    if /i "%EXT%"==".part"       set "DEST=TempCleanup"
    if /i "%EXT%"==".cache"      set "DEST=TempCleanup"
    if /i "%EXT%"==".log"        set "DEST=TempCleanup"
    if /i "%EXT%"==".dmp"        set "DEST=TempCleanup"
    if /i "%EXT%"==".swp"        set "DEST=TempCleanup"

    :: -------------------------------------------------------
    :: Unrecognised — sort by size
    :: -------------------------------------------------------
    if not defined DEST call :sortBySize "%SIZE%"

    :: -------------------------------------------------------
    :: Dry-run: just log and count, don't move
    :: -------------------------------------------------------
    if "!DRY_RUN!"=="1" (
        call :write_log "  [PREVIEW]    %FILE%  ->  %DEST%"
        set /a COUNT_PREVIEW+=1
        exit /b
    )

    :: -------------------------------------------------------
    :: Collision-safe move: auto-rename if file already exists
    :: -------------------------------------------------------
    set "FINAL_NAME=%FILE%"
    set "BASE=%~n2"
    set "COLLISION_EXT=%EXT%"
    set /a COUNTER=1

    :rename_loop
    if exist "%SOURCE%\%DEST%\%FINAL_NAME%" (
        set "FINAL_NAME=%BASE%_%COUNTER%%COLLISION_EXT%"
        set /a COUNTER+=1
        goto rename_loop
    )

    :: Create destination folder only if needed (on-demand)
    if not exist "%SOURCE%\%DEST%" mkdir "%SOURCE%\%DEST%"

    :: Move the file
    move "%FILEPATH%" "%SOURCE%\%DEST%\%FINAL_NAME%" >nul 2>&1

    if errorlevel 1 (
        call :write_log "  [FAILED]     %FILE%  ->  %DEST%"
        set /a COUNT_FAILED+=1
    ) else (
        :: Was it renamed due to collision?
        if not "%FINAL_NAME%"=="%FILE%" (
            call :write_log "  [RENAMED]    %FILE%  ->  %DEST%\%FINAL_NAME%  (name conflict)"
            set /a COUNT_RENAMED+=1
        ) else (
            call :write_log "  [MOVED]      %FILE%  ->  %DEST%"
            set /a COUNT_MOVED+=1
        )
        :: Write undo entry (move back to source root)
        echo move "%SOURCE%\%DEST%\%FINAL_NAME%" "%SOURCE%\%FILE%" >> "%UNDO%"
    )

exit /b


:: ======================================================
:: SUBROUTINE: sortBySize
:: ======================================================
:sortBySize
    set "SZ=%~1"
    if !SZ! GEQ 104857600 (
        set "DEST=LargeFiles"
    ) else if !SZ! GEQ 1048576 (
        set "DEST=MediumFiles"
    ) else (
        set "DEST=SmallFiles"
    )
exit /b
