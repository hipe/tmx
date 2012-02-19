#!/usr/bin/env ruby

require 'ncurses'

module Skylab; end

module Skylab::Kurse
  module BuilderMethods; end
  extend BuilderMethods
  module BuilderMethods
    def run_progress_bar(*a, &b)
      ProgressBar.new(*a, &b).run
    end
  end
  class DefaultUi < Struct.new(:out, :err)
    def self.singleton
      @singleton ||= new($stdout, $stderr)
    end
  end
  module Common
    def _recalculate attr
      instance_variable_set "@#{attr}", nil
      send attr
    end
  end
  module MyAttributeDefiner # @todo etc
   def float *names
      names.each do |attr|
        attr_reader attr
        define_method("#{attr}=") do |mixed|
          case mixed
          when String
            /\A-?\d+(?:\.\d+)?\z/ =~ mixed or fail("For #{attr}, invalid float: #{mixed.inspect}")
          end
          instance_variable_set("@#{attr}", mixed.to_f)
        end
      end
    end
  end
  class ProgressBar
    include Common
    extend MyAttributeDefiner
    def initialize(opts=nil, &b)
      opts and opts.each { |k, v| send("#{k}=", v) }
      @animation_duration_seconds ||= 1.6
      @fps                        ||= 12
      @presenter                  ||= :ncurses
      @ui                         ||= (ui || DefaultUi.singleton)
      # units related:
      @unit                       ||= 'foo'
      @start_units                ||= 1.3
      @current_units              ||= @start_units
      @end_units                  ||= 2.2
      # internal attributes
      @out, @err                  = [@ui.out, @ui.err]
      @nc                         = Ncurses
      presenter_class = case @presenter
        when :ncurses ; NcursesBar ;
        when :ugly    ; Ugly       ;
        when :cr      ; Cr         ;
        else          ; fail("no: #{@presenter.inspect}")
      end
      @_presenter = presenter_class.new(self)
    end
    float :animation_duration_seconds
    float :current_units
    float :end_units
    attr_reader :err
    float :fps
    attr_reader :out
    attr_reader :presenter
    def presenter= mixed
      @presenter = mixed.kind_of?(String) ? mixed.intern : mixed
    end
    attr_reader :_presenter
    float :start_units
    attr_reader :ui
    attr_accessor :unit
    def run
      _start!
      _render_frame
      _wait
      loop do
        _advance_state
        _render_frame
        @done and break
        _wait
      end
      _end!
      true
    end
    def _start!
      @done = false
      @t0 = @t1 = Time.now
      @t0f = @t0.to_f
      _recalculate :span_of_units_at_end
      _divide_by_zero_check
      _recalculate :minimum_frame_delay_seconds
      _recalculate :number_of_frames
      _recalculate :last_frame_index
      @current_frame_index = 0
      @_presenter.on_start
    end
    def number_of_frames
      @number_of_frames ||= [(@animation_duration_seconds * @fps).floor + 1, 2].max
    end
    def last_frame_index
      @last_frame_index ||= @number_of_frames - 1
    end
    def _advance_state
      @done and return nil
      @current_frame_index += 1
      if @current_frame_index >= @last_frame_index
        @done = true
      end
      ratio = @_presenter.waypoints[@current_frame_index][:ratio]
      @current_units = @start_units + (ratio * @span_of_units_at_end)
    end
    def _divide_by_zero_check
      %w(fps span_of_units_at_end).each do |attr|
        if (0 == instance_variable_get("@#{attr}"))
          fail("#{attr} can't be zero")
        end
      end
    end
    def minimum_frame_delay_seconds
      @minimum_frame_delay_seconds ||= begin
        1.0 / @fps
      end
    end
    def span_of_units_at_end
      @span_of_units_at_end ||= @end_units - @start_units
    end
    def span_of_units_so_far
      @current_units - @start_units
    end
    def ratio
      span_of_units_so_far / span_of_units_at_end
    end
    def _render_frame
      @t1f = Time.now.to_f
      @_presenter.render_frame
    end
    def elapsed_animation_seconds
      Time.now.to_f - @t0f
    end
    def elapsed_frame_seconds
      Time.now.to_f - @t1f
    end
    def _wait
      if (wait_for = minimum_frame_delay_seconds - elapsed_frame_seconds) > 0
        sleep wait_for
      else
        # video lag ! you could throttle fips if you wanted to be insane
      end
    end
    def _end!
      @_presenter.on_end
    end
  end
  class Ugly
    include Common
    def initialize progress_bar
      @data = progress_bar
      @err = progress_bar.ui.err
    end
    def on_start
      _recalculate :waypoints
    end
    # be careful, this could hog memory, remember iit's fps * duration_of_animation
    def waypoints
      @waypoints ||= begin
        divisor = (@data.number_of_frames - 1).to_f
        (0 .. @data.number_of_frames).map do |frame_index|
          { :frame_index => frame_index, :ratio => (frame_index.to_f / divisor) }
        end
      end
    end
    def render_frame
      @err.puts sprintf('%7s', _formatted_percent) # blit
    end
    def _formatted_amount
      '%4.1f %s' % [@data.current_units, @data.unit]
    end
    def _formatted_percent
      '%6.2f%' % [@data.ratio * 100]
    end
    def on_end
    end
  end
  class NcursesBar < Ugly
    def initialize(*a)
      super(*a)
      @nc = Ncurses
    end
    BAR_COLOR_PAIR = 1 # our internal name for color pair
    BACK_COLOR_PAIR = 2
    BAR_HEIGHT = 1
    LABEL_WIDTH = 15 # 'xxx% (xx.x uni)'
    attr_reader :scr
    def on_start
      super
      @scr = @nc.initscr
      # @nc.cbreak # @todo what is this
      @_previous_cursor = @nc.curs_set(0) # don't show cursor
      _resized
      @bar = Ncurses::WINDOW.new(@box[:height], @box[:width], @box[:y], @box[:x])
      _init_color
      @bar.move(@box[:y], @box[:x])
    end
    def on_end
      @nc.curs_set(@_previous_cursor || 1) # show cursor again
      @scr.clear
      @scr.refresh
      @nc.endwin # without this you end up with it messing up your who-hahs
    end
    def _init_color
      @nc.start_color
      @nc.init_pair(BAR_COLOR_PAIR, @nc::COLOR_WHITE, @nc::COLOR_BLUE)
      @nc.init_pair(BACK_COLOR_PAIR, @nc::COLOR_WHITE, @nc::COLOR_BLACK)
      @bar.bkgd(@nc.COLOR_PAIR(BAR_COLOR_PAIR))
      @nc.bkgd(@nc.COLOR_PAIR(BACK_COLOR_PAIR))
    end
    def _resized
      @y, @x = @nc.getyx(@scr, y=[], x=[]) || [y.first, x.first]
      @box ||= {}
      @box.clear
      @box.merge!( :y => @y+1, :x => 0, :height => BAR_HEIGHT, :width => @nc.COLS )
      @label_x = [@box[:x].to_f + (@box[:width].to_f / 2) - (LABEL_WIDTH.to_f / 2), 0].max.to_i
    end
    def render_frame
      _new_width = [(@box[:width] * @data.ratio).ceil, 1].max
      @bar.wresize(@box[:height], _new_width)
      @bar.noutrefresh
      @nc.mvaddstr(@box[:y], @label_x, "#{_formatted_percent} (#{_formatted_amount})")
      @nc.refresh
      # @nc.doupdate
    end
  end
  class Cr < Ugly
    def on_start
      super
      @screen_width = 80
      @max_arrow_length = @screen_width - 18  # 'ddd.dd% (12.3 sec)'
      @max_stem_length = [@max_arrow_length - HEAD.length, 0].max
      @prev_length = 0
    end
    def _formatted_info
      "#{_formatted_percent} (#{_formatted_amount})"
    end
    HEAD = '>'
    TAIL = '|'
    STEM = '-'
    BLANK = ' '
    def _arrow
      length = [@max_arrow_length, (@data.ratio * @max_arrow_length).round].min
      stem_length = [length - HEAD.length, 0].max
      stem_length == @max_stem_length ? "#{STEM * stem_length}" : "#{STEM * stem_length}#{HEAD}"
    end
    def render_frame
      arrow = _arrow
      info = _formatted_info
      rest = "#{BLANK * [@screen_width - info.length - arrow.length - HEAD.length, 0].max}#{TAIL}"
      @err.write "#{"\r" * @screen_width}#{info}#{arrow}#{rest}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  include Skylab
  opts = {}; idx = 0; last = (argv = ARGV.dup).length - 1
  while idx <= last
    if md = /\A--([-a-z0-9]{2,})(?:=(.*))?\z/.match(argv[idx])
      opts[md[1].gsub('-', '_').intern] = md[3] || (md[2] ? md[2].gsub(/\\(?=")/, '') : nil)
      argv[idx] = nil
    end
    idx += 1
  end
  argv.compact!
  argv.any? and fail("unparsable argument(s): #{argv.map(&:inspect).join(' ')}")
  Kurse.run_progress_bar opts
end

