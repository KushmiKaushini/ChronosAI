# Project Plan & Proposal — ChronosAI

**Prepared by:** K K K Ekanayake
**Date:** June 27, 2026
**Status:** PENDING CLIENT APPROVAL

---

## 1. Executive Summary

ChronosAI is a Flutter Android application that transforms static annual goal-setting into a dynamic, voice-first conversational coaching experience powered by the Gemini Live AI. By combining ultra-low-latency bidirectional voice streaming with a fully local, Isar-backed relational database (goals, habits, milestones, journal entries), the app delivers intelligent behavioral coaching while maintaining absolute user privacy — no backend server, no cloud data, no account required.

---

## 2. Product Vision

**Vision Statement:** Every professional and student should have access to an intelligent, private year-planning coach that adapts in real-time to their actual life — not a static PDF template.

**Problem:** Traditional goal-setting apps are passive. You write goals, forget them, and revisit them in December disappointed. There's no real-time adaptation, no conversational re-planning when life gets chaotic.

**Solution:** A voice-first AI companion that understands your year plan, your daily habits, and your milestones — and coaches you through it all in natural conversation, using only the data you've already stored locally.

---

## 3. Target Audience & Personas

### Persona A — "Professional Priya" (default: Professional mode)
- 28-40 years old, mid-to-senior professional
- Uses OKRs at work, wants personal life equally structured
- Pain: Work-life balance chaos, goals scattered across apps
- Wants: Weekly voice audit ("How am I tracking on Q2 goals?"), milestone re-planning, accountability
- Tech comfort: High

### Persona B — "Student Sam" (Student mode)
- 18-24 years old, university student
- Pain: Semester planning, exam prep, thesis deadlines, procrastination
- Wants: Exam countdown coaching, study habit tracking, adaptive scheduling during crunch periods
- Tech comfort: Medium-high

**Onboarding:** Single screen at launch — "I'm a Professional" or "I'm a Student". This selection tailors Gemini's coaching persona, default goal categories, and milestone templates.

---

## 4. Core Feature Set (MVP)

### F-01 — Gemini Live Voice Streaming (PRIMARY interaction)
- Bidirectional real-time voice via `google_generative_ai` Dart package (Live API)
- Microphone push-to-talk + optional always-listening wake mode
- Text fallback input for silent/quiet environments
- Voice activity detection with visual feedback (glow states)
- System audio session management (duck music, handle interruptions)

### F-02 — Local Isar Database (fully offline)
- **Goals:** title, description, category, priority, target date, status, linked milestones
- **Milestones:** title, due date, progress %, parent goal, dependencies
- **Habits (recurring):** title, frequency (daily/weekly/custom), target days, streak, completion log
- **Journal Entries:** text, timestamp, linked goal/milestone (optional), mood tag
- **User Profile:** persona type (professional/student), onboarding complete, preferences
- Relational queries: "all goals with overdue milestones", "habits missed 3+ days", "journal entries this week"

### F-03 — AI Coaching Engine
- Gemini Live session with full local DB context injected into system prompt
- Dynamic prompt construction: pull real-time stats (goal completion %, habit streaks, overdue items) and inject into conversation context
- Coaching modes: motivational ("keep going"), analytical ("you're behind on X"), re-planning ("let's adjust your timeline")
- No rule-based triggers — purely Gemini-powered, context-aware responses

### F-04 — Onboarding Flow
- Splash → Persona selection (Professional / Student) → API key input (or skip for demo mode) → Permission grant (mic) → Home
- API key stored via `flutter_secure_storage` (Android Keystore-backed)
- Optional: pre-seed sample data for instant demo experience

### F-05 — Progress Audit (voice-initiated, no background scheduling)
- User says: "How am I doing this week?" / "Audit my Q2 goals"
- Gemini queries local DB context, synthesizes progress report
- Visual summary card alongside voice response

### F-06 — Year Plan Overview
- Visual timeline of goals and milestones
- Habit streak calendar view
- Journal timeline
- Dark-mode-first Material 3 with AI voice glow states

### F-07 — Settings
- Clear all data (with confirmation)
- Change coaching persona
- API key management
- Text/voice toggle preference

---

## 5. Technical Architecture

