require File.expand_path('../../task', __FILE__)

module Skylab::Dependency
  class TaskTypes::Symlink < Task
    attribute :symlink
    attribute :target
    def slake
      stay, success = execute
      stay or return success
      fallback? or return dead_end
      fallback.slake or return false
      _, success = execute
      success
    end
    def check
      lstat = File.lstat(symlink) rescue Errno::ENOENT
      if lstat == Errno::ENOENT
        _info "Symbolic link does not exist: #{symlink}"
        false
      elsif lstat.symlink?
        tgt = File.readlink(symlink)
        if File.exist?(tgt)
          if tgt == target
            _info "link ok: #{symlink} -> #{tgt}"
            true
          else
            _info <<-HERE.gsub(/\n?^(  ){8}/, ' ')
              wrong target? (too strict?)
              #{symlink} -> #{ohno(tgt)} (expecting "-> #{target}")
            HERE
            false
          end
        else
          _info "bad symlink: #{symlink} -> #{ohno(tgt)}"
          false
        end
      else
        _info "Is not symbolic link: #{symlink}"
        false
      end
    end
    def execute
      if File.exist?(target)
        if File.exist?(symlink)
          if File.lstat(symlink).symlink?
            [false, true] # later for checking
          else
            _info "File exists but is not symlink: #{symlink}"
            [false, false]
          end
        else
          _show_bash "ln -s #{target} #{symlink}"
          if dry_run?
            optimistic_dry_run? or _pretending "success from above"
            [false, true]
          elsif 0 == (r = File.symlink(target, symlink))
            [false, true]
          else
            _info "Unexpected status from symlink command: #{r.inspect}"
            [false, false]
          end
        end
      else
        [true, nil] # the target file does not exist.  stay and try this again
      end
    end
  end
end

