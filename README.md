# Sahayak — Protocol in every pocket

A voice-first, offline-first decision-support app for ASHA/ANM health workers.
It turns a national protocol into a short guided screening in Hindi and English,
stops early on red flags, and hands the worker a printable referral slip.

Built with Flutter. Runs on Android, iOS, desktop, and the web from one codebase.

## What it does

- **Guided screening** — the maternal danger-sign protocol asks one question at a
  time, in Hindi with an English gloss, and records each answer as read back to
  the worker.
- **Deterministic engine** — answers map to green / amber / red outcomes. Red
  short-circuits the questionnaire immediately. Every result carries a protocol
  reference (`id@version#terminal`, e.g.
  `maternal-danger-signs@1.0.0#emergency_referral`).
- **Referral slip** — red and amber results generate an A4 PDF with patient
  details, findings, next actions, and the protocol reference. Save it or print
  it straight from the preview screen.
- **Local history** — saved referrals are persisted with `shared_preferences` on
  the device only. Nothing leaves the phone.
- **Works offline** — no network calls at runtime. Fonts and the protocol are
  bundled in the app.

## Run it

The Flutter SDK used for development lives at `S:\flutter`. Add its `bin`
directory to `PATH` (or call it by full path), then:

```bash
flutter pub get
flutter run -d chrome      # or: flutter run -d windows / an attached device
```

Build a static web release:

```bash
flutter build web --release --no-web-resources-cdn
```

Build an installable Android APK:

```bash
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk (universal, ~50 MB)
```

Release signing uses `android/key.properties` and
`android/app/sahayak-release.jks` (both git-ignored, demo-only). Without those
files the build falls back to debug signing.

## Test it

```bash
flutter analyze
flutter test
```

The suite covers the protocol engine, case persistence, the full screening flow
(including red short-circuit and the amber wait-for-all-answers rule), the PDF
builder, and the referral slip layout at phone width.

## Project structure

```
lib/
  main.dart                 app entry, loads the case store before runApp
  theme.dart                colours, type scale, Material 3 theme
  models/
    protocol.dart           Protocol, Question, Terminal, Risk, Evaluation
    case_record.dart        persisted referral record
  engine/
    protocol_engine.dart    deterministic evaluate()
  data/
    maternal_protocol.dart  the bundled v1.0.0 protocol
  storage/
    case_store.dart         JSON persistence with ChangeNotifier
  pdf/
    slip_pdf.dart           A4 referral slip (package:pdf)
    save_pdf.dart           conditional export: browser download / share sheet
  screens/
    home_shell.dart         bottom navigation shell
    home_tab.dart           landing, protocol card, how it works
    screening_screen.dart   one question at a time
    result_screen.dart      risk, findings, action, next steps
    slip_form_screen.dart   patient details form
    slip_preview_screen.dart native slip preview + Save PDF / Print
    history_tab.dart        saved referrals
  widgets/                  brand mark, risk badge, section label, case tile
assets/fonts/               Fraunces, Inter, Noto Sans Devanagari (OFL)
test/                       engine, store, flow, PDF and layout tests
```

## Adding a protocol

Add a `Protocol` in `lib/data/` with questions marked `isRed` where a positive
answer must stop the screening, plus a terminal for each risk level. Pass it to
`evaluate()`; the engine and the offline storage require no changes.

## Disclaimer

This is a hackathon prototype. The bundled protocol is an illustrative excerpt
and the app is not a medical device. It does not replace clinical judgement or
any national guideline.