### 5.1 Stack
| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| Platform | Android (minSdk 24, compileSdk 36) |
| AI | `google_generative_ai` — Gemini 2.0 Flash Live API |
| Database | Isar (local, NoSQL-relational) |
| Secure Storage | `flutter_secure_storage` (Android Keystore) |
| State Management | Riverpod + ChangeNotifier |
| Routing | GoRouter |
| Audio | `record` (mic), `just_audio` / native AudioTrack (playback) |
| Permissions | `permission_handler` |

### 5.2 Architecture Pattern
```
lib/
├── main.dart
├── app.dart
├── config/           # Theme, routes, constants
├── models/           # Isar collections (Goal, Milestone, Habit, JournalEntry, UserProfile)
├── providers/        # Riverpod providers (DB, Gemini, Audio)
├── services/
│   ├── isar_service.dart       # DB init, CRUD, queries
│   ├── gemini_service.dart     # Live API streaming, session management
│   ├── audio_service.dart      # Recording, playback, VAD
│   └── secure_storage_service.dart  # API key management
├── screens/
│   ├── onboarding/
│   │   ├── persona_screen.dart
│   │   ├── api_key_screen.dart
│   │   └── permissions_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── voice/
│   │   └── voice_chat_screen.dart    # Primary interaction
│   ├── plan/
│   │   └── year_plan_screen.dart
│   ├── habits/
│   │   └── habits_screen.dart
│   ├── journal/
│   │   └── journal_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── widgets/
    ├── ai_glow_indicator.dart
    ├── goal_card.dart
    ├── milestone_timeline.dart
    └── habit_streak_calendar.dart
```

### 5.3 Data Flow
```
[User Voice] → Audio Record → Gemini Live API (streaming)
                                           ↓
                              Gemini Response (text + voice)
                                           ↓
[UI Update] ← Riverpod Provider ← Gemini Service
      ↓
[Isar DB] ← Stats injected into next prompt context
```

### 5.4 Key Constraints
- **No backend server** — all Gemini calls go directly from device
- **No account system** — API key is optional (demo mode available)
- **No analytics/tracking** — pure privacy
- **compileSdk = 36** (required by modern plugins)
- **Java 17** for Gradle build (system Java 26 incompatible with AGP)

---

## 6. Design System

