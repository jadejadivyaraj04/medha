# Medha

**Offline · Private · On-device AI**

Medha is a prescription decoder and medication reminder for elderly users. Scan a prescription, understand the schedule in Gujarati, Hindi, or English, and get reminders — all on your phone. No prescription data leaves the device.

<p align="center">
  <img src="https://i.ibb.co/LzS2VLpR/device-mockup-1-5x-postspark-2026-07-07-16-46-48.png" alt="Medha app — Home, History, and Medicines" width="720" />
</p>

<p align="center">
  <em>Home · History · Medicines</em>
</p>

---

## What Medha does

- **Scan a prescription** — camera or gallery; on-device AI reads medicines, dose, timing, and duration
- **Verify before save** — you confirm every medicine; nothing is scheduled until you approve
- **Listen aloud (Sambhdo)** — schedule and medicine details spoken in Gujarati, Hindi, or English
- **Ask offline** — speak a medicine question; answers use only what’s on your phone
- **Today’s doses** — morning / afternoon / night timeline with Taken / Skip
- **History** — month calendar, adherence stats, optional share-with-doctor PDF
- **Refill nudges** — gentle reminders when supply is running low
- **100% offline** — AI and data stay on the device

> Medha is **AI, not a doctor**. It reads and reminds — it does not diagnose or change doses.

---

## Screens at a glance

| Screen | Purpose |
|--------|---------|
| **Home** | Greeting, offline trust badge, Ask, today’s doses, refill nudge |
| **Medicines** | Active / completed list with listen-aloud and details |
| **History** | Monthly adherence ring, calendar heat view, doctor share |
| **Scan** | Capture prescription → AI parse → verify → reminders |
| **Reminders** | Day timeline with Taken / Snooze / Skip |
| **Profile & Settings** | Language, font size, voice, permissions, model management |

---

## On-device AI

Powered by [flutter_gemma](https://pub.dev/packages/flutter_gemma) (Gemma 3n):

| Capability | How it’s used |
|------------|----------------|
| **Vision** | Read prescription images into structured medicine data |
| **Audio** | Answer spoken medicine questions offline |
| **RAG** | Side effects, food rules, and interaction hints from a local knowledge base |

Model download is one-time (gated Gemma model on Hugging Face). Pass a read token at run time — never commit tokens:

```bash
flutter run --dart-define=HUGGINGFACE_TOKEN=hf_your_token
```

Accept the Gemma license on Hugging Face before downloading.

---

## Run locally

**Requirements**

- Flutter 3.27+
- Android **arm64-v8a** device/emulator (recommended for full vision AI)
- iOS 16+ (memory entitlements required for the large model)

```bash
flutter pub get
flutter run
```

By default the app can run in mock mode for UI demos without the multi‑GB model. Turn off mock when you want real on-device inference.

---

## Languages

| Language | Locale |
|----------|--------|
| English | `en` |
| ગુજરાતી | `gu` |
| हिंदी | `hi` |

---

## Privacy

- Prescription photos and parsed medicine data **never leave the phone**
- No account / login server in MVP
- No cloud upload of medical data
- Caregiver / doctor share is **opt-in** and user-triggered only

---

## License

Private project. All rights reserved.
