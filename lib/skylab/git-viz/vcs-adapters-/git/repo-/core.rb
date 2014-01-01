# preston-werner, wanstrath, tomayko et al did all the hard work already with grit
# so we keep it thin here.  The point of this abstraction layer is for us to
# give some thought about what our requirements are, if we ever decide to target
# other VCS's like hg; and to insulate ourselves from implementations in general
#

module Skylab::GitViz::API::VcsAdapter
  class Git::Repo < Struct.new(:focus_path, :native, :root)
    @@instances = {}
    def self.instances ; @@instances end

    def initialize git_root_path, focus_path
      self.root = git_root_path
      self.native = ::Grit::Repo.new(git_root_path.to_s)
      self.focus_path = focus_path
    end
  end
  class << Git::Repo
    def build path, emitter
      orig = path
      path = path.expand_path
      failed = false
      loop do
        path.join('.git').exist? and break
        path == (dirname = path.dirname) and failed = true and break
        path = dirname
      end
      if failed
        emitter.emit(:error, "Didn't find .git in this or any parent directory: #{orig}")
        return false
      end
      new(path, orig)
    end
    def get path, emitter
      normalized = path.expand_path(__FILE__).to_s
      instances[normalized] ||= build(path, emitter)
    end
  end
end

