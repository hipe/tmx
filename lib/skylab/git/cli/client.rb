module Skylab::Git

  class CLI::Client

    # we built a custom client so that `face` wouldn't intercept the '-h'
    # and it was fun.

    def initialize *ioe
      @sin, @out, @err = ioe
      @program_name = nil
    end

    attr_writer :program_name

    def invoke argv
      if argv.length.nonzero? and (( m = self.class::H_[ argv[ 0 ] ] ))
        argv.shift
        send m, argv
      else
        @err.puts "#{ hi 'usage: ' }#{ program_name } #{
          }[ #{ self.class::A_ * ' | ' } ] [..]"
        @err.puts "see #{ hi "#{ program_name } <cmd> -h" } for help on #{
          }that command"
        nil
      end
    end

  private

    def build_bound i
      unbound = Git::CLI::Actions.const_get i, false
      if unbound.const_defined? :CLI, false
        unbound = unbound::CLI
      end
      bound = unbound.new @sin, @out, @err
      bound.program_name = progname_for i.id2name.gsub( '_', '-' ).downcase
      block_given? and yield bound
      bound
    end

    def progname_for str
      "#{ program_name } #{ str }"
    end

    def program_name
      @program_name || Face::FUN.program_basename[]
    end

    def hi msg
      ( @hi ||= Face::CLI.stylify.curry[ [ :green ] ] )[ msg ]
    end

    def get_y
      ::Enumerator::Yielder.new( & @err.method( :puts ) )
    end

    a = []

    define_singleton_method :method_added do |i|
      a and ( a << i ) ; nil
    end

    def head argv
      _pn = Git::Library_::Headless::System.defaults.bin_pathname.
        join 'tmx-git-head'
      load _pn.to_s
      _progname = "#{ program_name } head"
      Git::CLI::Actions::Head[ get_y, _progname, argv ]
    end

    def scoot argv
      build_bound( :Scoot ).invoke argv
    end

    def spread argv
      build_bound( :Spread ).invoke argv
    end

    def stash_untracked argv
      build_bound( :Stash_Untracked ).invoke argv
    end

    def push argv
      require_relative 'actions/push'
      ::TmxGit::Push::CLI.new.run argv
      nil
    end

    def ping argv
      @err.puts "hello from git."
      :hello_from_git
    end

    const_set :A_, [] ; const_set :H_, { }
    a.each do |i|
      moniker = i.to_s.gsub '_', '-'
      A_ << moniker
      H_[ moniker ] = i
    end
    a = nil ; A_.freeze ; H_.freeze

    module Adapter
      module For
        module Face
          module Of
            Hot = -> ns_sheet, my_client_class do
              -> mechanics, _slug do
                Adapter_.new( ns_sheet, my_client_class, mechanics )
              end
            end
            class Adapter_ < ::Skylab::Face::CLI::Client::Adapter::For::Face::Of::Hot
              def get_summary_a_from_sheet _
                [ "assorted git-focused one-offs." ]
              end
            end
          end
        end
      end
    end
  end
end
