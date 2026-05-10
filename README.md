<div align="center">

```
   ███████╗██╗██╗     ███████╗███████╗ ██████╗ ██╗  ██╗
   ██╔════╝██║██║     ██╔════╝██╔════╝██╔═══██╗╚██╗██╔╝
   █████╗  ██║██║     █████╗  █████╗  ██║   ██║ ╚███╔╝ 
   ██╔══╝  ██║██║     ██╔══╝  ██╔══╝  ██║   ██║ ██╔██╗ 
   ██║     ██║███████╗███████╗██║     ╚██████╔╝██╔╝ ██╗
   ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝
```

**Your files are a mess. FileFox isn't.**

[![Version](https://img.shields.io/badge/version-1.1-orange?style=flat-square)](https://github.com/asenaislive/FileFox)
[![Platform](https://img.shields.io/badge/platform-Windows-blue?style=flat-square)](https://github.com/asenaislive/FileFox)
[![Language](https://img.shields.io/badge/language-Batch-red?style=flat-square)](https://github.com/asenaislive/FileFox)
[![License](https://img.shields.io/badge/license-Free-green?style=flat-square)](https://github.com/asenaislive/FileFox)

</div>

---

## What is FileFox?

FileFox is a Windows batch script that looks at your chaotic folder full of random files and sorts everything into neat, labelled subfolders — automatically. No installation. No Python. No Node. No nonsense. Just double-click and watch it go.

Think of it as a very fast, very obedient assistant who never complains about how messy your Downloads folder is.

---

## ✨ What's New in v1.1

v1.1 is a big one. The focus was **safety first** — so you can run FileFox without fear.

| | Feature | What it means for you |
|---|---|---|
| 🔍 | **Preview mode** | See exactly what *would* happen before anything actually moves |
| ↩️ | **Undo last run** | Made a mistake? One prompt and everything goes back |
| 📂 | **You pick the folder** | No more hardcoded paths — just type the folder at launch |
| 🔁 | **Collision-safe renaming** | `photo.jpg` already there? It becomes `photo_1.jpg`. Nothing gets overwritten |
| 📋 | **Box-style changelog** | Clean, readable run log with a full summary footer |
| 🗂️ | **Folders created on demand** | No more empty ghost folders cluttering your directory |
| 🛡️ | **Self-aware script** | FileFox won't accidentally move or break itself, even if you rename it |
| ➕ | **17 new extensions** | Apple iWork, Linux apps, hi-res audio, modern languages and more |

---

## 🚀 Getting Started

**No installation required.** Seriously.

1. Download `filefox.bat` from this repo
2. Double-click it
3. Type in the path to the folder you want to sort (e.g. `D:\Downloads`)
4. Choose **P** for Preview or **R** for Real run
5. Watch the magic happen

> 💡 **Never used a batch file before?** That's totally fine. A `.bat` file is just a script Windows can run directly. No extra software needed — it works on any Windows 7 or later machine out of the box.

---

## 📁 Where Do Files Go?

After a run, your folder will look like this:

```
YourFolder/
├── 🖼️  Images/          → jpg, png, gif, heic, psd, raw, svg, ai, avif ...
├── 📄  Documents/       → pdf, docx, xlsx, pptx, txt, csv, md, pages, numbers ...
├── 🎬  Videos/          → mp4, mkv, mov, avi, webm, flv, vob ...
├── 🎵  Audio/           → mp3, flac, wav, aac, ogg, opus, midi, dsf ...
├── 🗜️  Archives/        → zip, rar, 7z, tar, iso, dmg, gz, lz4 ...
├── 📚  Ebooks/          → epub, mobi, azw3, djvu, cbz, fb2 ...
├── 💻  Code/            → py, js, ts, html, css, sql, json, zig, tf, elm ...
├── ⚙️  Executables/     → exe, msi, apk, deb, rpm, dll, AppImage, flatpak ...
├── 🧹  TempCleanup/     → tmp, bak, old, crdownload, log, dmp, swp ...
├── 📦  Duplicates/      → files that already existed in Duplicates\
├── 📏  SmallFiles/      → unknown files under 1 MB
├── 📏  MediumFiles/     → unknown files between 1–100 MB
├── 📏  LargeFiles/      → unknown files over 100 MB
└── 📝  changelog.txt    → full log of everything that happened
```

Folders are only created if there are files that need to go in them. No empty folders left behind.

---

## 📋 The Changelog

Every run writes a clean, readable log to `changelog.txt` in your sorted folder. Here's what it looks like:

```
╔══════════════════════════════════════════════════════════╗
║        FILEFOX v1.1                                      ║
║        Started : 10/05/2026  14:32:01                    ║
║        Source  : D:\Downloads                            ║
╚══════════════════════════════════════════════════════════╝

  [MOVED]      vacation.jpg         ->  Images
  [MOVED]      invoice_march.pdf    ->  Documents
  [RENAMED]    photo.jpg            ->  Images\photo_1.jpg  (name conflict)
  [DUPLICATE]  setup.exe            ->  Duplicates
  [PREVIEW]    notes.txt            ->  Documents

──────────────────────────────────────────────────────────
  SUMMARY  Moved: 38   Renamed: 2   Duplicates: 1   Failed: 0
  Finished : 10/05/2026  14:32:04
──────────────────────────────────────────────────────────
```

---

## 🧪 Want to Test It First?

There's a ready-made test kit in the `/tests` folder of this repo:

| File | What it does |
|---|---|
| `create_test_env.bat` | Creates a `C:\FileFoxTest\` folder with 46 dummy files across 8 test batches |

**How to use it:**

```
1. Run test_env.bat              → sets up the dummy folder
2. Run file_organizer.bat        → point it at the the directory that you entered in test_env.bat (The default is D:\TestFile)
```

It covers normal files, uppercase extensions, collisions, duplicates, edge cases, and files that must NOT move (like the changelog and undo script). Great way to get comfortable before running it on your real files.

---

## ↩️ Undo a Run

Made a mistake? At the end of every real run, FileFox asks:

```
  Undo last run? [Y/N]:
```

Hit **Y** and every single file gets moved back to where it came from. It also generates an `undo_last_run.bat` file in your folder, so you can run it manually later if you close the window too fast.

> ⚠️ Undo only covers the **most recent run**. Running FileFox again overwrites the previous undo data.

---

## 🔍 Preview Before You Commit

Not ready to actually move anything? Choose **P** at the mode prompt:

```
  Run mode — [P] Preview (dry-run)  /  [R] Real run:
```

FileFox will scan your folder, log exactly what it *would* do, and show you a count — without touching a single file. Check `changelog.txt` afterwards to review the full plan.

---

## 📦 Supported Extensions

<details>
<summary>Click to expand the full list</summary>

| Category | Extensions |
|---|---|
| Images | `.jpg` `.jpeg` `.png` `.gif` `.bmp` `.webp` `.heic` `.heif` `.tiff` `.raw` `.cr2` `.cr3` `.nef` `.arw` `.dng` `.orf` `.rw2` `.svg` `.ico` `.psd` `.ai` `.eps` `.xcf` `.jfif` `.avif` |
| Documents | `.pdf` `.doc` `.docx` `.docm` `.dot` `.dotx` `.txt` `.rtf` `.odt` `.ods` `.odp` `.xlsx` `.xls` `.xlsm` `.xltx` `.pptx` `.ppt` `.pptm` `.csv` `.tsv` `.xml` `.xps` `.wps` `.wpd` `.md` `.tex` `.pages` `.numbers` `.key` |
| Videos | `.mp4` `.avi` `.mkv` `.mov` `.wmv` `.flv` `.webm` `.m4v` `.3gp` `.3g2` `.mts` `.m2ts` `.vob` `.ogv` `.rmvb` `.divx` `.f4v` `.asf` |
| Audio | `.mp3` `.wav` `.flac` `.aac` `.ogg` `.wma` `.m4a` `.opus` `.aiff` `.aif` `.mid` `.midi` `.ape` `.mka` `.dsf` `.dsd` `.caf` |
| Archives | `.zip` `.rar` `.7z` `.tar` `.gz` `.bz2` `.xz` `.tgz` `.cab` `.iso` `.img` `.dmg` `.lzma` `.zst` `.lz4` |
| Ebooks | `.epub` `.mobi` `.azw` `.azw3` `.djvu` `.fb2` `.lit` `.cbz` `.cbr` |
| Code | `.py` `.js` `.ts` `.html` `.htm` `.css` `.cpp` `.c` `.h` `.cs` `.java` `.kt` `.swift` `.go` `.rs` `.php` `.rb` `.sh` `.bat` `.cmd` `.ps1` `.lua` `.r` `.json` `.yaml` `.yml` `.toml` `.ini` `.cfg` `.sql` `.vue` `.jsx` `.tsx` `.dart` `.zig` `.nim` `.ex` `.exs` `.elm` `.tf` `.clj` |
| Executables | `.exe` `.msi` `.msix` `.appx` `.apk` `.ipa` `.deb` `.rpm` `.pkg` `.run` `.bin` `.com` `.dll` `.sys` `.AppImage` `.flatpak` `.snap` |
| TempCleanup | `.tmp` `.temp` `.bak` `.old` `.crdownload` `.part` `.cache` `.log` `.dmp` `.swp` |

</details>

---

## ⚠️ Good to Know

- FileFox only processes **root-level files** — it won't touch subfolders inside your target directory
- Files are **moved**, not copied — originals are removed from the source after sorting
- Running FileFox on an already-sorted folder is safe — files inside subfolders are ignored
- If a file can't be moved (locked, no permission), it stays put and gets logged as `[FAILED]`
- FileFox won't move itself, the changelog, or the undo script, no matter what they're named

---

## 🖥️ Requirements

- Windows 7 or later
- That's it

---

## 📜 License

Free to use, modify, and share. Do whatever you want with it.

---

<div align="center">

Made with stubbornness and batch scripting by **[@asenaislive](https://github.com/asenaislive)**

*If FileFox saved your Downloads folder, consider leaving a ⭐*

</div>
