// Metronome.cs
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Timers;

class Metronome
{
    private int bpm;
    private int beatsPerMeasure;
    private int beatUnit;
    private bool running;
    private int beatCount;
    private System.Timers.Timer timer;
    private readonly object lockObj = new object();

    [DllImport("kernel32.dll")]
    private static extern bool Beep(int freq, int duration);

    public Metronome(int bpm, int beats, int unit)
    {
        this.bpm = bpm;
        this.beatsPerMeasure = beats;
        this.beatUnit = unit;
        this.beatCount = 0;
    }

    private void BeepSound()
    {
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            Beep(800, 100);
        }
        else
        {
            Console.Write(" 🔔");
        }
    }

    private void Visual(int beatNum, bool isDownbeat)
    {
        char downbeatChar = '█';
        char otherChar = '░';
        char barChar = isDownbeat ? downbeatChar : otherChar;
        string bar = new string(barChar, 10);
        Console.Write($"\rBeat {beatNum}/{beatsPerMeasure}: {bar}");
    }

    private void Tick(object sender, ElapsedEventArgs e)
    {
        lock (lockObj)
        {
            if (!running) return;
            beatCount++;
            int beatNum = ((beatCount - 1) % beatsPerMeasure) + 1;
            bool isDownbeat = beatNum == 1;
            Visual(beatNum, isDownbeat);
            BeepSound();
        }
    }

    public void Start()
    {
        running = true;
        beatCount = 0;
        double intervalMs = 60000.0 / bpm;
        timer = new System.Timers.Timer(intervalMs);
        timer.Elapsed += Tick;
        timer.AutoReset = true;
        timer.Enabled = true;
        Console.WriteLine($"\nStarting metronome at {bpm} BPM ({beatsPerMeasure}/{beatUnit}). Press Ctrl+C to stop.\n");
        // Wait for Ctrl+C
        Console.CancelKeyPress += (sender, e) =>
        {
            e.Cancel = true;
            Stop();
        };
        while (running) { Thread.Sleep(100); }
    }

    private void Stop()
    {
        lock (lockObj)
        {
            if (!running) return;
            running = false;
            timer?.Stop();
            timer?.Dispose();
            Console.WriteLine("\nStopped.");
        }
    }

    static void Main(string[] args)
    {
        Console.WriteLine("=== Metronome ===");
        Console.Write("Enter BPM (20-300) [120]: ");
        string bpmInput = Console.ReadLine()?.Trim();
        int bpm = 120;
        if (!string.IsNullOrEmpty(bpmInput) && int.TryParse(bpmInput, out int v) && v >= 20 && v <= 300)
            bpm = v;
        Console.Write("Enter time signature (e.g., 4/4) [4/4]: ");
        string sigInput = Console.ReadLine()?.Trim();
        if (string.IsNullOrEmpty(sigInput)) sigInput = "4/4";
        var parts = sigInput.Split('/');
        int beats = 4, unit = 4;
        if (parts.Length == 2 && int.TryParse(parts[0], out beats) && int.TryParse(parts[1], out unit) && beats > 0 && unit > 0)
        { /* use parsed */ }
        else { beats = 4; unit = 4; }
        var metro = new Metronome(bpm, beats, unit);
        metro.Start();
    }
}
