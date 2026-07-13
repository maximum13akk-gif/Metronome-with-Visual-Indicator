// Metronome.java
import java.util.Scanner;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class Metronome {
    private int bpm;
    private int beatsPerMeasure;
    private int beatUnit;
    private int beatCount;
    private boolean running;
    private ScheduledExecutorService scheduler;

    public Metronome(int bpm, int beats, int unit) {
        this.bpm = bpm;
        this.beatsPerMeasure = beats;
        this.beatUnit = unit;
        this.beatCount = 0;
        this.running = false;
    }

    private void beep() {
        // Java has no simple beep; we'll print a bell symbol
        System.out.print(" 🔔");
    }

    private void visual(int beatNum, boolean isDownbeat) {
        char downbeatChar = '█';
        char otherChar = '░';
        char barChar = isDownbeat ? downbeatChar : otherChar;
        StringBuilder bar = new StringBuilder();
        for (int i = 0; i < 10; i++) bar.append(barChar);
        System.out.printf("\rBeat %d/%d: %s", beatNum, beatsPerMeasure, bar.toString());
    }

    private void tick() {
        if (!running) return;
        beatCount++;
        int beatNum = ((beatCount - 1) % beatsPerMeasure) + 1;
        boolean isDownbeat = beatNum == 1;
        visual(beatNum, isDownbeat);
        beep();
    }

    public void start() {
        running = true;
        beatCount = 0;
        long intervalMs = (long)(60000.0 / bpm);
        System.out.printf("\nStarting metronome at %d BPM (%d/%d). Press Ctrl+C to stop.\n", bpm, beatsPerMeasure, beatUnit);
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(this::tick, 0, intervalMs, TimeUnit.MILLISECONDS);
        // Wait for interrupt
        try {
            Thread.sleep(Long.MAX_VALUE);
        } catch (InterruptedException e) {
            stop();
        }
    }

    public void stop() {
        if (!running) return;
        running = false;
        if (scheduler != null) {
            scheduler.shutdownNow();
            try { scheduler.awaitTermination(1, TimeUnit.SECONDS); } catch (InterruptedException e) {}
        }
        System.out.println("\nStopped.");
        System.exit(0);
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.println("=== Metronome ===");
        System.out.print("Enter BPM (20-300) [120]: ");
        String bpmInput = scanner.nextLine().trim();
        int bpm = 120;
        if (!bpmInput.isEmpty()) {
            try {
                int v = Integer.parseInt(bpmInput);
                if (v >= 20 && v <= 300) bpm = v;
            } catch (NumberFormatException e) {}
        }
        System.out.print("Enter time signature (e.g., 4/4) [4/4]: ");
        String sigInput = scanner.nextLine().trim();
        if (sigInput.isEmpty()) sigInput = "4/4";
        String[] parts = sigInput.split("/");
        int beats = 4, unit = 4;
        if (parts.length == 2) {
            try {
                beats = Integer.parseInt(parts[0]);
                unit = Integer.parseInt(parts[1]);
                if (beats <= 0 || unit <= 0) { beats = 4; unit = 4; }
            } catch (NumberFormatException e) { beats = 4; unit = 4; }
        }
        scanner.close();
        Metronome metro = new Metronome(bpm, beats, unit);
        // Add shutdown hook to stop on Ctrl+C
        Runtime.getRuntime().addShutdownHook(new Thread(metro::stop));
        metro.start();
    }
}
