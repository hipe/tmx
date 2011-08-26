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
        @fileutils_label = "#{hi_name}: "
      end
      def slake
        interpolated? or interpolate! or return false
        check and return true
        deps? or return dead_end
        slake_deps or return false
        check and return true
        @ui.err.puts("#{hi_name}: #{ohno('error:')} move to: source file not found: #{@from}")
        false
      end
      def check
        if File.exist?(@move_to)
          @ui.err.puts("#{hi_name}: exists: #{@move_to}")
          true
        elsif File.exist?(@from)
          mv(@from, @move_to, :verbose => true)
          true
        else
          false
        end
      end
    end
  end
end
