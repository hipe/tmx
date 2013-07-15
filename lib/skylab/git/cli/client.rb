module Skylab::Git

  class CLI::Client

    # we built a custom client so that `face` wouldn't intercept the '-h'
    # and it was fun.

    def initialize *ioe
      @sin, @out, @err = ioe
    end

    def invoke argv
      if argv.length.nonzero? and (( m = self.class::H_[ argv[ 0 ] ] ))
        argv.shift
        send m, argv
      else
        pn, st = Face::FUN.at :program_basename, :stylize
        hi = st.curry[ [ :green ] ]
        @err.puts "#{ hi[ 'usage: '] }#{ pn[] } #{
          }[ #{ self.class::A_ * ' | ' } ] [..]"
        @err.puts "see #{ hi[ "#{ pn[] } <cmd> -h" ] } for help on that #{
          }command"
        nil
      end
    end

    a = [ ]

    define_singleton_method :method_added do |i|
      a and ( a << i )
      nil
    end

    def stash_untracked argv
      Git::CLI::Actions::Stash_Untracked::CLI.
        new( @sin, @out, @err ).invoke argv
    end

    def push argv
      require_relative 'actions/push'
      ::TmxGit::Push::CLI.new.run argv
      nil
    end

    const_set :A_, [ ] ; const_set :H_, { }
    a.each do |i|
      moniker = i.to_s.gsub( '_', '-' )
      A_ << moniker
      H_[ moniker ] = i
    end
    a = nil ; A_.freeze ; H_.freeze
  end
end
