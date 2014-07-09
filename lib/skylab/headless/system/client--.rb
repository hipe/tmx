module Skylab::Headless

  module System

    class Client__  # read [#014] #section-2 introduction to the client

      def initialize
        # ( here is where we would easily append user args )
        absrb_iambic_fully DEFAULT_ARG_X_A__.dup  # until [#mh-068]
        freeze ; nil
      end

      def which exe_name
        SAFE_NAME_RX__ =~ exe_name or "invalid name: #{ exe_name }"
        out = Headless::Library_::Open3.popen3 'which', exe_name do |_, o, e|
          EMPTY_STRING_ == (( err = e.read )) or raise ::SystemCallError,
            "unexpected response from `which` - #{ err }"
          o.read.strip
        end
        out if EMPTY_STRING_ != out
      end
      SAFE_NAME_RX__ = /\A[-a-z0-9_]+\z/i


      defn_x_a = [ :absorber, :absrb_iambic_fully,
        :passive, :absorber, :absorb_iambic_passively  # until [#mh-067]
      ]
      o = defn_x_a.method :push  # declarations
      a = []  # definitions


      o[ :memoized, :proc, :any_home_directory_path ]

      a << :any_home_directory_path << -> do
        ::ENV[ 'HOME' ]
      end


      o[ :memoized, :method, :any_home_directory_pathname ]

      a << :any_home_directory_pathname << -> do
        (( s = any_home_directory_path )) and ::Pathname.new( s )
      end


      MetaHell_::Fields.contoured.from_iambic_and_client defn_x_a, self

      DEFAULT_ARG_X_A__ = a.freeze

    end
  end
end
