# preston-werner, wanstrath, tomayko et al did all the hard work already with grit
# so we keep it thin here.  The point of this abstraction layer is for us to
# give some thought about what our requirements are, if we ever decide to target
# other VCS's like hg; and to insulate ourselves from implementations in general
#

module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_

      def self.[] path_s, listener
        self::Resolve__.new( self, path_s, listener ).execute
      end

      def initialize absolute_pn, focus_dir_absoulte_pn, listener
        @listener = listener
        @focus_dir_relpath_pn = focus_dir_absoulte_pn.
          relative_path_from( absolute_pn )
        @absolute_pn = absolute_pn
        @ci_pool_p = -> { init_ci_pool }
        # MetaHell::FUN.without_warning { GitViz::Services::Grit[] }
        # @inner = ::Grit::Repo.new absolute_pn.to_path ; nil
      end

      class Resolve__  # this looks like a :+[#st-007] tree walk

        def initialize repo_cls, pn, listener
          @listener = listener ; @pn = pn
          @pn.absolute? or raise ::ArgumentError,
            "relative paths are not honored here - #{ pn }"
          @repo_cls = repo_cls ; nil
        end

        def execute
          pn = @pn ; count = 0
          begin
            pn.join( IMPLEMENTATION_DIR_ ).exist? and break
            count += 1
            TOP__ == pn.instance_variable_get( :@path ) and
              break( did_fail = true )
            pn = pn.dirname
          end while true
          @count = count
          did_fail ? when_did_fail : when_did_succeed( pn )
        end
        TOP__ = '/'.freeze
      private
        def when_did_fail
          @listener.call :repo_root_not_found, :error, :string do
            say_didnt_find_repo_implementation_dir
          end
          DESIST_
        end
        def say_didnt_find_repo_implementation_dir
          "Didn't find #{ IMPLEMENTATION_DIR_ } in this or any parent #{
            }directory (looked in #{ @count } dirs): #{ @pn }"
        end
        def when_did_succeed pn
          @repo_cls.new pn, @pn, @listener
        end
      end
    end
  end
  if false
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
    def get path, emitter
      normalized = path.expand_path(__FILE__).to_s
      instances[normalized] ||= build(path, emitter)
    end
  end
  end
end
