@echo off
chcp 1251 > nul
setlocal enabledelayedexpansion
title MarkFlow - sborka montazha

echo.
echo =================================================
echo   MarkFlow -- avtomaticheskiy montazh Makashenets
echo =================================================
echo.

REM --- VASH PUT K VIDEO-FAJLU ---
REM Izmeni etu stroku: ukazi polnyj put' k fajlu .mov ili .mp4
set "VPATH=C:\Users\Artem\Videos\Ìàêàøåíåö\ÌÎÄÍÀß ÏÐÎÏÀÃÀÍÄÀ\Êîïèÿ Keyed-Video_2608311425_0001.mov"

set "AUDIO=%~dp0audio_standup.wav"
set "WORDS=%~dp0words.json"
set "GDOC=%~dp0gdoc_raw.json"
set "SCEN=%~dp0scenarij.txt"
set "OUTDIR=%~dp0output_final"

cd /d "%~dp0"

REM --- ØÀGJ 0: proverka ---
echo [0/5] Proverka Python i ffmpeg...

python --version > nul 2>&1
if errorlevel 1 (
    echo   OSHIBKA: Python ne naiden. Skachai s https://python.org
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('python --version 2^>&1') do echo   Python: %%v

ffmpeg -version > nul 2>&1
if errorlevel 1 (
    echo   OSHIBKA: ffmpeg ne naiden.
    echo   Ustanovi: winget install Gyan.FFmpeg
    echo   Ili skachai s ffmpeg.org i dobav' bin\ v PATH
    pause
    exit /b 1
)
echo   ffmpeg: OK

echo   Ustanavlivayu faster-whisper (esli net)...
python -m pip install -q faster-whisper
echo   faster-whisper: OK
echo.

REM --- ØÀGJ 1: scenarij ---
echo [1/5] Proverka scenariya...

if exist "%GDOC%" (
    echo   gdoc_raw.json est' -- propuskayu.
    goto STEP2
)

if not exist "%SCEN%" (
    echo.
    echo   NUZHEN SCENARIJJ:
    echo   1. Otkrojj Google Doc scenarij
    echo   2. Fajl -^> Skachat' -^> Obychnyj tekst (.txt)
    echo   3. Pereimenovajj v: scenarij.txt
    echo   4. Polozhijj ryadom s etim .bat fajlom
    echo   5. Zapusti snova.
    echo.
    pause
    exit /b 1
)

python -c "import json,sys; t=open(sys.argv[1],encoding='utf-8',errors='replace').read(); json.dump({'fileContent':t},open(sys.argv[2],'w',encoding='utf-8'),ensure_ascii=False); print('OK:',len(t),'chars')" "%SCEN%" "%GDOC%"
if errorlevel 1 ( echo OSHIBKA konvertacii & pause & exit /b 1 )

:STEP2
echo.

REM --- ØÀGJ 2: audio ---
echo [2/5] Izvlechenie audio iz video...

if exist "%AUDIO%" (
    echo   audio_standup.wav est' -- propuskayu.
    goto STEP3
)

if not exist "%VPATH%" (
    echo.
    echo   OSHIBKA: video fajl ne naiden:
    echo   %VPATH%
    echo   Otkrojj etot .bat v Notepade i izmeni stroku set VPATH=...
    echo.
    pause
    exit /b 1
)

echo   Izvlekayu audio (tol'ko zvuk, 5-15 min)...
ffmpeg -i "%VPATH%" -vn -acodec pcm_s16le -ar 16000 -ac 1 "%AUDIO%" -y
if errorlevel 1 ( echo OSHIBKA ffmpeg & pause & exit /b 1 )
echo   Audio gotovo: %AUDIO%

:STEP3
echo.

REM --- ØÀGJ 3: ASR (Whisper) ---
echo [3/5] Transkripciya Whisper large-v3...

if exist "%WORDS%" (
    echo   words.json est' -- propuskayu.
    goto STEP4
)

echo   1-j zapusk: skachaet model' ~3 GB.
echo   75 min video ~ 40-60 min na CPU.
echo   Mozhno ujjti, sdelat' chaj i vernut'sya.
echo.
python markflow\tools\run_asr.py "%AUDIO%" -o "%WORDS%"
if errorlevel 1 ( echo OSHIBKA ASR & pause & exit /b 1 )

:STEP4
echo.

REM --- ØÀGJ 4: pipeline ---
echo [4/5] Sbork montazha (pipeline)...

python -m markflow.pipeline.run_pipeline --gdoc_json "%GDOC%" --words_json "%WORDS%" --video_path "%VPATH%" --out_dir "%OUTDIR%" --project_name "Modnaya_propaganda_ch2" --fps 60.0

if errorlevel 1 (
    echo.
    echo   OSHIBKA v pipeline. Chitajj soobshheniya vyshe.
    pause
    exit /b 1
)

echo.
echo [5/5] GOTOVO!
echo.
echo   Otkrojj v Premiere Pro: File -^> Import
echo   Vyiberi fajl: %OUTDIR%\Modnaya_propaganda_ch2.xml
echo.
echo   Esli Import ne rabotaet: File -^> Open Project
echo   Vyiberi fajl: %OUTDIR%\Modnaya_propaganda_ch2.prproj
echo.
explorer "%OUTDIR%"
pause
