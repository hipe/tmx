#!/usr/bin/env ruby

require 'ncurses'
require 'ruby-debug'

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
  class ProgressBar
    include Common
    def initialize(ui = nil, &b)
      @ui ||= DefaultUi.singleton
      @out, @err = [@ui.out, @ui.err]
      @nc = Ncurses
      @unit = 'sec'
      presenter_class = case :ugly
        when :ncurses ; NcursesBar ;
        when :ugly    ; Ugly       ;
        else          ; fail("nope")
      end
      @presenter = presenter_class.new(self)
    end
    attr_reader :out, :err, :ui
    def run
      _init_state
      _render_frame
      _wait
      loop do
        _advance_state
        _render_frame
        @done and break
        _wait
      end
    end
    def _init_state
      @done = false
      @t0 = @t1 = Time.now
      @t0f = @t0.to_f
      @start_units = 1.3
      @current_units = 1.3
      @end_units = 2.2
      _recalculate :span_of_units_at_end
      @fps = 3
      _divide_by_zero_check
      @animation_duration_seconds = 3.0
      _recalculate :minimum_frame_delay_seconds
      _recalculate :number_of_frames
      _recalculate :last_frame_index
      @current_frame_index = 0
      @presenter.init_state
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
      ratio = @presenter.waypoints[@current_frame_index][:ratio]
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
      span_of_units_so_far / @span_of_units_at_end
    end
    def _render_frame
      @t1f = Time.now.to_f
      @presenter.render_frame
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
  end
  class Ugly
    include Common
    def initialize progress_bar
      @data = progress_bar
      @err = progress_bar.ui.err
    end
    def init_state
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
    def _formatted_percent
      sprintf('%.2f%', @data.ratio * 100)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  include Skylab
  Kurse.run_progress_bar
end

