# metronome.rb
class Metronome
  def initialize(bpm, beats_per_measure, beat_unit)
    @bpm = bpm
    @beats_per_measure = beats_per_measure
    @beat_unit = beat_unit
    @beat_count = 0
    @running = false
    @interval = 60.0 / bpm
  end

  def beep
    # Try system beep on Linux, else print
    if RUBY_PLATFORM =~ /linux/
      system("beep -f 800 -l 100 2>/dev/null")
    else
      print " 🔔"
    end
  end

  def visual(beat_num, is_downbeat)
    downbeat_char = '█'
    other_char = '░'
    bar_char = is_downbeat ? downbeat_char : other_char
    bar = bar_char * 10
    print "\rBeat #{beat_num}/#{@beats_per_measure}: #{bar}"
    STDOUT.flush
  end

  def tick
    @beat_count += 1
    beat_num = ((@beat_count - 1) % @beats_per_measure) + 1
    is_downbeat = beat_num == 1
    visual(beat_num, is_downbeat)
    beep
  end

  def start
    @running = true
    @beat_count = 0
    puts "\nStarting metronome at #{@bpm} BPM (#{@beats_per_measure}/#{@beat_unit}). Press Ctrl+C to stop.\n"
    trap("INT") { stop }
    loop do
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      tick
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
      sleep_time = @interval - elapsed
      sleep(sleep_time) if sleep_time > 0
    end
  rescue Interrupt
    stop
  end

  def stop
    return unless @running
    @running = false
    puts "\nStopped."
    exit
  end
end

def parse_time_signature(sig)
  parts = sig.split('/')
  if parts.length == 2
    beats = parts[0].to_i
    unit = parts[1].to_i
    if beats > 0 && unit > 0
      return beats, unit
    end
  end
  [4, 4]
end

def main
  puts "=== Metronome ==="
  print "Enter BPM (20-300) [120]: "
  bpm_input = gets.chomp.strip
  bpm = 120
  if !bpm_input.empty?
    bpm = bpm_input.to_i
    bpm = 120 if bpm < 20 || bpm > 300
  end
  print "Enter time signature (e.g., 4/4) [4/4]: "
  sig_input = gets.chomp.strip
  sig_input = "4/4" if sig_input.empty?
  beats, unit = parse_time_signature(sig_input)
  metro = Metronome.new(bpm, beats, unit)
  metro.start
end

main if __FILE__ == $0
