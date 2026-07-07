# THE 21
### The Integrated Man's onboarding journey · FINAL SCRIPTS v1 · July 2026

**What it is:** every man's first 21 days. A daily pump-up from Leo (90 seconds to 8 minutes), one clear action, marked done where his brothers see it. It teaches WHO to become (the vision), WHAT to do (the Integrated OS), and hands him the tool that keeps it going (the app). Surrender is the engine: you as the vessel, God as the power.

**Locked decisions (Leo, July 6 2026):**
- Morning execution order: **Silence → Undivided time with God → Scripture → Journal → Exercise.** J.E.S.U.S. is the memory device for the pieces; this is the order you run them.
- Minimum viable morning: **5m silence · 10m undivided · 10m scripture · 5m journal · 30m exercise = 1 hour.** Installed by waking one hour earlier, backed up 15 minutes at a time across Week 2. "It changed my life."
- Day 3 visualization: **Leo runs it himself** (record it once; it becomes the Day 3 audio). Script below only frames and lands it.
- J.E.S.U.S. morning mode + PRAISE nightly mode = **in-app guided installs** (widget-like, done-for-today until tomorrow). **Unlocked ONLY by taking The 21.** The program is the key to the OS.
- Affirmations: **both** — who God says he is (Scripture) + his own words. Taught on Day 18.
- Time blocking: **Google Calendar.**
- **Monday start.** Debriefs land on Sundays (Days 7, 14, 21).

---

## LEO'S CURRICULUM (source of truth, from his notes)

1. **Awareness** of where he's at (Pillars, honest).
2. **Vision**: the visualization. The man you want to be (character), the life you want to steward (pillars), the lifestyle. Then write it all down clearly.
3. **Remove thieves**: porn, mindless scrolling, laziness, snoozing, complaining.
4. **The Surrender / Handoff**: the life and character we want is impossible without Him. "Why would He bless your kingdom? But imagine if you build His."
5. **The Integrated OS**: the J.E.S.U.S. Morning Routine (Journal, Exercise, Silence, Undivided time, Scripture) · the PRAISE Nightly Routine (Pray, Review, Affirmation, Inventory, Scripture, Entrust) · habits (routine, waking on time, nightly) · Mind Renewal (Rom 12:2: catch the negativity, replace with truth, repeat the truth, live the truth).
6. **Time Blocking**: protect the hours that build the vision.
7. **Pillar-specific action**: what WOULD that version of you do, what DOES he do? Research. Then DO.
8. **Night**: reflection, reading, prayer, get ready.

## BUILD STATE — WHAT IS ALREADY SHIPPED ON DEV (v61.63-dev, July 6 2026)

**The engine is BUILT and live on the dev site. Code lives in index.html (all functions prefixed `t21`,
styles `.f21-`); the authoritative code documentation is CLAUDE.md → "The Forge + The 21" section.
This file remains the CONTENT source of truth: the scripts below generate `the21.json` via the
build script (session scratchpad `build_the21.py`). Edit scripts here → regenerate → commit both.**

Shipped: Forge nav tab (flame + ready-dot badge) · The 21 full flow (Welcome → Day 1 immediate →
first-light locks, program waits on misses, one day per calendar day) · the 21-dot path with
milestone dots + week-gate interstitials (AWAKE→BUILD→BECOME) · in-session widgets for every
in-app-able action (Day 1/21 pillar scorer with per-pillar explainer lines, Day 21 BLANK-start +
sealed Day 1→today delta + share invite; journals/reviews saving to Notes; Day 4 letter vault +
examples; Day 6 wake-time picker + 3-step setup; Day 10 reading-plan status; Day 13 lies/truths;
Day 17 pick-a-move (3 options per weakest pillar); Day 18 affirmation bank + one-tap "No
complaining" habit) · draft autosave for everything typed (survives back arrow, per-day keys,
cleared on complete) · J.E.S.U.S. Morning + P.R.A.I.S.E. Night runnable guided flows (unlock Days
12/15; Silence countdown timer 1–10 min ending in the deep chime; sample prayers on Pray/Entrust;
preview mode from Days 12/15 that never consumes the real run) · THE FALL as three course-correction
protocols (tempted-now / fell / missed-morning) behind a quiet link · Home "Day N is ready" card ·
strike celebration (flash + embers + chime + haptic) · audio player (1x/1.25x/1.5x) that appears the
moment a day's `audio` URL is set · dev time machine · data safety (grow-only merge, quote-safe
escaping, uid-tagged, letter/lies/affirms/drafts protected).

