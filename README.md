# BlockWood clone in Defold

## Why clone a Tetris clone?

My preferred Tetris-like app for iOS is called _BlockWood_. It's really elegant and enjoyable, with minimal interruptions and no fancy rule complications.

> But what about Android?

Searching online I might have found it on Google Play, but I can't confirm, since neither of my modern Android devices could install it for cryptic reasons. That's why I decided to quickly create a clone.

> Quickly?

Well, my time isn't worth spending on this at all, so I opted for agentic coding. I used [Kimi K2.6](https://openrouter.ai/moonshotai/kimi-k2.6) with [OpenCode](https://opencode.ai/), and only done manual corrections here and there to achieve my initial goals.

> And why Defold?

[Defold](https://defold.com/) uses Lua for scripting, which is incredibly memory- and storage-efficient, and also quite readable and maintainable without previous experience. I hate very few things, but complex software and bloated apps are definitely among them. Just by opting for Defold, the bundled Android app takes up less than 6 MB of storage and loads almost instantly.

## The result

- Bundles into a tiny app. (Only tested on Android.)
- Game parameters are nicely configurable in the source, with some available in a settings menu.
- Closely matches the original (clone) experience.
- Has absolutely no ads.

## Screenshots

| Main menu | Paused mid-game |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/87f9fbf1-83dd-47f5-a3bc-0c67de223ae9" alt="Screenshot_20260502_191930" width="300"> | <img src="https://github.com/user-attachments/assets/6cffc4bf-48cd-42bb-9a92-9585ad3175f5" alt="Screenshot_20260502_192235" width="300"> |
## How to build

1. [Install Defold](https://defold.com/download/)
2. Clone this repo
3. Open the project in Defold
4. <kbd>CTRL</kbd> + <kbd>B</kbd> to preview, `Project` -> `Bundle` to... well, bundle
