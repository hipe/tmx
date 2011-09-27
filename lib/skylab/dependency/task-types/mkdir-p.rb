require File.expand_path('../../task', __FILE__)
require 'skylab/face/path-tools'
require 'pathname'
require 'fileutils'

module Skylab
  module Dependency
    class TaskTypes::MkdirP < Task

      class Maker
        # we need a dedicated class for this because the host object has its own mkdir_p
        # which is different
        include FileUtils
        def initialize stream, prefix
          @fileutils_output = stream
          @fileutils_label = prefix
        end
        public :mkdir_p
      end

      include ::Skylab::Face::PathTools
      include FileUtils
      attribute :mkdir_p
      attribute :maxdepth

      def check
        @ok = true
        if File.exist?(@mkdir_p)
          true
        else
          dir = @mkdir_p
          current_depth = 0
          begin
            dir = File.dirname(dir)
            current_depth += 1
          end while ! File.directory?(dir) and ! ['.','/'].include?(dir) and current_depth <= @maxdepth
          if current_depth > @maxdepth
            _info("won't mkdir more than #{@maxdepth} levels deep " <<
              "(#{pretty_path @mkdir_p} requires #{current_depth} levels)")
            @ok = false
            false
          else
            _info "doesn't exist, can create #{pretty_path @mkdir_p}"
            false
          end
        end
      end

      def slake
        check and return true # silent ok
        ! @ok and return false
        Maker.new(ui.err, "#{me}: ").mkdir_p(@mkdir_p, :verbose => true)
        true
      end

      def _defaults!
        @maxdepth ||= 1
      end
    end
  end
end

