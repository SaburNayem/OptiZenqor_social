# Chat Platform Feature Roadmap

Updated: 2026-05-13

## Goal

This roadmap tracks the messaging and calling features needed to move the app closer to Facebook Messenger, WhatsApp, and Instagram DM quality.

It is based on:

- Flutter frontend code in this workspace
- local backend code in `../Socity_backend`
- recent live-device logs and API behavior

## Current Summary

The project already has partial support for:

- direct chat threads
- direct message fetch/send
- uploads
- socket contract discovery
- presence snapshots and typing infrastructure in backend source
- group chat routes in backend source
- mute/archive thread routes in backend source
- blocked and muted account routes
- call session bootstrap routes

The project is still incomplete for:

- reliable direct-chat attachment sending in deployed backend
- polished group chat frontend
- end-to-end message request flow
- durable read/delivered/seen sync across all chat surfaces
- real WebRTC audio/video transport
- many advanced messaging features expected from Messenger/WhatsApp/Instagram

## Feature Matrix

| Feature | Backend source status | Frontend status | Overall |
| --- | --- | --- | --- |
| Direct text messaging | present | present | usable |
| Image/audio/video/file message contract | present in local backend source, not trusted in deployed backend yet | partial | blocked by deploy alignment |
| Uploads | present | present | usable |
| Message status `sent/delivered/read` | present in backend source | partial UI | partial |
| Active status / last seen / typing | present in backend source | partial | partial |
| Group chat routes | present in backend source | limited frontend integration | partial |
| Thread mute/archive | present in backend source | not fully surfaced end to end | partial |
| Blocked/muted accounts | present | present in settings flows | partial |
| Message requests | settings/preferences exist, full inbox request flow not verified | partial | partial |
| Realtime new-message sync | socket contract exists | partial | partial |
| Audio call session lifecycle | present | present | partial |
| Real voice/video media transport | not complete end to end | not complete end to end | missing |
| Reply, reactions, forward, edit, delete for messages | not fully verified end to end | not fully implemented end to end | missing/partial |
| Group roles/admin controls | present in backend source | limited | partial |
| Pin chat / star message / search in conversation | mixed | mixed | partial |

## What To Build For “Facebook + WhatsApp + Instagram” Level Messaging

### Phase 1: Core Reliability

- finalize canonical direct-message payload contract
- redeploy backend with the latest chat controller and DTO changes
- verify text, image, audio, video, and file send against the deployed backend
- wire message delivery states consistently in thread list and message bubbles
- make presence, last seen, and typing use one backend contract everywhere

### Phase 2: Group Messaging

- finish group chat list and group detail screens
- create group, rename group, change avatar
- add/remove members
- admin/promote/demote roles
- group mute/archive/leave/delete flows
- group message read state and typing state

### Phase 3: Inbox Behavior

- proper message requests inbox
- accept/ignore/restrict flows
- unread counts and mention counts
- pin/unpin chats
- archive chats
- mute notifications per thread
- search across inbox and inside chat

### Phase 4: Message Actions

- reply to message
- react to message
- copy/delete/unsend
- forward to other chats
- share post/story/reel into chat
- voice notes with playback waveform and duration
- media gallery inside conversation

### Phase 5: Call Quality

- real WebRTC service implementation
- offer/answer/ICE signaling hookup
- join/leave/reconnect handling
- speaker/bluetooth/earpiece control
- call ringing, missed-call, busy, decline states
- group calls if needed

### Phase 6: Privacy and Safety

- block/unblock from chat
- mute/unmute from chat
- read receipt controls
- active status controls
- disappearing messages if desired
- report conversation/user

## Highest Priority Backend Tasks

1. Redeploy the latest backend chat build so production matches source.
2. Publish one canonical request/response example for:
   - `POST /chat/threads/:id/messages`
   - `GET /chat/threads/:id/messages`
   - `GET /chat/presence`
   - `POST /chat/presence`
   - group chat CRUD routes
3. Confirm message-request routes and payloads.
4. Finish RTC signaling and media contract for calls.

## Highest Priority Frontend Tasks

1. Finish direct-chat attachment flow strictly against the deployed backend contract.
2. Surface true message state labels and remove any remaining fake/local fallback behavior.
3. Build full group-chat screens around the existing backend routes.
4. Add message-request inbox and actions.
5. Replace mock/static call behavior with real RTC transport after backend signaling is finalized.

## Honest Expectation

Getting “all Facebook, WhatsApp, and Instagram features” is a large product scope, not one bug fix.

The fastest realistic path is:

1. stabilize direct chat
2. stabilize presence and delivery state
3. finish group chat
4. finish message requests
5. finish real calling
6. add advanced message actions
