# VB 4.8.0 - Source, portable browser and offline compiler

VB is ready to run. Building is optional. This kit includes the blue/turquoise browser, transparent VB icon, editable JA21 sources, compiler sources, bundled compiler runtimes, installer sources, licenses and a printable instructions sheet.

## Get the complete kit

1. Download every numbered `.zip.001`, `.zip.002`, etc. part and `START-HERE.zip` into one folder. Keep their names unchanged.
2. Extract `START-HERE.zip`. Open `Join VB Parts.cmd` in the extracted folder. It finds the parts in that folder or its parent.
3. The helper checks each part, rejoins the ZIP, checks its complete hash and extracts a new `VB-JA21-4.8.0-Kit-Ready` folder beside the parts. Open the kit inside it.
4. Double-click `Verify Kit.cmd`, then `Run VB.cmd` to browse.

Every full part is exactly 24,000,000 bytes (24 MB); the final part is smaller. Numbered parts are fragments of one ZIP, not independently extractable ZIP files. The parts and starter all stay below the requested 24 MB limit. Keep about 2 GB free for assembly and building.

## The four controls

| Open this file | What it does |
|---|---|
| Run VB.cmd | Opens the portable browser; no installation required. |
| Compile VB.cmd | Rebuilds JA21 application, interface and design outputs, checks them and refreshes the integrity inventories. |
| Build Installer.cmd | Compiles first, then creates `Builds/VB-JA21-4.8.0-Setup.exe`. |
| Verify Kit.cmd | Checks the complete kit against its saved file hashes. Use it after extraction and after rebuilding. |

## What the compiler includes

The JA/JAUI compiler and bounded VM are in `VB/app/runtime/ja21.js`; the supplied JAXD bootstrap compiler is `VB/tools/jxd_compiler.py`. `Compiler/compile.cjs` drives them. The kit includes an isolated CPython 3.13.14 Windows x64 runtime, plus the existing Electron Node runtime used for the JavaScript compiler. JA21 compilation needs no separately installed Python, Node, package manager, Internet connection or paid service.

Installer building additionally uses the Windows .NET Framework 4 compiler and WPF libraries at `%WINDIR%/Microsoft.NET/Framework64/v4.0.30319/`. If they are absent, JA21 compilation still works; the build window explains the missing installer prerequisite. The Microsoft compiler is not redistributed in this kit.

This is the working VB JA21 subset described in `VB/docs/EXECUTABLE-PROFILE.md`. It is not a compiler for every feature in all twenty language suites. The inherited Electron/Chromium executable is reused, not compiled from Chromium source. Optional image-authoring utilities require Pillow/NumPy/SciPy and are not needed to run or compile VB.

## Edit and rebuild

Close VB before rebuilding. Edit `VB/source/browser.ja` (behavior), `VB/source/chrome.jaui` (controls), or `VB/source/glass.jxd` (design). Open `Compile VB.cmd`. Only run the browser after it reports success. Open `Build Installer.cmd` if you want a new installer. Failed builds report the problem and do not claim success. After editing, an old integrity check can fail until compilation refreshes it.

## Storage, downloads and DeleteMe

Portable data is stored in `VB/profile`. Installed data keeps the existing Air Glass profile location for compatibility; close an older instance before opening VB. DeleteMe reviews this installation, its app data, matching shortcuts and downloads recorded by VB, plus earlier files you explicitly select. It does not erase the general Windows Downloads folder. Backup any data you want before confirming deletion. Full details are in `VB/docs/DELETEME.md`.

## License and notices

`LICENSE` contains the full Apache License 2.0 text for new contributions and kit packaging. `NOTICE` indexes attributions. The distribution also contains inherited private / UNLICENSED components and third-party software under its own terms, so it is not presented as wholly Apache-licensed. Read `LICENSING.md` and `VB/THIRD-PARTY-NOTICES.md`; all supplied license texts remain included. CPython's complete license and Windows binary conditions are in `Compiler/Python/LICENSE.txt`.

## Validation and limits

The original VB installer and source checks passed, and this kit is tested by reassembly, complete file verification, the bundled compiler and a local installer rebuild. Detailed delivery evidence is supplied alongside the parts. Live Chromium rendering and the complete production DeleteMe handoff remain unverified in the current build environment. The included Electron 31 runtime remains the previously documented legacy version.

`INSTRUCTIONS.html` is a printable one-page guide. `INSTRUCTIONS.txt` provides the same essential steps in plain text. Part hashes detect changed or incomplete transfers; they are not a publisher signature.
