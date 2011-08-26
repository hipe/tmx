require File.expand_path('../../task', __FILE__)
module Skylab::Face
  class DependencyGraph
    class TaskTypes::Symlink < Task
      attribute :symlink
      attribute :target
      def slake
        interpolated? or interpolate! or return false
        stay, success = check
        stay or return success
        deps? or return dead_end
        slake_deps or return false
        _, success = check
        success
      end
      def check
        interpolated? or interpolate! or return false
        if File.exist?(target)
          if File.exist?(symlink)
            if File.lstat(symlink).symlink?
              [false, true] # later for checking
            else
              @ui && @ui.err.puts("#{hi_name}: File exists but is not symlink: #{symlink}")
              [false, false]
            end
          else
            @ui && @ui.err.puts("#{hi_name}: ln -s #{target} #{symlink}")
            if 0 == (r = File.symlink(target, symlink))
              [false, true]
            else
              @ui && @ui.err.puts("#{hi_name}: Unexpected status from symlink command: #{r.inspect}")
              [false, false]
            end
          end
        else
          [true, nil] # the target file does not exist.  stay and try this again
        end
      end
    end
  end
end
