# Frontend Backend Action Checklist

Updated: 2026-05-12

## Purpose

This file turns the current frontend and live-backend mismatch review into an actionable checklist for engineering handoff.

Scope of this checklist:

- Flutter frontend code in this workspace
- existing local audit documents
- live backend behavior observed from recent run logs

Out of scope:

- direct verification of backend source code, because the backend repository is not present in this workspace

## Evidence Base

- [documentation.md](./documentation.md)
- [FRONTEND_BACKEND_AUDIT.md](./FRONTEND_BACKEND_AUDIT.md)
- [FRONTEND_BACKEND_MISMATCH_REPORT.md](./FRONTEND_BACKEND_MISMATCH_REPORT.md)
- [lib/core/webrtc/webrtc_service.dart](./lib/core/webrtc/webrtc_service.dart)
- live Flutter/device logs captured on 2026-05-12 during chat, stories, login, onboarding, feed, and socket flows

## Honest Summary

The app is not fully backend-complete yet.

What is clearly backend-backed enough right now:

- auth and login
- onboarding slides and onboarding completion
- feed fetch
- bookmarks fetch
- story fetch
- chat thread fetch
- chat message fetch
- uploads
- call session bootstrap basics
- socket contract discovery

What is still mismatched or incomplete:

- direct chat attachments
- full direct-message lifecycle consistency
- durable presence and last-seen richness
- real WebRTC voice/video transport
- richer marketplace, jobs, support/help, groups, pages, saved collections, and account-switching payload completeness

## Root Cause

The mismatch is a contract gap across three layers:

1. Product guidance allowed static-first, mock-driven screens early.
2. Frontend implemented clickable UX ahead of final backend contract stabilization.
3. Backend currently supports some foundation routes, but not every payload and transport the UI assumes.

This is consistent with the implementation guidance in [documentation.md](./documentation.md), which explicitly describes the project as static-first and mock-driven.

## Action Table

| Feature | Frontend status | Backend status | Evidence | Exact endpoint or file | Fix owner | Needed next |
| --- | --- | --- | --- | --- | --- | --- |
| Direct text chat | Working enough | Working enough | recent device logs show successful thread and message fetch | `GET /chat/threads`, `GET /chat/threads/:id/messages`, `POST /chat/threads/:id/messages` | shared | keep payload contract stable and document canonical message shape |
| Direct chat attachments | UI exists, assumptions still mixed | incomplete or undocumented | live logs rejected attempted attachment fields with `mediaUrl should not exist`, `imageUrl should not exist`, `fileUrl should not exist` | `POST /chat/threads/:id/messages` | backend first, then frontend | publish exact accepted attachment payload contract for `text`, `image`, `audio`, `video`, `file` |
| Uploads for chat/media | Working | Working | recent run logs and prior app behavior confirm uploads succeed | `POST /uploads` | backend | document upload response fields that messaging is expected to consume |
| Chat presence and active state | partially simulated on frontend | limited backend richness visible | current app can display active state, but durable presence semantics are not yet clearly contracted | `GET /chat/presence`, realtime presence events | shared | define presence snapshot fields, last seen fields, and socket update event payloads |
| Chat realtime event naming | partly integrated | available but event naming drift existed | backend socket contract returns `chat.message.created`, `message:new`, `thread.presence.updated`, etc. | `GET /socket/contract`, realtime namespace | frontend | keep event alias handling aligned with backend contract and remove old assumptions gradually |
| Stories fetch | Working | Working enough | live logs show successful `/stories` and `/stories?scope=buddies` fetches | `GET /stories` | shared | keep author/media payloads consistent and trim UI fallback assumptions over time |
| Story creation and story reply follow-through | mixed | mixed | story fetch works, but story-driven chat follow-up still depends on chat contract quality | story routes plus chat thread creation | shared | validate story reply to chat end-to-end with durable server-created conversation payloads |
| Marketplace payload richness | partial | partial | already flagged in existing mismatch report | marketplace repositories and related endpoints | shared | expand payload completeness and remove frontend derivation |
| Jobs payload completeness | partial | partial | existing mismatch report calls out placeholder labels | jobs models and repository paths | shared | finish backend payload coverage, then remove placeholder labels in models |
| Support/help detail depth | thin but present | thin but present | existing audit calls out richer ticket detail and reply flow as remaining work | support/help repositories and endpoints | shared | add ticket detail, replies, update lifecycle, and stronger UI states |
| Groups, pages, saved collections, account switching | mixed | mixed | existing audit calls these out as still needing normalized contract cleanup | multiple repositories and endpoints | shared | complete normalized `data` payload audit feature by feature |
| Calls lifecycle UI | partial | partial | existing mismatch report already flags calls lifecycle as incomplete | calls repositories and server call routes | shared | define durable lifecycle snapshots, participants, and state transitions |
| Real WebRTC audio/video transport | not implemented | not implemented from frontend perspective | `WebRtcService` throws `UnimplementedError` | [lib/core/webrtc/webrtc_service.dart](./lib/core/webrtc/webrtc_service.dart) | backend and frontend | define signaling contract, ICE exchange, RTC session lifecycle, then implement the shared transport layer |

