module Skylab::Headless

  module System

    class Client_

      # because singletons are bad for testing
      # see also the caveat in the parent node

      def initialize
        # ( here is where we would easily append user args )
        absorb( * DEFAULT_ARG_A_ )
        freeze
      end

      def which exe_name
        SAFE_NAME_RX_ =~ exe_name or "invalid name: #{ exe_name }"
        out = Headless::Services::Open3.popen3 'which', exe_name do |_, o, e|
          '' == (( err = e.read )) or raise ::SystemCallError, "unexpected #{
            }response from `which` - #{ err }"
          o.read.strip
        end
        out if '' != out
      end
      SAFE_NAME_RX_ = /\A[-a-z0-9_]+\z/i

      o = (( defn_a = [ ] )).method( :push )
      a = [ ]

      defn_a << :absorber_method_name << :absorb

      o[ :memoized, :proc, :any_home_directory_path ]

      a << :any_home_directory_path << -> do
        ::ENV[ 'HOME' ]
      end

      o[ :memoized, :method, :any_home_directory_pathname ]

      a << :any_home_directory_pathname << -> do
        (( s = any_home_directory_path )) and ::Pathname.new( s )
      end

      MetaHell::FUN::Fields_::Contoured_[ self, * defn_a ]

      DEFAULT_ARG_A_ = a.freeze

    end
  end
end