**Not yet built:** Leo's audio (recordings pending → upload to Supabase Storage → set `audio` URLs
in the json build), circle-board auto-events ("began The 21" / "Day N ✓"), read-along from Leo's
Voice Memos transcripts, prod ship (needs disaster drills + Leo's explicit go).

## BUILD NOTES FOR THE ENGINE (original design notes — see BUILD STATE above for what's real)

- **J.E.S.U.S. morning mode**: guided 5-step flow in execution order (Silence timer → Undivided/prayer → Scripture/reading → Journal → Exercise check). Installs progressively Days 8 to 12. Widget-like card that completes for the day and returns at first light.
- **PRAISE nightly mode**: guided tap-through (Pray → Review today → Affirmations spoken → Inventory heart-check prompt → Scripture → Entrust tomorrow, one line). Installs Day 15.
- **Unlock mechanic**: both modes are locked app features. Taking The 21 unlocks them progressively; completing The 21 keeps them forever. This is the incentive to take the program.
- **Mind renewal card** (Day 13): his top 3 lies + the truth that answers each. Surfaced in PRAISE (Affirmation step) and by the Fall button.
- **Affirmation bank** (Day 18): his own lines from the vision letter + Scripture identity verses.
- **Vault**: Day 4 vision letter, sealed until Day 21.
- **The Fall button**: live from Day 2. Emergency audio, no shame protocol. After ANY missed day, grace speaks first next morning (notification + short audio).
- **Wake-time backup**: Days 8, 9, 10, 12 each move the alarm 15 minutes earlier (total: one hour). App tracks declared wake time.
- **Time blocking**: Google Calendar (external). No in-app calendar.
- **Day 21**: Second Mirror, delta view, letter opened, completion artifact, invite-one-man flow, soft pointer to Growth Plans (future).
- Monday start; sessions breathe (90 sec to 8 min); every verse read plainly with one line of context; no Christianese; `[YOUR STORY]` = Leo's testimony slots.

---

## ENGINE DECISIONS (LOCKED · pre-build audit, July 6 2026)

1. **The opt-in IS Day 0 (the Welcome), and Day 1 opens immediately (Leo's call).** A man taps "Start The 21" whenever → the ~2 min Welcome plays right then → Day 1 is available on the spot (strike while he's hot; the Mirror works at any hour). Each NEXT day unlocks at first light after completing the prior one, so the morning rhythm takes over from Day 2 on. A man can also choose to wait: "Day 1 will be waiting at first light."
2. **The program WAITS on a missed day.** Day N stays open until completed; no content is ever skipped. The streak/board shows the miss honestly and grace speaks first on return. Max ONE day per calendar day: no binge catch-up; the next day always unlocks at first light.
3. **Rolling starts.** Engine is per-man (startDate); cohort 1 starts together on a Monday, but any future man can begin any day. Scripts say "week," never weekday names.
4. **The Mirror is snapshotted, read-only.** Day 1's action IS the normal home-screen pillar scoring; the engine just copies those scores as mirror0 (Day 21 → mirror21). Snapshots read from his ratings and never write to them: the home screen behaves identically during the program.
5. **Read mode until audio exists.** Any day without a recording runs with the script text as the session. The whole engine is buildable and testable before Leo records past Day 1.
6. **Multi-part days** (7 morning+evening, 21 part1+Mirror+part2) supported by the content format.
7. **No manual "UP" posts (whacked by Leo).** The circle board announces automatically: "began The 21," "Day 9 ✓." The witness is built in; nobody performs anything. Circle-less men simply have no board events; nothing breaks.
8. **The Fall button** lives on The 21 screen (later also inside PRAISE). Its audio ships in recording batch 2.
9. **The Forge enters the bottom nav NOW (the flame tab), with The 21 inside it** (Leo's call: men should get used to growth living in the Forge from day one). The Forge screen = The 21 as centerpiece + a grayed "more forging ahead" teaser row.
10. **Data safety:** completions are grow-only union-merge, uid-tagged; the letter gets journal-grade sacred protection; disaster drills (two devices, fresh device mid-program, offline completion, midnight straddle) must pass before any prod ship; dev time machine included from day one.
11. **Re-runs: out of scope v1.** Completing The 21 is a terminal state (the repeat engine arrives with The Forty).
12. **J.E.S.U.S./PRAISE unlock only via The 21** (locked teaser card for everyone else).

---

### DAY 0 · THE WELCOME
*Plays immediately when he taps "Start The 21" · ~2 min · recording #26*

**AUDIO:**

You just did something most men never do. You didn't scroll past.

Here's what you just signed up for, straight: 21 mornings. A few minutes with me, one clear thing to do, every single day. Some days will feel easy. A few will put a knot in your stomach. All of them are buildable into the man you've been wanting to be, the one God's been waiting to build.

`[YOUR STORY: 30 seconds. What was at stake when you started your own 21 days of building the rhythm. Why it mattered.]`

One rule in here. One. Don't fake anything. Don't check a box you didn't do. Don't write a nice answer when the true one is ugly. Every man who's ever been changed by anything got changed by the truth, so in here we tell it.

One thing before you sleep tonight: get to bed like a man with an appointment, because you have one.

Day 1 is called The Mirror, and it takes about ten minutes. It's already open. If you're ready, take it right now. If not, it'll be waiting for you at first light, and morning is where this program lives.

Either way: the man who shows up tomorrow morning is already different from the man who almost didn't.

**ACTION:** Take Day 1 now, or sleep and let it meet you at first light.

---

# THE SCRIPTS

## WEEK 1 · AWAKE

---

### DAY 1 · THE MIRROR
*Charge · ~3 min · onboards: 7 Pillars*

Welcome to The 21. I'm Leo. For the next 21 days I'm with you every morning. A few minutes together, then one thing to do. That's the deal.

Here's why you're here. There's a version of you that God had in mind when He made you. Strong. Clear. Steady. The man your family gets to lean on. And there's the version of you that showed up today. The 21 is about closing that gap. Not all of it. But enough that you'll never be able to un-feel the difference.

`[YOUR STORY: 60 seconds. Where you were before this rhythm existed. One specific scene.]`

Nothing changes until you can see clearly. Not where you want to be. Where you ARE. Most men never do this. They keep the lights dim on purpose, because the dark is comfortable and the truth has edges. Today you turn the lights on.

In the app there are seven areas of your life. Faith. Body. Mind. Your people. Your work. Your money. Your space. Score yourself in all seven, one to ten. One rule, and it's the rule for all 21 days: don't fake anything. A fake ten is worth less than an honest three. The honest three can grow.

That number at the end is your starting line. Not your sentence. You'll score again on Day 21, and the numbers will tell you a story I won't have to sell you on.

Go look in the mirror. It's right here on this page: score all seven, right now. See you tomorrow.

**ACTION:** Score all 7 pillars honestly, right here. One sentence in the journal: the truest thing the numbers said about you.

---

### DAY 2 · THE THIEVES
*Charge · ~3 min · onboards: Journal, the Fall button*

Yesterday you looked in the mirror. Today we name what's been robbing you.

Every man has thieves. The snooze button that steals your mornings. The scroll that steals your evenings an hour at a time and hands you nothing back. Laziness, which never announces itself, it just whispers "later." Complaining, the sneakiest one, because it feels like talking but it's actually agreeing with defeat. And for a lot of us, porn. Stealing more than we want to admit.

`[YOUR STORY: 45 seconds. Your thief. What it took from you. When you realized it.]`

Here's what I need you to get: the thief isn't the real problem. The thief is a painkiller. You reach for it because something hurts or something's empty. We'll deal with that this week. But first you name them, because a thief you won't name is a thief you can't catch.

Today, write the list. Every thief. Real names, not soft ones. "I waste a little time on my phone" is soft. "The scroll takes ninety minutes a night and I hate myself after" is a name. Then circle the big one. The one that, if it lost, everything else gets easier.

Two more things. Tonight your phone sleeps outside your bedroom. Starting tonight, not negotiable. And from today there's a button in this app called the Fall. If a thief gets you at 1am some night during these 21 days, press it, and I'll be there. No shame in this program. Shame is the thief's best friend, and we're starving them both.

Write the list. Circle the one. Phone out of the room.

**ACTION:** Write your thieves list right here on this page (it saves into your journal). Name the big one. Phone sleeps outside the bedroom from tonight on.

---

### DAY 3 · THE VISUALIZATION
*Descent · Leo runs the visualization live (recorded once, becomes this day's audio) · onboards: nothing new, just him and the picture*

**INTRO (script, ~60 seconds, then Leo's visualization):**

Today is different. No list, no habit, no fixing anything. Today you get to see something.

Most men are running hard with no destination. That's not discipline, that's a hamster wheel. Before we build anything, you need to see the man you're building toward. Not a fantasy. The actual man God had in mind when He made you, and the life he's stewarding.

Find somewhere you won't be interrupted for fifteen minutes. Sit down. When you're ready, close your eyes and follow my voice.

`[LEO RUNS HIS VISUALIZATION HERE: the man he is (character), the life he stewards (the seven pillars), the lifestyle he lives.]`

**LANDING (script, ~45 seconds):**

Open your eyes. Don't lose him.

Right now, before the world gets back in, open the journal and dump everything you saw. Bullet points, fragments, doesn't matter. How he carries himself. His mornings. His marriage, his kids, his work, his money, his body, his walk with God. Get the pictures on paper before they fade.

Tomorrow, we turn those pictures into something you'll carry for the rest of your life. See you then.

**ACTION:** 15 min visualization, then raw-dump everything into the journal while it's hot.

---

### DAY 4 · WRITE IT DOWN
*Descent · ~4 min · onboards: the vault (sealed letter)*

Yesterday you saw him. Today you write him down, because a vision that stays in your head is a daydream. A vision written clearly is a target.

There's a verse this whole app is built on. Romans 12:2. Paul says: don't be conformed to this world, be TRANSFORMED, by the renewing of your mind. Read that again slowly. Transformation doesn't start with your habits. It starts with what you can see. A man can't become what he can't picture. You pictured him yesterday. Today you make it permanent.

`[YOUR STORY: 45 seconds. The moment you first wrote your vision down, and what changed once it existed on paper.]`

In the app there's a letter waiting for you. It seals when you finish, and it stays sealed until Day 21. Nobody sees it but you, and you won't see it again until the last day.

Write the man. His character: how he talks, what he refuses, what people feel when he walks in. Write the life he stewards, all seven pillars: his faith, his body, his mind, his people, his work, his money, his space. Write the lifestyle: what a normal Tuesday looks like when it's him living it.

Write in the present tense, like he already exists, because in God's mind, he already does. "He gets up when the alarm sounds. He opens the Word before the world gets to him. His kids know his eyes, not the top of his head."

Pull up yesterday's notes and write for fifteen minutes. Don't edit. Don't be realistic. Realistic is just fear wearing glasses. And if you stall, there are a few example lines on this page to prime the pump. Borrow the shape, not the words.

On Day 21 you're going to read this letter, and something in your chest is going to move. Write it like you mean it.

**ACTION:** Write the vision letter, present tense, all of it clearly. It seals until Day 21.

---

### DAY 5 · THE HANDOVER
*Descent · ~5 min · onboards: Prayer · THE SURRENDER DAY*

Today is the most important day of the 21. It doesn't look like it. There's nothing to check off that'll impress anybody. But everything else rests on today.

You've got the letter now. The man, the life, the lifestyle. So let me ask you the hard question: what makes you think you can build him?

Be honest. How many times have you tried to become that guy? White knuckles. New Year's. Deleting the app and re-downloading it two weeks later. How'd it go?

Same way it went for me.

`[YOUR STORY: 90 seconds. The day you stopped building your own kingdom. What surrender actually looked like, in a real room, on a real day. This is the heart of the program. Take your time on this one.]`

Here's the truth nobody told me. That man in your letter? You can't build him. Not because you're weak. Because you were never the power source. You've been trying to be the engine, and you were only ever built to be the vessel. The power was never supposed to come from you. It was supposed to come THROUGH you.

And here's the question that flipped everything for me: why would God bless YOUR kingdom? Your empire, your ego, your plans with your name on them. Why would He pour His power into that? But imagine, just imagine, if you started building HIS. Jesus said it plainly: seek first His kingdom, and all these things get added to you. All these things. The letter you wrote yesterday is full of "all these things."

So here's today. Five minutes. Somewhere quiet, phone in another room. Open your hands, palms up on your knees. It'll feel strange. Do it anyway. And say one sentence out loud, your own words: "I can't build him on my own. It's Yours now. I'm the vessel, You're the power. Your kingdom, not mine."

The men who skip today have a hard week two. The men who mean it today are different by Day 21, and they know exactly why.

**ACTION:** 5 minutes, quiet, open hands, the handover sentence out loud. Log the prayer in the app in your own words.

---

### DAY 6 · THE BLUEPRINT
*Charge · ~3 min · onboards: Keystone Habits setup*

Vision's written. Kingdom's handed over. Now we lay the first stone, and it's smaller than you think.

You don't become the man in that letter through one heroic month. You become him through a morning. Next week I'm going to give you the exact morning routine that changed my life, piece by piece. But a routine can't live in chaos, so today we pour the foundation.

Three things.

First: declare your wake time. Whatever time you're supposed to get up now, that's the number, and starting tomorrow it's FIRM. No snooze, ever again. The snooze button is you breaking your word to yourself before your feet even touch the floor, and a man who breaks his word to himself all morning will break it to everyone else all day.

Second: tonight the alarm goes ACROSS the room. Not the nightstand. Across the room, volume up.

Third: your habits. If you've already got some set on your Home page, they're showing right here on this page. Look at them honestly: keep the ones that serve the man in your letter, swap the ones that don't. If you've got none yet, set these, and keep them small: two minutes in the Word before you touch anything else on that phone. Five minutes of movement, pushups on the bedroom floor counts. And name the ONE most important thing you'll do with your day. Small on purpose. Next week we build the real thing on top of this.

Declare the wake time to your circle. Out loud, on the board, where they can see it. Tomorrow morning is your first rep. First blood.

Set it up. Then get to bed on time. That's not a suggestion, that's the assignment.

**ACTION:** Declare wake time to the circle. Alarm across the room. Set the 3 starter habits in the app. In bed on time.

---

### DAY 7 · THE FIRST MORNING + WEEKLY REVIEW #1
*Field morning + Debrief evening · morning audio ~90 sec, evening ~3 min · onboards: check-off, streak, board, weekly review*

**MORNING (90 seconds, plays at wake):**

This one's short. No lesson this morning, just your first rep.

The alarm's going to sound, and in that first second and a half you'll hear the negotiation start. That voice offering deals. Five more minutes. Start Monday. Nobody would know.

You can't out-argue that voice. You out-MOVE it. Feet on the floor before the negotiation gets going. Ninety seconds of no mercy. Feet. Floor. Stand. Done. You just won the first fight of the day, and every fight after gets easier.

Then run your three and check them off as you go. Your brothers' boards show who's already moving this morning, and yours is about to say the same about you. Go.

**EVENING (Weekly Review #1, ~3 min):**

Week one. Done. Look at what you're standing on: an honest score, a named list of thieves, a vision letter sealed in the vault, open hands, and a morning already won. Seven days ago none of that existed.

Tonight is your first weekly review. Every week for the rest of your life, if you'll take it, one evening is for looking back before you push forward. Look at your week, what got checked, what got skipped. No spin. Then answer the three questions right here on this page, one sentence each: Where did I show up? Where did I drift? What does next week need from me? Your answers save into your journal, and months from now you'll read them back like mile markers.

One more thing, and it matters. Somewhere in the next 14 days you'll probably miss a day. Life will swing at you, or a thief will catch you at a weak moment. Hear me: a missed day is not a broken program. This thing runs on grace, the same grace you opened your hands to on Day 5. When you fall, the plan isn't shame. The plan is: get up, press the button if you need me, take the next morning. The deal was never perfection. The deal was direction.

Rest tonight. Real rest. Because tomorrow, week two begins, and I'm handing you the exact morning that changed my life. We're going to steal a whole hour back from your sleep, fifteen minutes at a time, and I promise you it'll be the best trade you've ever made.

See you at first light.

**ACTION:** Morning: feet on the floor at the alarm, run your three habits. Evening: first weekly review, three journal sentences, sleep.

---

## WEEK 2 · BUILD (The Integrated OS)

---

### DAY 8 · THE J.E.S.U.S. MORNING ROUTINE · SILENCE
*Charge · ~4 min · installs: Silence (5 min) · alarm backs up 15 minutes*

Week two. This is where I hand you the machine.

For years my mornings belonged to everybody but God and me. The phone, the news, the noise, other people's emergencies before my eyes were even open. Then I built one hour, five pieces, and it changed my life. Not improved it. Changed it.

`[YOUR STORY: 60 seconds. The hour that changed your life. What your mornings were before, and what happened when this routine took hold.]`

Here's the frame so you never forget the pieces. The routine spells J.E.S.U.S.: Journal, Exercise, Silence, Undivided time with God, Scripture. Five pieces, easy to remember. But you don't RUN it in that order. You run it the way it actually works: Silence first. Then undivided time with God. Then Scripture. Then journal. Then exercise. This week we install one piece a day, and by Friday you're running the full hour.

Today: Silence. Five minutes. Before the phone, before the noise, before the world gets let in. Sit still and let your mind settle, or chew slowly on one line of Scripture. That's it. No production. Five minutes of quiet before a single input hits you.

Why silence first? Because the first voice you hear in the morning sets the terms for the day. Most men hand that slot to their notifications. You're about to take it back.

Tonight, back the alarm up fifteen minutes. That's the first installment of your hour. Small trade: fifteen minutes of sleep for the quietest, strongest start you've had in years.

Alarm minus fifteen. Silence, five minutes, first thing. Then your starters. Go.

**ACTION:** Alarm 15 min earlier. Tomorrow: 5 minutes of silence before any input, then the starter habits.

---

### DAY 9 · THE J.E.S.U.S. MORNING ROUTINE · UNDIVIDED
*Charge · ~3 min · installs: Undivided time with God (10 min) · alarm backs up another 15*

Piece two. And this one's the center of the whole machine.

Undivided time with God. Ten minutes, just you and Him. Not reading yet, not journaling yet. Talking. Listening. Being with.

Think about how Jesus did mornings. Mark writes that he got up while it was still dark and went out to a solitary place to pray. The Son of God, who had more power in His pinky than we'll ever carry, still needed the quiet dark alone with the Father before He faced people. That wasn't ritual. That was the source.

Undivided means undivided. No phone in your hand. No music. No multitasking prayers while you make coffee. Ten minutes where God gets what nobody else in your life gets: all of you at once.

You don't need fancy words. Talk to Him like a son, because that's the position. Thank Him for three things you can see from where you're sitting. Put the day in front of Him. Ask Him what He wants you to know. And then, and this is the part most men skip, be quiet for a minute and listen.

Tonight, alarm back another fifteen. You're at thirty minutes reclaimed. Tomorrow morning: silence, five. Then Him, ten. Undivided.

The vessel connects to the power source every morning, or the vessel runs dry. That simple.

**ACTION:** Alarm another 15 earlier. Morning: Silence (5), then Undivided time with God (10).

---

### DAY 10 · THE J.E.S.U.S. MORNING ROUTINE · SCRIPTURE
*Charge · ~3 min · installs: Scripture (10 min) · alarm backs up another 15*

Piece three: the Word. Ten minutes, and the placement matters: BEFORE the world gets to talk to you.

Here's the question that rearranged my mornings: who gets to tell you who you are today? Somebody will. If the phone goes first, it's the algorithm, the news, your boss, the comment section. Every input is a voice making a claim on you. Scripture first means the deepest voice goes first, and everything else that day has to argue with what God already said.

Here's how you run it. The app has reading plans, and this page will show you yours. If you've already picked one, good, that's your daily bread: go read today's portion. If you haven't, pick one right now, it takes thirty seconds, and it'll be waiting on your Home page every morning after this. And listen, if you love your physical Bible, use it. Paper counts. The app just keeps your place.

Ten minutes. Don't rush to finish chapters, that's not the goal. Read until something catches, and when it catches, stop and chew. One verse that actually lands beats three chapters skimmed.

And if you're new to the Bible and don't know where to start, here's my answer: a Proverb a day, there are 31 of them, pure wisdom for men. Or the Gospel of John: the life and the good news of Jesus, told by a man who watched it happen. Either one will feed you for weeks.

One more thing, because the S in J.E.S.U.S. is Scripture OR reading. Some mornings, after the Word, you'll have time to read something else: make it something aligned with your values that grows you. A book on your weakest pillar. Something an older man you respect would hand you. The rule is simple: if it doesn't build the man in your letter, it doesn't get your morning.

And when something lands, hold onto it, because tomorrow I'm giving you the piece that keeps it.

Tonight: alarm back another fifteen. You're forty-five minutes in, and tomorrow morning looks like this: quiet, five. God, ten. Word, ten. Twenty-five minutes that most men never get in a week, and you'll have them before sunrise.

**ACTION:** Alarm another 15 earlier. Morning: Silence (5), Undivided (10), Scripture (10).

---

### DAY 11 · THE J.E.S.U.S. MORNING ROUTINE · JOURNAL
*Charge · ~3 min · installs: Journal (5 min) · no alarm change*

Piece four, and good news: this one's free. No alarm change tonight. The five minutes are already sitting inside the hour we've been building.

Journal. Right after the Word, five minutes, write what He's teaching you.

Here's the line I want you to remember: Jesus didn't necessarily write things down, but His disciples did. That's the whole Bible you read this morning, by the way. Men who walked with Him and WROTE IT DOWN. You're a disciple. Act like one. When God teaches you something at 6am and you don't write it, by lunch it's gone, and by Friday you can't even remember that it happened.

This isn't "dear diary." This is a man keeping records of what God is doing in his life. The page you're on gives you the space right now, with prompts if you need them: What did the reading say to ME today? What is He teaching me in this season? What am I not going to forget? And if the reading hasn't found its groove yet, remember: a Proverb a day, or the Gospel of John. Simple beats impressive.

Some mornings you'll write two lines. Some mornings the pen won't stop. Both count. Here's how the habit builds: same slot every morning, right after the Word, two-line minimum, zero pressure to be deep. Depth shows up on its own around week three.

And here's the payoff, because this habit pays like compound interest. On Day 21 you'll read back what you wrote today. In six months you'll read a man you barely recognize. In five years your journal is evidence: proof God was speaking, proof you were listening, proof of how far He's brought you. Your own book of remembrance. Almost nobody has one. You will.

Tomorrow, the final piece, and it's the biggest block of the hour. Bring your shoes.

**ACTION:** Morning: Silence (5), Undivided (10), Scripture (10), Journal (5): write what He's teaching you.

---

### DAY 12 · THE J.E.S.U.S. MORNING ROUTINE · EXERCISE
*Charge · ~3 min · installs: Exercise (30 min) · final alarm backup: the full hour*

Last piece. Exercise. Thirty minutes of moving your body.

Now, before you do the math and get confused: yes, the workout is thirty minutes, but tonight the alarm only moves fifteen. Here's why. You've been banking the hour in pieces: fifteen minutes on Day 8, fifteen on Day 9, fifteen on Day 10. Tonight's fifteen is the last deposit. Four moves of fifteen: the full sixty minutes, claimed. Silence five, God ten, Word ten, journal five, body thirty. That's the hour, and it's yours now. The man from two weeks ago wouldn't recognize you.

Move your body. Thirty minutes. Gym if you've got one, but the floor of your bedroom works fine: pushups, squats, a run around the block, whatever gets you breathing hard. The standard is sweat, not aesthetics.

Why is this in a morning routine with prayer and Scripture? Because your body isn't separate from your walk with God. Paul calls it a temple of the Holy Spirit. It's the vessel we talked about on Day 5, the actual physical vessel the power works through. A drained, soft, neglected vessel serves nobody. And practically? Discipline is a muscle that doesn't know the difference. The man who conquers his body at 6am finds that his mind and his appetites start falling in line too. Win the body, and the body votes for you the rest of the day.

So here it is, the full machine, the J.E.S.U.S. morning in running order: Silence, five. Undivided time with God, ten. Scripture, ten. Journal, five. Exercise, thirty. One hour. The app walks you through every piece from here on out, every morning, in order.

Tomorrow you run the complete hour for the first time. Then I'm going to show you what to do with the enemy that lives between your ears. See you at first light. Full hour.

**ACTION:** Move the alarm 15 minutes earlier one last time (with the three earlier moves, that's the full hour). Tomorrow: run the complete J.E.S.U.S. morning, all five pieces. The app now has the routine built in and will walk you through it, step by step, every morning from here on.

---

### DAY 13 · THE RENEWAL
*Charge · ~5 min · installs: the mind renewal card (top 3 lies + truths)*

You ran the full hour this morning. Feel that. Two weeks ago that hour didn't exist, and now it's yours. But there's a battle the routine alone can't win, and it's the one between your ears.

Let me walk you down a chain. Where do your thoughts come from? Wherever you've been feeding. The feeds, the failures, the words somebody spoke over you years ago. And what do thoughts do? They drive decisions. You don't decide anything without a thought behind it. And decisions, stacked up, become your life. So follow the chain backwards: your life is built from your decisions, your decisions are built from your thoughts, and your thoughts are built from whatever's been allowed to speak. That's why two men can have the same job, same gym, same church, and completely different lives. Different thoughts, different chains.

Romans 12:2. Be transformed by the renewing of your mind. Not the improving of your behavior. The RENEWING of your MIND. God put the leverage point in your head.

`[YOUR STORY: 60 seconds. A lie you used to believe about yourself, how it ran your decisions, and the truth that broke it.]`

So here's the protocol. Four moves. CATCH it: the moment a thought shows up telling you you're a failure, you're behind, you'll never change, catch it like a stranger walking into your house, because that's what it is. REPLACE it: answer it with truth, out loud if you have to. Not positive thinking. Truth. What God actually says. REPEAT it: once isn't renewal. The lie got strong through reps, the truth gets strong the same way. LIVE it: act like the truth is true, because your body believes what you do faster than what you think.

Today's action, right here on this page: write down the three lies that run your head the most. The three sentences on repeat. Then, next to each one, write the truth that answers it. You'll see a few of mine on the page as examples, borrow the shape until you find your own words. If you don't know the truth that answers yours, here's a starter: you're a son of the King, bought at full price, given a spirit of power, love, and a sound mind. That's 2 Timothy 1:7 and it's not a suggestion, it's an inventory list.

Those three truths are about to become weapons. You'll speak them every night starting the day after tomorrow. Catch. Replace. Repeat. Live.

**ACTION:** Write your top 3 lies + the truth that answers each into the app. Run the full morning tomorrow.

---

### DAY 14 · WEEKLY REVIEW #2
*Debrief · ~3 min*

Two weeks down. Look at the board and look at your week: the full hour is installed, the machine is running, and your mind has its first weapons.

I'll tell you what I see from here. Week one you were a man taking inventory. Week two you became a man in training. There's a difference, and everybody around you can feel it even if they haven't said anything yet.

Tonight, Weekly Review number two, right here on this page. What got checked, what got skipped, no spin. Three sentences, they save into your journal: Where did I show up? Where did I drift? What does next week need from me?

And let's be honest about the fight-back, because this week was the week your old life noticed you were leaving. Maybe the snooze voice got louder. Maybe a thief caught you on a tired night. If one did, and you pressed the button and got back up, that's not a scar, that's training. And if one got you and you told nobody, tell your circle tonight. Secrets are where thieves grow. Light is where they die.

Next week is the last week, and it's my favorite. The mornings are yours now. Week three is about the nights, your time, your tongue, and then, at the end, two things are waiting: a mirror, and a letter you wrote to yourself seventeen days ago.

Rest tonight. Real rest. The kind you don't have to earn.

**ACTION:** Weekly review, three sentences, honest word to the circle if a thief scored this week. Sleep.

---

## WEEK 3 · BECOME

---

### DAY 15 · THE P.R.A.I.S.E. NIGHT
*Charge · ~4 min · installs: PRAISE nightly mode (guided flow)*

Your mornings are handled. Tonight we take the other end of the day, because how a man ends his day decides how the next one starts.

Right now, if you're like most men, your day just sort of... trails off. Some scrolling, some TV, fall asleep mid-something. The day never actually ends, it just runs out of battery. Tonight that changes. I'm giving you the nightly routine, and it spells PRAISE.

P. Pray. Close the day the way you opened it: with Him. Short is fine.

R. Review. Look at your day in the app. What got done, what didn't, what happened. A man should never end a day he didn't look at.

A. Affirmation. Speak life over yourself. Those three truths you wrote on Day 13? This is their slot. Out loud. Your ears need to hear your voice saying what God says.

I. Inventory. Check your heart. Anything ugly get in today? Resentment, lust, envy, a lie you told, a person you owe an apology? Find it now, deal with it now. Don't let it compound overnight. Interest accrues while you sleep.

S. Scripture. A few verses, or a page of something that grows you. Last input of the day. Remember the rule from the mornings: the deepest voice speaks first. At night, the deepest voice speaks LAST.

E. Entrust. One line to God: tomorrow is Yours before it starts. Then set out what tomorrow needs, clothes, alarm across the room, and put the day down. It's His now. Sleep like it.

The app now has this built in. From tonight on, there's a nightly flow that walks you through all six, a few minutes total, and you unlocked it by being here on Day 15. Run PRAISE tonight for the first time. Morning belongs to J.E.S.U.S., night belongs to PRAISE, and the man in between is becoming somebody.

**ACTION:** Run the PRAISE flow in the app tonight. Phone still sleeps outside the room.

---

### DAY 16 · THE TIME LOCK
*Charge · ~4 min · action: Google Calendar time blocking*

Mornings, locked. Nights, locked. Now the hours in between, because here's a hard truth: you can win both bookends and still lose the middle of your day to everybody else's agenda.

Look at yesterday. Outside your routines, who decided how your hours got spent? Be honest. The inbox decided. The group chat decided. The algorithm definitely decided. Drift decided. Your vision letter is sitting in the vault describing a man with a certain life, and not one hour of yesterday was assigned to building it.

Here's the principle: time you don't protect gets taken. Every time. Nobody is coming to guard your hours for you. The man in your letter doesn't have more time than you. He's got 24 like everybody. He just locks his.

So today, the time lock, and we keep it simple. Grab whatever you'll actually use: pen and paper works, a notecard on your desk works, and if you want it digital, Google Calendar is the tool. Then block TOMORROW. Not the whole month, not some fancy system. Tomorrow. Your morning hour first, that's a standing appointment with the King. Then two or three work blocks: the real work, the deep stuff, with a start time and an end time. Write them down like they're meetings, because that's what they are: meetings with your future.

Two rules about a block. One: protect it. When something tries to take it, and something will try tomorrow, you say the most powerful phrase in time management: "I have a commitment then." You don't have to say it's with yourself. Two: if life genuinely breaks a block, you don't delete it, you MOVE it. A moved block is a kept promise rescheduled. A deleted block is a surrender. Your goal tomorrow is simple: finish the blocks as planned.

Start with one day. A man who can protect one day can learn to protect a week. Lock tomorrow.

**ACTION:** Block tomorrow (pen and paper or Google Calendar): your morning hour + 2 to 3 work blocks. Protect them. If one breaks, move it, never delete it.

---

### DAY 17 · THE PILLAR MOVES
*Charge · ~4 min · action: define the moves, schedule them*

Yesterday you built fences around your time. Today we decide what lives inside them, and there's one question that unlocks all of it.

Go back to the man in your letter. Now look at this page: the app pulled your two weakest pillars, straight from your own honest scores. No hiding from your own numbers. And for each one, ask the question that changes everything, the question I want tattooed on the inside of your skull: what would HE do? The man in your letter. Not what does he want, not what does he believe. What does he DO?

Because here's the thing about the man you're becoming: he's not a feeling, he's a pattern of actions. The version of you with a thriving marriage DOES things: plans the date, asks the question, puts the phone down at dinner. The version with money handled DOES things: reviews the accounts weekly, invests on a schedule, tells his money where to go. The version with the strong body, the deep faith, the ordered house, all of them are just men with different DO lists.

So, your two weakest, and for each: what would he do? Write down one concrete move per pillar, and the page shows you examples for exactly your weak spots, so you can see the shape of a real move. Not "be better with money." Concrete: "Sunday, 30 minutes, full look at the accounts, set the auto-transfer." Not "invest in my marriage." Concrete: "Thursday night, date, planned by me, phone in the car."

And if you genuinely don't know what that man would do, that's not a wall, that's an assignment: research. Ask a man who's strong where you're weak. Search it. Read one chapter. Finding out IS the move this week.

Then, yesterday's skill: block it. Each move gets a day and a time in your calendar. A move without a time slot is a wish.

This is the engine you'll run for the rest of your life, by the way. Score the pillars, find the weak one, ask what HE would do, block it, do it. That's it. That's the whole game.

**ACTION:** Your two weakest pillars are on this page. One concrete move each ("what would he do?"), blocked into your calendar with a day and a time. Research counts as a move.

---

### DAY 18 · THE TONGUE
*Charge · ~4 min · installs: the affirmation bank (his words + God's words)*

Today we deal with the most underrated force in your life: your own mouth.

Here's something wild: you hear your own voice more than any voice on earth. Every word you say about yourself is a rep. "I'm terrible with money." "I always do this." "That's just how I am." Reps. You're literally training your own mind, and most men have been running the wrong program for decades and wondering why they can't change. Proverbs says death and life are in the power of the tongue. That's not poetry. That's mechanics.

Remember Day 2, when we named complaining as a thief? Here's why it made the list: complaining is agreeing with defeat, out loud, in your own voice, the most influential voice you know. So today, two moves.

Move one: the complaining fast. From now to Day 21, three days, not one complaint out of your mouth. Not about traffic, not about your boss, not about being tired. Catch yourself mid-sentence if you have to, laugh, and flip it: state the problem as something you're doing something about, or say what you're thankful for instead. Three days. Feel how hard it is. That's how deep the pattern runs.

Move two: build your affirmation bank, right here on this page. Two kinds of ammunition. First, God's words about you: the page has suggestions ready, tap the ones that hit, and your Day 13 truths are already in there. Son of the King. Bought at a price. More than a conqueror. Power, love, sound mind. Second, YOUR words. You remember the man in your letter. Write three "I am" statements about him, present tense, in your own voice. "I am a man who keeps his word." "I am the man who gets up." Yours, not borrowed.

From tonight on, the A in your P.R.A.I.S.E. night hands the whole bank back to you, and you say them OUT LOUD. Your ears hearing your voice speaking God's truth. That's renewal with sound on.

**ACTION:** Commit to the complaining fast until Day 21 (say it out loud: "no complaints for three days"). Build your affirmation bank on this page: tap the suggestions that hit + write 3 "I am" statements. Speak them tonight in P.R.A.I.S.E.

---

### DAY 19 · THE WITNESS
*Field · ~2 min · action: tell one man your vision*

Short one today, because today is about your voice leaving the building.

For eighteen days this has been between you, God, and your circle. Today you take the vision public, one man at a time. Here's the assignment: pick one man, and tell him your vision. Out loud. The man you're becoming, what you're building, what these three weeks have been.

I know exactly what just happened in your stomach. That clench? That's the fear of being seen trying. Every man has it. We'd rather succeed in secret so nobody watches us fail. But hear this: a vision spoken to another man becomes real in a way a private vision never does. It's the difference between a thought and a stake in the ground. Jesus sent his men out two by two, never solo, because He knew: what's witnessed, sticks.

Pick the man. Your brother, your dad, a friend who'd get it, the guy at the gym. Look him in the eye or call him, no texting, and say some version of: "I've been doing this 21-day thing. Here's the man I'm becoming." Two minutes of your vision, said out loud, to a witness.

Some of you are about to find out that your vision does something to the man hearing it. Don't be surprised if he says "man... I need something like that." Remember his name if he does. You'll want it on Day 21.

**ACTION:** One man. Your vision, out loud, eye to eye or voice to voice. No text.

---

### DAY 20 · THE LIFT
*Field · ~2 min · action: pour into one man*

Yesterday you spoke your vision to a witness. Today, the flow reverses. Today you lift somebody.

Somewhere in your world there's a man having a worse week than you. You know who he is. He came to mind just now, before I finished the sentence. That heaviness he's carrying, the thing he posted, the way he sounded last time you talked. Him.

Today, you pour in. Call him or see him, and do two things: ask him a real question and actually listen to the answer, and then speak something true and specific over him. Not flattery. Specific. "You're a better father than you think you are, and I've watched you prove it." "You carried your family through last year and nobody clapped. I saw it." One real sentence like that from another man can hold a guy up for a month. You know, because you know exactly which sentences you've been needing to hear.

Here's what's happening on the mechanics level, and why this is day twenty of twenty-one: everything you've built these three weeks, the mornings, the mind, the vision, was never just for you. Vessels aren't storage. Vessels POUR. This is the fifth stage, the whole point of the mountain: you climb so you can lower the rope. Today's the first pull.

And hear me: one call is the action, not the ceiling. If he needs more, give more. Another call this week. A meal. And if what's been changing you these three weeks is something he needs, bring him toward it when it's natural. Not a pitch. A door. You know the difference, because you know which one you'd walk through.

Tomorrow is Day 21. The mirror, and a letter you haven't seen in seventeen days. Come with your hands full.

**ACTION:** One man, one real question, one true and specific sentence spoken over him. Call or in person.

---

### DAY 21 · THE SECOND MIRROR
*Sending · ~7 min · the finale: re-score, the delta, the letter, the handoff, the invite*

Day 21. Sit down for this one. Somewhere quiet. This is the longest I'll talk to you, and it's the last day I talk to you like this, so let's do it right.

Three weeks ago you were a different man. I don't say that to flatter you. I say it because in about two minutes, you're going to prove it with numbers.

First: the mirror. Open the pillars and score yourself again, all seven, same rule as Day 1. Don't fake anything. Don't inflate it to make the story better, and don't deflate it out of false humility. Honest numbers. Go ahead, I'll wait. Pause this if you need to.

Now look. Day 1 next to Day 21. Look at what moved.

`[YOUR STORY: 45 seconds. What it felt like the first time you saw your own growth in numbers, or in evidence you couldn't argue with.]`

Those numbers moved because YOU moved. Because you got up when the alarm sounded, sat in the silence, met with God before you met with the world, caught the lies and answered them out loud, locked your hours, spoke your vision, lifted a brother. Twenty-one mornings, stacked. That's not motivation. That's evidence.

And now, the letter. Seventeen days ago you wrote to this exact moment. The app's about to hand it to you. Read it slowly. All of it.

...

You just heard your own voice describe the man you're becoming, and here's what I want you to notice: he's not a stranger anymore. Some of what you wrote, you're already doing. The rest? You now own the exact machine that builds him. The morning belongs to J.E.S.U.S.. The night belongs to PRAISE. The week has a debrief. The mind has weapons. The calendar has locks. The pillars have moves.

So here's the most important thing I'll say today: the program ends. The rhythm doesn't. Starting tomorrow there's no Day 22 audio waiting for you, and that's on purpose. You weren't building a dependence on my voice. You were building an operating system, and it's installed now. This app carries it: same morning flow, same nightly flow, same streak, same board, same brothers. Nothing stops tomorrow except my talking. The training wheels come off because you can ride.

Two last things.

One: keep the covenant with yourself. The wake time stays. The hour stays. If a thief gets you some night in week five, the Fall button will still be there, and so will grace. The deal was never perfection. Direction. Forever.

And two, the big one. Remember Day 19, when you told a man your vision, and I said watch his face? Somewhere in your life is a man who needs these 21 days. Maybe it's the man you told. Maybe it's the one you lifted yesterday. Maybe it's the name that's in your head right now, because there's always a name. Here's your last action, and it's the one that makes you a builder of His kingdom and not just a resident: bring him. Right here on this page there's a button, and it writes the invite for you: your words to send him, ready to go. Pick the brother. Send it. Your 21 ends with his beginning. That's how this works. That's how it's always worked: transformed men transform men.

You showed up twenty-one times. You're not the man from the first mirror. Now go be him, and take somebody with you.

It's His kingdom. You're the vessel. Go build it.

**ACTION:** Re-score the 7 pillars. Read the Day 1 vs Day 21 delta. Read your letter. Send one man his invite to the next 21.

---

---

# THE RECORDING KIT

**Logistics:** Apple Voice Memos, one take, imperfect is the standard. Improvise freely off the scripts. After each recording, paste the Voice Memos transcript to Claude: it becomes the in-app read-along (cleaned lightly). Name files `day01`, `day02`, ... Claude uploads to Supabase Storage.

**The one rule when improvising:** END every recording by stating the day's ACTION exactly as written in the script's ACTION line. The app shows that same text on the action card; mouth and card must match.

**The full recording list (26 files):**
- **Day 0 · The Welcome** (~2 min): plays on enrollment, any time of day
- Days 1 to 6, 8 to 20: one file each (19 files)
- Day 7: TWO files (morning ~90 sec + evening debrief)
- Day 21: TWO files (part one: up to "score yourself again" → the app inserts the Mirror → part two: the delta, the letter, the sending)
- **The Fall** (~90 sec): for the 1am fall. No shame. Get up, water, one text, sleep. Grace is already waiting.
- **The Grace Morning** (~20 sec): plays first thing after any missed day. "Yesterday's gone. Today is open. Move."

**Per-day must-land beats (don't drop these while improvising):**
- D1: don't fake anything · score all 7 · "starting line, not sentence"
- D2: name the thieves incl. complaining · phone OUT of bedroom tonight · the Fall button exists
- D3: (your visualization) · land it: dump raw notes in journal NOW, before the world gets in
- D4: present tense · seals until Day 21 · Rom 12:2
- D5: vessel not engine · "why would He bless YOUR kingdom?" · open hands + one sentence out loud
- D6: wake time declared to circle · alarm ACROSS the room · 3 starter habits, small
- D7am: feet before negotiation, run the three || D7pm: 3 sentences · grace = direction not perfection
- D8: J.E.S.U.S. = the pieces, but RUN order = Silence first · alarm minus 15 · 5 min quiet before any input
- D9: undivided means undivided, phone elsewhere · alarm minus 15 more · Mark 1:35 (dark, solitary, prayed)
- D10: the deepest voice goes FIRST · read till it catches, then chew · alarm minus 15 more
- D11: "Jesus didn't write, His disciples did" · write what He's teaching you · no alarm change
- D12: final minus 15 = full hour claimed · sweat is the standard · full run tomorrow
- D13: thoughts → decisions → life · CATCH, REPLACE, REPEAT, LIVE · write top 3 lies + truths in app · 2 Tim 1:7
- D14: fight-back week named · secrets grow thieves, light kills them · PRAISE teased
- D15: walk all six letters P·R·A·I·S·E · the app now walks it nightly · deepest voice speaks LAST at night
- D16: time you don't protect gets taken · Google Cal: routines + work + VISION BLOCKS · stop ghosting meetings with your future
- D17: "what does that man DO?" · one concrete move per weak pillar · a move without a time slot is a wish
- D18: complaining fast until Day 21 · affirmation bank: God's words + 3 "I am" lines · out loud in PRAISE
- D19: one man, vision out loud, no text · "what's witnessed, sticks" · remember his name
- D20: one real question + one true specific sentence over him · vessels pour
- D21 pt1: same rule, don't fake anything · score now || pt2: the delta is evidence · the letter · "the program ends, the rhythm doesn't" · bring one man

**Recording cadence (locked):** Day 1 now (the voice test) → Claude builds the engine on dev with it → record Week 1 + Fall + Grace while the engine builds → full dev test run on the time machine → record Week 2 with what the test taught → stay one week ahead of the cohort, never more.

**Engine pre-flight (Claude, on dev):** progress fields added to merge rules (completions grow-only, letter = sacred content, uid-tagged) · disaster drills pass (two devices, fresh device mid-program, empty cloud, offline completion, midnight-straddle completion) · J.E.S.U.S./PRAISE visibility COMPUTED never stored (the anti-Oura-bug rule) · fallback scripture bank if Day 13 skipped · audio pre-cache for offline mornings · dev time machine (jump/reset days) · prod untouched until Leo's explicit ship.*
