// metronome.swift
import Foundation

class Metronome {
    let bpm: Int
    let beatsPerMeasure: Int
    let beatUnit: Int
    private var beatCount: Int = 0
    private var running: Bool = false
    private var timer: Timer?
    private let interval: TimeInterval

    init(bpm: Int, beats: Int, unit: Int) {
        self.bpm = bpm
        self.beatsPerMeasure = beats
        self.beatUnit = unit
        self.interval = 60.0 / Double(bpm)
    }

    @objc func beep() {
        #if os(Linux)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/beep")
        process.arguments = ["-f", "800", "-l", "100"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        #else
        print(" 🔔", terminator: "")
        #endif
    }

    func visual(beatNum: Int, isDownbeat: Bool) {
        let downbeatChar = "█"
        let otherChar = "░"
        let barChar = isDownbeat ? downbeatChar : otherChar
        let bar = String(repeating: barChar, count: 10)
        print("\rBeat \(beatNum)/\(beatsPerMeasure): \(bar)", terminator: "")
        fflush(stdout)
    }

    @objc func tick() {
        guard running else { return }
        beatCount += 1
        let beatNum = ((beatCount - 1) % beatsPerMeasure) + 1
        let isDownbeat = beatNum == 1
        visual(beatNum: beatNum, isDownbeat: isDownbeat)
        beep()
    }

    func start() {
        running = true
        beatCount = 0
        print("\nStarting metronome at \(bpm) BPM (\(beatsPerMeasure)/\(beatUnit)). Press Ctrl+C to stop.\n")
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        // Wait for interrupt
        signal(SIGINT) { _ in
            exit(0)
        }
        RunLoop.current.run()
    }

    func stop() {
        guard running else { return }
        running = false
        timer?.invalidate()
        print("\nStopped.")
        exit(0)
    }
}

func parseTimeSignature(_ sig: String) -> (Int, Int) {
    let parts = sig.split(separator: "/")
    if parts.count == 2, let beats = Int(parts[0]), let unit = Int(parts[1]), beats > 0, unit > 0 {
        return (beats, unit)
    }
    return (4, 4)
}

func main() {
    print("=== Metronome ===")
    print("Enter BPM (20-300) [120]: ", terminator: "")
    let bpmInput = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    var bpm = 120
    if !bpmInput.isEmpty, let v = Int(bpmInput), v >= 20, v <= 300 {
        bpm = v
    }
    print("Enter time signature (e.g., 4/4) [4/4]: ", terminator: "")
    let sigInput = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "4/4"
    let (beats, unit) = parseTimeSignature(sigInput.isEmpty ? "4/4" : sigInput)
    let metro = Metronome(bpm: bpm, beats: beats, unit: unit)
    // Handle SIGINT to stop gracefully
    signal(SIGINT) { _ in
        print("\nStopped.")
        exit(0)
    }
    metro.start()
}

main()
