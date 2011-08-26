require File.expand_path('../../task', __FILE__)
require 'stringio'
module Skylab::Face
  class DependencyGraph
    class TaskTypes::Executable < Task
      include Open2
      attribute :executable
      def check
        if '' == (path = open2("which #{@executable}").strip)
          @ui.err.puts("#{hi_name}: #{ohno('not in PATH:')} #{@executable}")
          false
        else
          @ui.err.puts("#{hi_name}: #{path}")
          true
        end
      end
    end
  end
end
