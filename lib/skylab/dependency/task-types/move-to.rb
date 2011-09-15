require File.expand_path('../../task', __FILE__)
require 'skylab/face/path-tools'
require 'fileutils'

module Skylab
  module Dependency
    class TaskTypes::MoveTo < Task
      include Skylab::Face::PathTools
      include FileUtils
      attribute :move_to
      attribute :from
      def initialize(*a)
        super(*a)
        @fileutils_output = ui.err
        @fileutils_label = "#{me}: "
      end
      def slake
        if File.exist?(@move_to)
          ui.err.puts "#{me}: desintation exists (move/rename to re-run): #{@move_to}"
          true
        else
          if ! File.exist?(@from) and fallback?
            fallback.slake or return false
          end
          execute
        end
      end
      def check
        if ! File.exist?(@from)
          ui.err.puts "#{me}: source file not found: #{@from}"
          false
        elsif File.exist?(@move_to)
          ui.err.puts "#{me}: exists: #{@move_to}"
          true
        else
          ui.err.puts "#{me}: does not exist: #{@move_to}"
          false
        end
      end
      def execute
        if File.exist?(@from)
          noop = request[:dry_run] ? true : false
          mv(@from, @move_to, :verbose => true, :noop => noop)
          true
        else
          ui.err.puts "#{me}: FAILED: source file not found: #{@from}"
          false
        end
      end
      def _undo
        if File.exist?(@move_to)
          if ! File.exist?(@from)
            mv(@move_to, @from, :verbose => true)
          else
            ui.err.puts "#{me}: can't undo: exists: #{pretty_path @from}"
            false
          end
        else
          ui.err.puts "#{me}: nothing to undo: does not exist: #{@move_to}"
          false
        end
      end
      def interpolate_stem
        fallback.interpolate_stem
      end
    end
  end
end