| Element | Specification |
|---------|--------------|
| Theme | Material 3, dark-mode-first |
| Background | Deep charcoal (#121212) |
| Surface | Elevated dark surfaces (#1E1E1E) |
| Primary Accent | Electric blue (#4A90D9) |
| AI Voice Glow | Animated cyan/teal gradient ring, pulses during active listening |
| Typography | Inter / Roboto, large readable body |
| Animations | 300ms ease-out transitions, subtle glow pulse on voice state |
| Voice States | Idle (dim) → Listening (cyan pulse) → Thinking (amber pulse) → Speaking (green solid) |

---

## 7. Development Phases & Sprint Plan

### Phase 1: Foundation (Days 1-3)
| Task | Agent | Deliverable |
|------|-------|-------------|
| Flutter project scaffold + Isar schema | James Park | Working `flutter run` with DB models |
| Android manifest + permissions | James Park | Mic permission, compileSdk 36 |
| Material 3 dark theme + routing | Maya Rodriguez | Theme system, GoRouter config |
| Project architecture doc | James Park | `docs/ARCHITECTURE.md` |

### Phase 2: Core Data + Onboarding (Days 4-6)
| Task | Agent | Deliverable |
|------|-------|-------------|
| Isar service layer (CRUD, queries) | James Park | All model repositories |
| Onboarding flow (persona + API key) | James Park | 3-screen onboarding |
| Secure storage integration | Rachel Torres | API key encrypted at rest |
| Settings screen skeleton | James Park | Settings with data wipe |

### Phase 3: Gemini Integration (Days 7-10)
| Task | Agent | Deliverable |
|------|-------|-------------|
| Gemini Live API streaming service | Dr. Aisha Patel + James Park | Bidirectional voice session |
| Audio recording + playback | James Park | Mic capture, speaker output |
| Dynamic prompt builder (DB context → Gemini) | Dr. Aisha Patel | Stats injection system |
| Rate limiting + fallback | Dr. Aisha Patel | Graceful degradation on 429/403 |

### Phase 4: Voice UI + Coaching (Days 11-14)
| Task | Agent | Deliverable |
|------|-------|-------------|
| Voice chat screen with glow states | Maya Rodriguez + James Park | Primary interaction UI |
| AI response rendering (text + voice) | James Park | Streaming response display |
| Coaching persona differentiation | Dr. Aisha Patel | Professional vs Student prompts |

### Phase 5: Goals/Habits/Journal UI (Days 15-18)
| Task | Agent | Deliverable |
|------|-------|-------------|
| Year plan overview screen | Maya Rodriguez + James Park | Timeline, milestones, progress |
| Habits screen + streak calendar | James Park | Habit tracking UI |
| Journal screen | James Park | Entry list + composer |
| CRUD for all entities | James Park | Full data management |

### Phase 6: QA + Polish (Days 19-21)
| Task | Agent | Deliverable |
|------|-------|-------------|
| Unit tests (services, models) | Priya Sharma | Test suite >70% coverage |
| Integration tests | Priya Sharma | Voice flow, DB queries |
| UI polish + animations | Maya Rodriguez | Glow effects, transitions |
| Build verification (APK) | David Kim | Debug + Release APK |

### Phase 7: Documentation + Final Sign-off (Days 22-23)
| Task | Agent | Deliverable |
|------|-------|-------------|
| README.md + User Guide | Emma Larsson | Complete documentation |
| Architecture decision records | Emma Larsson | `docs/adr/` |
| Final build + security scan | David Kim + Rachel Torres | Audit report |
| PM final test | Sarah Chen | "Project is all done" |

**Estimated total: ~23 working days**

---

## 8. Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Gemini Live API latency on slow networks | Medium | High | Show "thinking" state; allow text fallback |
| Isar schema migration breaking changes | Medium | Medium | Lock schema early; no migrations in MVP |
| Audio session conflicts (calls, notifications) | Medium | Medium | Proper AudioFocus handling; duck/pause behavior |
| Gemini API rate limits (15 req/min free tier) | Medium | Low | Debounce user requests; local context caching |
| Android 14+ microphone permission restrictions | Low | High | Target API 34; proper runtime permission flow |
| `google_generative_api` package Live API support gaps | Medium | High | Fallback to standard `generateContent` if Live unavailable |
| Dark theme accessibility contrast failures | Low | Medium | WCAG AA compliance audit in Phase 6 |

---

## 9. Success Metrics

| Metric | Target |
|--------|--------|
| Cold start time | < 2 seconds |
| Gemini Voice response latency | < 1.5 seconds (to first audio byte) |
| App size (APK) | < 25 MB |
| Voice-to-text accuracy | > 90% (dependent on Gemini model) |
| DB query latency (local) | < 50ms |
| Memory footprint | < 150MB average |
| Build success rate | 100% (CI green) |

---

## 10. Open Decisions (need client input before execution)

| # | Question | Options |
|---|----------|---------|
| D1 | Sample/demo data on first launch? | A) Pre-seed with realistic year plan B) Empty state with onboarding C) Let user choose |
| D2 | Offline behavior when no API key? | A) Show setup prompt immediately B) Demo mode with mock responses C) Limited local-only coaching |
| D3 | Journal entries linked to goals? | A) Optional link B) Always linked C) Separate, unlinkable |
| D4 | Habit streak reset policy? | A) Auto-reset on miss B) Grace period (1 day) C) User manually resets |
| D5 | APK delivery | A) Direct APK B) App Bundle C) Both |

---

## 11. What This Proposal Does NOT Include

- iOS build (Android-only MVP)
- Push notifications / background sync
- Cloud backup or sync
- User accounts / auth
- In-app purchases / monetization
- Admin panel or dashboard
- Analytics / crash reporting (Firebase, Sentry, etc.)
- Multi-language localization (English only for MVP)

---

## 12. Approval Required

**This plan is ready for your review. Please:**

1. Review all sections above, especially the feature set (Section 4), architecture (Section 5), and timeline (Section 7).
2. Answer the open decisions (Section 10) — or let the agent team decide sensibly.
3. Confirm, revise, or reject this proposal.

**Once approved, development begins immediately following the PM-Led Workflow with cross-document consistency checks.**

---

*Prepared by K K K Ekanayake — Mobile Development Team*
