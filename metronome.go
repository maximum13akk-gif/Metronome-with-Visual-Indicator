// metronome.go
package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"
)

type Metronome struct {
	bpm              int
	beatsPerMeasure  int
	beatUnit         int
	running          bool
	interval         time.Duration
	beatCount        int
}

func NewMetronome(bpm, beats, unit int) *Metronome {
	return &Metronome{
		bpm:             bpm,
		beatsPerMeasure: beats,
		beatUnit:        unit,
		interval:        time.Duration(float64(60)/float64(bpm)*1000) * time.Millisecond,
	}
}

func (m *Metronome) beep() {
	switch runtime.GOOS {
	case "windows":
		// No simple beep without syscalls; we'll print
		fmt.Print(" 🔔")
	case "linux":
		cmd := exec.Command("beep", "-f", "800", "-l", "100")
		cmd.Run()
	default:
		fmt.Print(" 🔔")
	}
}

func (m *Metronome) visual(beatNum int, isDownbeat bool) {
	downbeatChar := "█"
	otherChar := "░"
	bar := downbeatChar
	if !isDownbeat {
		bar = otherChar
	}
	bar = strings.Repeat(bar, 10)
	fmt.Printf("\rBeat %d/%d: %s", beatNum, m.beatsPerMeasure, bar)
}

func (m *Metronome) tick() {
	m.beatCount++
	beatNum := (m.beatCount-1)%m.beatsPerMeasure + 1
	isDownbeat := beatNum == 1
	m.visual(beatNum, isDownbeat)
	m.beep()
}

func (m *Metronome) Start() {
	m.running = true
	m.beatCount = 0
	fmt.Printf("\nStarting metronome at %d BPM (%d/%d). Press Ctrl+C to stop.\n", m.bpm, m.beatsPerMeasure, m.beatUnit)
	ticker := time.NewTicker(m.interval)
	defer ticker.Stop()
	go func() {
		for m.running {
			<-ticker.C
			m.tick()
		}
	}()
	// Wait for interrupt
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, os.Interrupt)
	<-ch
	m.running = false
	fmt.Println("\nStopped.")
}

func parseTimeSignature(sig string) (int, int) {
	parts := strings.Split(sig, "/")
	if len(parts) == 2 {
		b, err1 := strconv.Atoi(parts[0])
		u, err2 := strconv.Atoi(parts[1])
		if err1 == nil && err2 == nil && b > 0 && u > 0 {
			return b, u
		}
	}
	return 4, 4
}

func main() {
	fmt.Println("=== Metronome ===")
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter BPM (20-300) [120]: ")
	bpmStr, _ := reader.ReadString('\n')
	bpmStr = strings.TrimSpace(bpmStr)
	bpm := 120
	if bpmStr != "" {
		if v, err := strconv.Atoi(bpmStr); err == nil && v >= 20 && v <= 300 {
			bpm = v
		}
	}
	fmt.Print("Enter time signature (e.g., 4/4) [4/4]: ")
	sigStr, _ := reader.ReadString('\n')
	sigStr = strings.TrimSpace(sigStr)
	if sigStr == "" {
		sigStr = "4/4"
	}
	beats, unit := parseTimeSignature(sigStr)
	metro := NewMetronome(bpm, beats, unit)
	metro.Start()
}