## High Priority Gaps

### 1. Direct chat attachment contract

Observed backend validation failures:

- `mediaUrl should not exist`
- `imageUrl should not exist`
- `fileUrl should not exist`
- `kind must be one of: text, image, video, audio, file`

What this means:

- uploads can succeed
- message creation can succeed for text
- the bridge between uploaded asset and message payload is missing, incomplete, or undocumented

Backend action needed:

- publish canonical request and response examples for `POST /chat/threads/:id/messages`
- include accepted fields for each message kind
- clarify whether uploaded media should be referenced by URL, upload id, media object, or attachment array

Frontend action needed after backend contract is confirmed:

- remove rejected fields
- send only canonical fields
- update attachment composer to match exact server shape
- update message parsing for attachment metadata

### 2. RTC signaling and media transport

Current proof of incompleteness:

- [lib/core/webrtc/webrtc_service.dart](./lib/core/webrtc/webrtc_service.dart) throws `UnimplementedError`

What this means:

- call screens and some call APIs can exist
- true audio/video transport is still not complete

Backend action needed:

- define signaling endpoints and/or socket events
- define session creation, join, leave, offer, answer, ICE candidate, and end-call payloads
- define authorization and participant model

Frontend action needed after contract exists:

- implement the shared WebRTC transport service
- connect call screens to real RTC lifecycle
- handle reconnect, denied permissions, and participant state updates

### 3. Presence and last-seen consistency

Current status:

- frontend can show active indicators
- backend routes and socket presence events exist
- durable semantics for online, offline, last seen, typing, and thread presence are not yet fully obvious from the current app contract

Needed next:

- define exact shape of presence snapshot and updates
- ensure thread list, chat detail header, and typing indicators all consume the same source of truth

## Owner Split

### Backend-first tasks

- document canonical direct-message payload contract
- document canonical attachment payload contract
- define RTC signaling contract
- define durable presence contract
- enrich marketplace, jobs, and support/help payloads where frontend is still deriving display values

### Frontend-first tasks

- remove remaining placeholder assumptions after backend payloads are finalized
- tighten repository parsing to canonical `data` contracts across remaining feature slices
- stop sending non-canonical attachment fields once backend contract is confirmed
- connect call screens to real WebRTC implementation once signaling is available

### Shared tasks

- align socket event names and payload shapes
- write one source-of-truth contract examples for chat, calls, stories, support/help, marketplace, and jobs
- run end-to-end verification on real device for chat text, chat attachments, stories, and calls

## Recommended Next Sequence

1. Confirm and document `POST /chat/threads/:id/messages` request and response contract.
2. Confirm and document RTC signaling and media contract for calls.
3. Re-run frontend chat attachment implementation strictly against that contract.
4. Complete normalized contract audit on remaining repositories called out in existing mismatch docs.
5. Trim remaining display-level placeholders after payload completeness is verified.

## Notes

- This checklist is intentionally conservative. If a feature is not directly verified from backend source in this workspace, it is treated as partial unless the live logs clearly prove otherwise.
- Existing audit files should remain the source for prior cleanup work, while this file is the practical next-step tracker.
