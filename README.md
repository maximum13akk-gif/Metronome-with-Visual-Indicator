🥁 Metronome with Visual Indicator

A simple yet effective **metronome** for the command line.  
Set the tempo (BPM), choose a time signature (e.g., `4/4`), and watch the visual beat indicator tick with every pulse.  
Built in **7 programming languages** – ideal for musicians, learners, and developers.

## ✨ Features
- **Adjustable tempo** – set beats per minute (20–300 BPM).
- **Time signature** – choose `2/4`, `3/4`, `4/4`, `6/8`, etc. (default `4/4`).
- **Visual indicator** – a blinking symbol (e.g., `█` for the downbeat, `░` for others) updates in real time.
- **Beat counter** – shows the current beat number within the measure.
- **Optional sound** – plays a system beep (or prints frequency) on each beat (where supported).
- **Start/Stop** – start the metronome, stop it with `Ctrl+C` or a command.
- **Cross‑platform** – works on Windows, macOS, and Linux (sound may vary).

## 🗂 Languages & Files
| Language          | File            |
|-------------------|-----------------|
| Python            | `metronome.py`  |
| Go                | `metronome.go`  |
| JavaScript (Node) | `metronome.js`  |
| C#                | `Metronome.cs`  |
| Java              | `Metronome.java`|
| Ruby              | `metronome.rb`  |
| Swift             | `metronome.swift`|

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler.

| Language | Command |
|----------|---------|
| Python   | `python metronome.py` |
| Go       | `go run metronome.go` |
| JavaScript | `node metronome.js` |
| C#       | `dotnet run` (or `csc Metronome.cs && Metronome.exe`) |
| Java     | `javac Metronome.java && java Metronome` |
| Ruby     | `ruby metronome.rb` |
| Swift    | `swift metronome.swift` |

## 📊 Example Session
=== Metronome ===
Enter BPM (20-300) [120]: 140
Enter time signature (e.g., 4/4) [4/4]: 4/4
Starting metronome at 140 BPM (4/4). Press Ctrl+C to stop.

Beat 1: ████ (downbeat)
Beat 2: ░░░░
Beat 3: ░░░░
Beat 4: ░░░░
Beat 1: ████ (downbeat)
...
^C
Stopped.

text

## 🔧 Commands (Interactive)
On start, the program prompts for:
- **BPM** (20–300) – press Enter to use default (120).
- **Time signature** – enter as `n/m` (e.g., `4/4`, `3/4`). Default `4/4`.

After starting, it runs until you press `Ctrl+C`.

## 📁 Sound Support
- **Windows**: uses `Console.Beep` (C#) or `winsound.Beep` (Python).
- **Linux**: tries `beep` command (install via `sudo apt install beep`).
- **macOS**: no built‑in beep – prints frequency instead.
If sound is unavailable, the program silently continues with visual only.

## 🤝 Contributing
Add support for MIDI, accelerometer input, or a graphical interface – PRs welcome!

## 📜 License
MIT – use freely.
