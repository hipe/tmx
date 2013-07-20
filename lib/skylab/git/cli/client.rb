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

    def program_name
      @program_name || Face::FUN.program_basename[]
    end

    def hi msg
      ( @hi ||= Face::FUN.stylize.curry[ [ :green ] ] )[ msg ]
    end

    def progname_for str
      "#{ program_name } #{ str }"
    end

    def get_y
      ::Enumerator::Yielder.new( & @err.method( :puts ) )
    end

    a = [ ]

    define_singleton_method :method_added do |i|
      a and ( a << i )
      nil
    end

    def head argv
      Git::CLI::Actions::Head[ self, argv ]
    end

    def spread argv
      cli = Git::CLI::Actions::Spread.new( @sin, @out, @err )
      cli.program_name = progname_for 'spread'
      cli.invoke argv
    end

    def stash_untracked argv
      cli = Git::CLI::Actions::Stash_Untracked::CLI.new( @sin, @out, @err )
      cli.program_name = progname_for 'stash-untracked'
      cli.invoke argv
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

    const_set :A_, [ ] ; const_set :H_, { }
    a.each do |i|
      moniker = i.to_s.gsub( '_', '-' )
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
            class Adapter_ < ::Skylab::Face::CLI::Adapter::For::Face::Of::Hot
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
