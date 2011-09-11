require File.expand_path('../../task', __FILE__)
module Skylab::Face
  class DependencyGraph
    class TaskTypes::Symlink < Task
      attribute :symlink
      attribute :target
      def slake
        interpolated? or interpolate! or return false
        stay, success = execute
        stay or return success
        deps? or return dead_end
        slake_else or return false
        _, success = execute
        success
      end
      def interpolate_stem
        need_else.interpolate_stem
      end
      def check
        interpolated? or interpolate! or return false
        lstat = File.lstat(symlink) rescue Errno::ENOENT
        if lstat == Errno::ENOENT
          @ui && @ui.err.puts("#{me}: Symbolic link does not exist: #{symlink}")
          false
        elsif lstat.symlink?
          tgt = File.readlink(symlink)
          if File.exist?(tgt)
            if tgt == target
              @ui && @ui.err.puts("#{me}: link ok: #{symlink} -> #{tgt}")
              true
            else
              @ui && @ui.err.puts(<<-HERE.gsub(/\n?^(  ){8}/, ' ')
                #{me}: wrong target? (too strict?)
                #{symlink} -> #{ohno(tgt)} (expecting "-> #{target}")
              HERE
              )
              false
            end
          else
            @ui && @ui.err.puts("#{me}: bad symlink: #{symlink} -> #{ohno(tgt)}")
            false
          end
        else
          @ui && @ui.err.puts("#{me}: Is not symbolic link: #{symlink}")
          false
        end
      end
      def execute
        interpolated? or interpolate! or return false
        if File.exist?(target)
          if File.exist?(symlink)
            if File.lstat(symlink).symlink?
              [false, true] # later for checking
            else
              @ui && @ui.err.puts("#{me}: File exists but is not symlink: #{symlink}")
              [false, false]
            end
          else
            @ui && @ui.err.puts("#{me}: ln -s #{target} #{symlink}")
            if 0 == (r = File.symlink(target, symlink))
              [false, true]
            else
              @ui && @ui.err.puts("#{me}: Unexpected status from symlink command: #{r.inspect}")
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
