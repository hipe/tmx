require File.expand_path('../../task', __FILE__)
require 'stringio'
module Skylab::Face
  class DependencyGraph
    class TaskTypes::Executable < Task
      include Open2
      attribute :executable
      def check
        interpolated? or interpolate! or return false
        if '' == (path = open2("which #{@executable}").strip)
          @ui.err.puts("#{me}: #{ohno('not in PATH:')} #{@executable}")
          false
        else
          @ui.err.puts("#{me}: #{path}")
          true
        end
      end
    end
  end
end
