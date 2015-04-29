module Skylab::Headless

  module IO

    DRY_STUB__ = class Dry_Stub__  # getting a good dry run

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

      def __say_d mode_d

        "sanity - expected ( CREATE | WRONLY [ | TRUNC ] ) had #{ mode_d }"
      end

      def puts *a
      end

      def truncate d
        d
      end

      def write s
        "#{ s }".length
      end

      def close
        # there is risk of this silently succeeding when it should have
        # failed per state, but meh we would have to remove the singleton  #open [#170]
      end

      class << self

        def the_dry_byte_downstream_identifier
          THE_DRY_BYTE_DOWNSTREAM_IDENTIFIER___
        end
      end

      module THE_DRY_BYTE_DOWNSTREAM_IDENTIFIER___

        class << self
          def to_minimal_yielder
            LT_LT___
          end
        end  # >>

        class Less_Than_Less_Than___
          def << _
            self
          end
        end

        LT_LT___ = Less_Than_Less_Than___.new

      end

      self
    end.new.freeze  # :+#[#sl-126] class for singleton
  end
end
