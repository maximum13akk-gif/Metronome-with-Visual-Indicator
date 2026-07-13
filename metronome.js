// metronome.js
const readline = require('readline');
const { exec } = require('child_process');
const os = require('os');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

class Metronome {
    constructor(bpm, beatsPerMeasure, beatUnit) {
        this.bpm = bpm;
        this.beatsPerMeasure = beatsPerMeasure;
        this.beatUnit = beatUnit;
        this.running = false;
        this.interval = 60000 / bpm; // ms
        this.beatCount = 0;
        this.timer = null;
    }

    beep() {
        const platform = os.platform();
        if (platform === 'linux') {
            exec('beep -f 800 -l 100', (err) => { if (err) console.log('(beep unavailable)'); });
        } else {
            // Windows/macOS: just print a bell symbol
            process.stdout.write(' 🔔');
        }
    }

    visual(beatNum, isDownbeat) {
        const downbeatChar = '█';
        const otherChar = '░';
        const bar = (isDownbeat ? downbeatChar : otherChar).repeat(10);
        readline.cursorTo(process.stdout, 0);
        process.stdout.write(`Beat ${beatNum}/${this.beatsPerMeasure}: ${bar}`);
    }

    tick() {
        this.beatCount++;
        const beatNum = ((this.beatCount - 1) % this.beatsPerMeasure) + 1;
        const isDownbeat = beatNum === 1;
        this.visual(beatNum, isDownbeat);
        this.beep();
    }

    start() {
        this.running = true;
        this.beatCount = 0;
        console.log(`\nStarting metronome at ${this.bpm} BPM (${this.beatsPerMeasure}/${this.beatUnit}). Press Ctrl+C to stop.\n`);
        this.timer = setInterval(() => this.tick(), this.interval);
        // Handle Ctrl+C
        process.on('SIGINT', () => {
            this.stop();
        });
    }

    stop() {
        this.running = false;
        if (this.timer) {
            clearInterval(this.timer);
            this.timer = null;
        }
        console.log('\nStopped.');
        process.exit(0);
    }
}

function parseTimeSignature(sig) {
    const parts = sig.split('/');
    if (parts.length === 2) {
        const beats = parseInt(parts[0]);
        const unit = parseInt(parts[1]);
        if (!isNaN(beats) && !isNaN(unit) && beats > 0 && unit > 0) {
            return [beats, unit];
        }
    }
    return [4, 4];
}

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

async function main() {
    console.log('=== Metronome ===');
    const bpmInput = await ask('Enter BPM (20-300) [120]: ');
    let bpm = 120;
    if (bpmInput.trim()) {
        const v = parseInt(bpmInput);
        if (!isNaN(v) && v >= 20 && v <= 300) bpm = v;
    }
    const sigInput = await ask('Enter time signature (e.g., 4/4) [4/4]: ');
    const sig = sigInput.trim() || '4/4';
    const [beats, unit] = parseTimeSignature(sig);
    const metro = new Metronome(bpm, beats, unit);
    metro.start();
}

main().catch(console.error);
