module Skylab::Basic

  module String::LineStream_via_String  # :[#024]

      # represent a string as a stream of "lines", each produced successively
      # through the universal minimal stream interface of a method named
      # `gets`. any trailing newline sequence is included with each produced
      # line (per the UNIX-y semantics of line "terminators" (not separators
      # [#sn-020])). (blank lines are each their own item.)
      #
      # in addition to `gets` there are two more exposed API points:
      #
      #   • the current "line number" is available thru `lineno`, with
      #     semantics similar to the synonymous platform method on an `IO`
      #     in terms of what for e.g "line 1" means.
      #
      #   • also like a platform IO, this can be rewound back to the
      #     beginning with `rewind` (because internally it uses a string
      #     scanner, but you don't know that).
      #
      # only peripherally related, a "reverse scanner" merely writes to
      # a mutable string though a yielder as proxy, writing newlines as
      # appropriate with *separator* (not terminator) semantics. as this
      # is not "correct" (per the previous above reference), this will be
      # sunsetted #todo.

    class << self

      def define & p
        # make an assuption here
        SeparatorSemanticsScanner___.new( & p )
      end

      def call s
        QuitePopularLineScanner___.new s
      end
      alias_method :[], :call
    end  # >>

      # ==

      class QuitePopularLineScanner___

        include Common_::Stream::InstanceMethods

        def initialize s
          @upstream = TerminatorSemantics___.new s
        end

        def lineno
          @upstream.__lineno_
        end

        def rewind
          @upstream.__rewind_
        end

        def gets
          @upstream.__gets_
        end

      def close
        # (this is stateless unlike a resource handle, but for sanity:)
        remove_instance_variable :@upstream ; nil
      end

        def new_by & p
          Common_::Stream.by( & p )
        end
      end

      # ==

      class SeparatorSemanticsScanner___

        def initialize
          yield self
          s = remove_instance_variable :@string
          rx = remove_instance_variable :@separator

          if rx.respond_to? :ascii_only?
            rx = ::Regexp.new rx
          end

          @_not_separator_rx = ::Regexp.new(
            "(?:(?!#{ rx.source }).)+",
            rx.options,  # if this one uses 'x', use 'x' ..
          )

          @_scn = Home_.lib_.string_scanner s
          @_separator_rx = rx
          @_gets = :_first_gets

          s = send @_gets
          if s
            @_kn_kn = Writable_Known_Known___[ s ]
            @unparsed_exists = true
          end
        end

        attr_writer(
          :separator,
          :string,
        )

        def to_stream
          Common_.stream do
            if @unparsed_exists
              gets_one
            end
          end
        end

        def gets_one
          x = head_as_is
          advance_one
          x
        end

        def advance_one
          s = send @_gets
          if s
            @_kn_kn.value = s
          else
            remove_instance_variable :@_kn_kn
            @unparsed_exists = false
          end
          NIL
        end

        def head_as_is
          @_kn_kn.value
        end

        attr_reader(
          :unparsed_exists
        )

        def _first_gets
          s = @_scn.scan @_not_separator_rx
          if s
            @_gets = @_scn.eos? ? :_done : :__subsequent_gets
            s
          elsif @_scn.eos?
            @_gets = :_done
            NOTHING_
          else
            @_scn.check( @_separator_rx ) || self._REGEX_SANITY
            self._WE_NEED_OPTIONS_for_absoulte_path_looking_strings
          end
        end

        def __subsequent_gets  # assume not eos
          @_scn.skip @_separator_rx or self._REGEX_SANITY
          if @_scn.eos?
            self._WE_NEED_OPTIONS_for_dir_looking_strings
          else
            s = @_scn.scan @_not_separator_rx
            s || self._REGEX_SANITY
            if @_scn.eos?
              @_gets = :_done
            end
            s
          end
        end

        def _done
          NOTHING_
        end
      end

      # ==

      class TerminatorSemantics___

        # to be in the stream inheirance hierarchy we must contain all of our
        # state in one object that can be passed around to derivative streams

        def initialize s

          lineno = 0

          @_lineno = -> do
            lineno
          end

          scn = Home_.lib_.string_scanner s

          @_gets = -> do
            s = scn.scan String::LINE_RX_
            if s
              lineno += 1
            end
            s
          end

          @_rewind = -> do
            lineno = 0
            scn.pos = 0
            0  # look like file IO
          end
        end

        def __gets_
          @_gets[]
        end

        def __lineno_
          @_lineno[]
        end

        def __rewind_
          @_rewind[]
        end
      end

      # ==

      Reverse = -> mutable_string do  # see #the-reverse-scanner
        is_first = true
        ::Enumerator::Yielder.new do |line|
          if is_first
            is_first = false
            mutable_string.concat line
          else
            mutable_string.concat "#{ NEWLINE_ }#{ line }"
          end ; nil
        end
      end

      # ==

      Writable_Known_Known___ = ::Struct.new :value

      # ==
  end
end
