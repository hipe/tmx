require File.expand_path('../../task', __FILE__)
require 'fileutils'
module Skylab::Face
  class DependencyGraph
    class TaskTypes::MoveTo < Task
      include FileUtils
      attribute :move_to
      attribute :from
      def initialize(*a)
        super(*a)
        @fileutils_output = @ui.err
        @fileutils_label = "#{me}: "
      end
      def slake
        interpolated? or interpolate! or return false
        check and return true
        deps? or return dead_end
        slake_else or return false
        check and return true
        @ui.err.puts("#{me}: #{ohno('error:')} move to: source file not found: #{@from}")
        false
      end
      def check
        interpolated? or interpolate! or return false
        if File.exist?(@move_to)
          @ui.err.puts("#{me}: exists: #{@move_to}")
          true
        elsif File.exist?(@from)
          mv(@from, @move_to, :verbose => true)
          true
        else
          false
        end
      end
      def interpolate_stem
        need_else.interpolate_stem
      end
    end
  end
end
