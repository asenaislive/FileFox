@echo off
setlocal enabledelayedexpansion

:: ======================================================
::   Test Environment Creator
::   Run this FIRST to set up dummy files for testing.
::   Then run file_organizer.bat on the same folder.
:: ======================================================

::   Edit the TEST_DIR below value to create dummy test files in your desired place
:: 	 Enter the same path in verify_results.bat

set "TEST_DIR=D:\TestFile"

echo.
echo  Creating test environment at: %TEST_DIR%
echo.

if not exist "%TEST_DIR%" mkdir "%TEST_DIR%"

:: -------------------------------------------------------
:: Helper: create a dummy file of roughly N bytes
:: echo some text repeatedly into files
:: -------------------------------------------------------

:: --- Batch 1: Normal everyday files ----------------------
call :make "%TEST_DIR%\photo.jpg"            small
call :make "%TEST_DIR%\vacation.png"         small
call :make "%TEST_DIR%\logo.svg"             small
call :make "%TEST_DIR%\report.docx"          small
call :make "%TEST_DIR%\budget.xlsx"          small
call :make "%TEST_DIR%\notes.txt"            small
call :make "%TEST_DIR%\movie.mp4"            small
call :make "%TEST_DIR%\clip.mkv"             small
call :make "%TEST_DIR%\song.mp3"             small
call :make "%TEST_DIR%\podcast.flac"         small
call :make "%TEST_DIR%\backup.zip"           small
call :make "%TEST_DIR%\archive.7z"           small
call :make "%TEST_DIR%\novel.epub"           small
call :make "%TEST_DIR%\manual.mobi"          small
call :make "%TEST_DIR%\script.py"            small
call :make "%TEST_DIR%\index.html"           small
call :make "%TEST_DIR%\styles.css"           small
call :make "%TEST_DIR%\setup.exe"            small
call :make "%TEST_DIR%\installer.msi"        small
call :make "%TEST_DIR%\temp_dl.crdownload"   small
call :make "%TEST_DIR%\old_config.bak"       small
call :make "%TEST_DIR%\error.log"            small
call :make "%TEST_DIR%\crash.dmp"            small

:: --- Batch 2: New v1.1 extensions ------------------------
call :make "%TEST_DIR%\presentation.key"     small
call :make "%TEST_DIR%\budget2.numbers"      small
call :make "%TEST_DIR%\writer.pages"         small
call :make "%TEST_DIR%\app.AppImage"         small
call :make "%TEST_DIR%\package.flatpak"      small
call :make "%TEST_DIR%\hello.zig"            small
call :make "%TEST_DIR%\infra.tf"             small
call :make "%TEST_DIR%\server.ex"            small
call :make "%TEST_DIR%\music_hires.dsf"      small
call :make "%TEST_DIR%\compressed.lz4"       small

:: --- Batch 3: Uppercase extensions (was broken in v1.0) --
call :make "%TEST_DIR%\PHOTO.JPG"            small
call :make "%TEST_DIR%\DOCUMENT.PDF"         small
call :make "%TEST_DIR%\VIDEO.MP4"            small

:: --- Batch 4: Collision test -----------------------------
:: photo.jpg already exists - organizer should rename this
call :make "%TEST_DIR%\Images\photo.jpg"     small
:: song.mp3 already exists in Audio\
if not exist "%TEST_DIR%\Audio" mkdir "%TEST_DIR%\Audio"
call :make "%TEST_DIR%\Audio\song.mp3"       small

:: --- Batch 5: Duplicate test -----------------------------
:: Put a file in Duplicates\ first, then create same name in root
if not exist "%TEST_DIR%\Duplicates" mkdir "%TEST_DIR%\Duplicates"
call :make "%TEST_DIR%\Duplicates\report.docx"  small
:: report.docx also exists in root (created in Batch 1)
:: organizer should detect it as duplicate

:: --- Batch 6: Unknown extensions -> size sort ------------
call :make "%TEST_DIR%\weirdfile.xyz"        small
call :make "%TEST_DIR%\datafile.bin2"        small
call :make "%TEST_DIR%\archive.dat"          small

:: --- Batch 7: Edge cases ---------------------------------
call :make "%TEST_DIR%\noextension"          small
call :make "%TEST_DIR%\.hidden"              small
call :make "%TEST_DIR%\file with spaces.mp3" small
call :make "%TEST_DIR%\file.tar.gz"          small

:: --- Batch 8: Files that should be SKIPPED ---------------
:: changelog.txt and undo_last_run.bat should never be moved
call :make "%TEST_DIR%\changelog.txt"        small
call :make "%TEST_DIR%\undo_last_run.bat"    small

echo.
echo  ==========================================
echo   Test environment ready!
echo.
echo   Folder  : %TEST_DIR%
echo   Files   : See above
echo.
echo   WHAT TO DO NEXT:
echo   1. Press any key to add more dummy files for testing or Ctrl + C to stop
echo   2. Run file_organizer.bat
echo   3. Enter path : D:\TestFile
echo   4. Try [P] first (preview), then [R] (real run)
echo   5. Check D:\TestFile\changelog.txt for results
echo   6. Try undo at the end to verify reversal
echo  ==========================================
echo.
pause
exit /b 0


:: ======================================================
:: SUBROUTINE: make a dummy file
:: ======================================================
:make
    set "FPATH=%~1"
    set "FDIR=%~dp1"
    if not exist "!FDIR!" mkdir "!FDIR!"
    echo DUMMY TEST FILE - SAFE TO DELETE > "!FPATH!"
    echo Created: %~1
exit /b
