# metronome.py
import time
import sys
import threading
import platform

class Metronome:
    def __init__(self, bpm=120, beats_per_measure=4, beat_unit=4):
        self.bpm = bpm
        self.beats_per_measure = beats_per_measure
        self.beat_unit = beat_unit
        self.running = False
        self.interval = 60.0 / bpm
        self.beat_count = 0

    def _beep(self):
        system = platform.system()
        try:
            if system == 'Windows':
                import winsound
                winsound.Beep(800, 100)
            elif system == 'Linux':
                import subprocess
                subprocess.run(['beep', '-f', '800', '-l', '100'], check=False)
            else:
                # macOS or others – just print frequency
                print(" 🔔", end='', flush=True)
        except:
            pass

    def _visual(self, beat_num, is_downbeat):
        # Clear line and print beat indicator
        downbeat_char = '█'
        other_char = '░'
        bar = downbeat_char if is_downbeat else other_char
        bar *= 10
        measure_info = f"Beat {beat_num}/{self.beats_per_measure}"
        print(f"\r{measure_info:20} {bar}", end='', flush=True)

    def _tick(self):
        self.beat_count += 1
        beat_num = ((self.beat_count - 1) % self.beats_per_measure) + 1
        is_downbeat = (beat_num == 1)
        self._visual(beat_num, is_downbeat)
        # Beep on downbeat or all beats? Let's beep on every beat.
        self._beep()

    def start(self):
        self.running = True
        self.beat_count = 0
        print(f"\nStarting metronome at {self.bpm} BPM ({self.beats_per_measure}/{self.beat_unit}). Press Ctrl+C to stop.\n")
        try:
            while self.running:
                start_time = time.perf_counter()
                self._tick()
                elapsed = time.perf_counter() - start_time
                sleep_time = self.interval - elapsed
                if sleep_time > 0:
                    time.sleep(sleep_time)
        except KeyboardInterrupt:
            self.running = False
            print("\nStopped.")

def parse_time_signature(sig):
    parts = sig.split('/')
    if len(parts) == 2:
        try:
            beats = int(parts[0])
            unit = int(parts[1])
            return beats, unit
        except:
            pass
    return 4, 4

def main():
    print("=== Metronome ===")
    bpm_input = input("Enter BPM (20-300) [120]: ").strip()
    bpm = 120
    if bpm_input:
        try:
            bpm = int(bpm_input)
            if bpm < 20 or bpm > 300:
                bpm = 120
        except:
            bpm = 120
    sig_input = input("Enter time signature (e.g., 4/4) [4/4]: ").strip()
    beats, unit = parse_time_signature(sig_input if sig_input else "4/4")
    metro = Metronome(bpm, beats, unit)
    metro.start()

if __name__ == "__main__":
    main()
