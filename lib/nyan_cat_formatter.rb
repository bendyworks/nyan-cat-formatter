# -*- coding: utf-8 -*-
require 'rspec/core/formatters/base_text_formatter'

class NyanCatFormatter < RSpec::Core::Formatters::BaseTextFormatter

  TRAIL_CHARS = %w( ¯ ¯ · . ¸ ¸ . · )

  ESC     = "\e["
  NND     = "#{ESC}0m"
  PASS    = '='
  FAIL    = '*'
  ERROR   = '!'
  PENDING = '·'

  attr_accessor :current, :color_index, :bar_length, :example_results,
    :pending_count, :failure_count, :title, :title_width, :max_title_width,
    :max_count_width

  def start(example_count)
    super(example_count)
    self.current, self.color_index = 0,0
    self.bar_length = `tput cols`.to_i
    self.example_results = []
    self.max_count_width = example_count.to_s.size
    self.max_title_width = max_count_width * 2 + 4
  end

  def example_passed(example)
    super(example)
    tick TRAIL_CHARS[current % TRAIL_CHARS.count]
  end

  def example_pending(example)
    super(example)
    self.pending_count =+1
    tick PENDING
  end

  def example_failed(example)
    super(example)
    self.failure_count =+1
    tick FAIL
  end

  # Increments the example count and displays the current progress
  #
  # Returns nothing
  def tick(mark = PASS)
    self.example_results << mark
    self.current =  (current > example_count) ? example_count : current + 1
    dump_progress
  end

  # Displays the current progress in all Nyan Cat glory
  #
  def dump_progress
    title = "  #{current.to_s.rjust max_count_width}/#{example_count.to_s.rjust max_count_width}:"
    max_width = 30
    self.color_index -= [bar_length - max_title_width - 18, current].min - 1
    examples = example_results.last(bar_length - max_title_width - 18)
    rainbow = examples.map {|r| highlight r}.join
    output.print (' ' * title.size) + rainbow + nyan_cat_back + "\n"
    output.print (' ' * title.size) + rainbow + nyan_cat_ears + "\n"
    output.print title + rainbow + nyan_cat_face + "\n"
    output.print (' ' * title.size) + rainbow + nyan_cat_feet + "\r\e[3A"
  end

  def start_dump
    self.current = example_count
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    dump_profile if profile_examples? && failure_count == 0
    summary = "\n\n\n\n\nNyan Cat flew for #{format_seconds(duration)} seconds".split(//).map { |c| rainbowify(c) }
    output.puts summary.join
    output.puts colorise_summary(summary_line(example_count, failure_count, pending_count))
    dump_commands_to_rerun_failed_examples
  end

  def dump_failures
    # noop
  end

  # Ascii Nyan Cat. If tests are complete, Nyan Cat goes to sleep. If
  # there are failing or pending examples, Nyan Cat is concerned.
  #
  # Returns String Nyan Cat
  def nyan_cat_back
    '  ╭ ━━━━━━ ╮'
  end

  def nyan_cat_ears
    '  ┃.  〮.  〮⟑   ⟑'
  end

  def nyan_cat_face
    if failure_count > 0 || pending_count > 0
      '╭ ┃ . ᐧ（｡ˣ⌢ ˣ｡）'
    elsif (current == example_count)
      '╰ ┃ . ᐧ（｡ᐢ‿‿ᐢ｡）'
    else
      tail = current % 4 < 2 ? '╭ ' : '╰ '
      "#{tail}┃ ᐧ .（｡°‿‿°｡）"
    end
  end

  def nyan_cat_feet
    if current % 4 < 2
      '  ╰ ━⊍━⊍━━ ⊍ ⊍'
    else
      '  ╰ ⊍━⊍━━━⊍ ⊍ '
    end
  end


  # Colorizes the string with raindow colors of the rainbow
  #
  def rainbowify(string)
    c = colors[color_index % colors.size]
    self.color_index += 1
    "#{ESC}38;5;#{c}m#{string}#{NND}"
  end

  # Calculates the colors of the rainbow
  #
  def colors
    colors ||= (0...(6 * 7)).map do |n|
      pi_3 = Math::PI / 3
      n *= 1.0 / 6
      r  = (3 * Math.sin(n           ) + 3).to_i
      g  = (3 * Math.sin(n + 2 * pi_3) + 3).to_i
      b  = (3 * Math.sin(n + 4 * pi_3) + 3).to_i
      36 * r + 6 * g + b + 16
    end
  end

  # Determines how to color the example.  If pass, it is rainbowified, otherwise
  # we assign red if failed or yellow if an error occurred.
  #
  def highlight(mark = PASS)
    if TRAIL_CHARS.include? mark
      rainbowify mark
    else
      case mark
        when FAIL;  red mark
        when ERROR; yellow mark
        else mark
      end
    end
  end

end

