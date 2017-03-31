module Skylab::System

  module IO

    module DRY_STUB ; class << self

      # this is meant to look like an IO (imagine a file) open for writing,
      # similar to writing to `/dev/null`. it may be useful to the client
      # drying to implement a dry run, so that it can invoke all of the same
      # moving parts as a real life file write.

      # since our instance can be (and should be) truly stateless (that
      # is, no member variables at all), it's #[#sl-126.2] a singleton
      # implemented with a module.

      # a bespoke #[#039.1] one of many such proxies

      def open mode

        if mode.respond_to? :ascii_only?
          WRITE_MODE_ == mode || APPEND_MODE_ == mode or fail __say_s mode
        else

          d = ::File::CREAT | ::File::WRONLY
          unless d == mode || ( d | ::File::TRUNC ) == mode
            fail __say_d node
          end
        end

        yield self
      end

      def __say_s mode_s

        "sanity - expected #{ WRITE_MODE_ } or #{ APPEND_MODE_ } had #{ mode_s }"
      end

      APPEND_MODE_ = 'a'
      WRITE_MODE_ = ::File::WRONLY | ::File::CREAT | ::File::TRUNC

      def __say_d mode_d

        "sanity - expected ( CREATE | WRONLY [ | TRUNC ] ) had #{ mode_d }"
      end

      def puts *a
        NIL
      end

      def << _
        self
      end

      def truncate d
        d
      end

      def write s
        s.length
      end

      def close
        # there is risk of this silently succeeding when it should have
        # failed per state, but meh we would have to remove the singleton  #open [#170]
        NIL
      end

    end ; end
  end
end
