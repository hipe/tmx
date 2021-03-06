module Skylab::System

  class Find  # see [#016].
    # -
      #   - remember there is the [#041.2] pipe-find-into-grep experiment

      # -
        # synopsis:
        #
        #   • this is a #[#fi-004.5] "normal normalizer": once built this entity
        #     is :+[#bs-018] immutable, effecting :+[#sl-023] dup-and-mutate
        #
        #   • when successful the entity holds a tokenized array of strings
        #     (the "command args") obviating the need to shellescape here
        #     (but know what you're doing!! major :+#security concern)
        #
        #   • this node itself is concerned with modeling the entity not
        #     finding the files, however producing an array of paths for
        #     the latter is the default behavior for some forms of call.
        #     as well there exists (recommended) progressive streaming.

      Attributes_actor_.call( self,
        when_command: nil,
      )

      class << self

        def against_mutable_ a, & p

          if a.length.zero?
            self
          else
            o = new( & p )
            kp = o.send :process_iambic_fully, a
            if kp
              o.__mixed_result
            else
              kp
            end
          end
        end

        def statuser_by & p
          Statuser__.new p
        end

        def _resolve_which_version_of_find
          @@_which_version_of_find.nil? or fail("only call this once")
          @@_which_version_of_find = _determine_which_version_of_find
          return @@_which_version_of_find
        end

        def _determine_which_version_of_find
          # This is a check to be run once per runtime.
          # NOTE memoize the results of this so it is only ever run once.
          # At #history-B.1 we changed our main development OS from OS X
          # to Ubuntu. In so doing, the system version of `find` changed from
          # a BSD version (we think) to a GNU version and everything broke.
          # The syntax is different # between these variants in ways that are
          # evidenced by the code below.
          # At writing we are coding it "carefully" in attempt to retain the
          # way it used to work on the BSD/OS X `find`, but there is no
          # assurance that we have retained that old way until we cover it,
          # which is beyond our resources at this time

          _, o, e, thread = Home_.services.popen3(FIND__, '--version')
          lines = []
          begin
            line = o.gets
            if line.nil?
              break
            end
            lines.push line
          end while true
          err_big_string = e.read
          thread.terminate
          if 0 == lines.length
            first_err_line  = err_big_string[/^[^\n\r]*/]
            fail("cover me (errput first line: #{first_err_line.inspect})")
          end
          line1 = lines[0]
          if line1.include?('GNU findutils')
            if not line1.include?(' 4.8.')
              fail "probably ok but sign off on this find version: #{line1}"
            end
            return :GNU_find
          end
          fail "cover me, hopefully a BSD version of `find` on OS X: #{line}"
        end

        private :new
      end  # >>

      @@_which_version_of_find = nil

      # ->

        def initialize & x_p

          @listener = x_p || DEFAULT_ON_EVENT_SELECTIVELY___

          @sanitized_freeform_query_infix_words = nil
          @sanitized_freeform_query_postfix_words = nil

          @unescaped_filename_a = []
          @unescaped_ignore_dir_a = []
          @unescaped_path_a = []
          @when_command = WHEN_COMMAND___
        end

        WHEN_COMMAND___ = -> cmd do
          cmd.to_probably_ordered_path_stream.to_a
        end

        DEFAULT_ON_EVENT_SELECTIVELY___ = -> i, * _, & ev_p do
          if :info != i
            raise ev_p[].to_exception
          end
        end

        def with * x_a, & p
          dup.__init_new x_a, & p
        end

        def initialize_copy _otr_

          # (hi.) dups are created when a client wants to modify a prototype
          # to create a new session, and also dups are created here for the
          # dup-and-mutate pattern. as such we do not freeze the dup [#016.B]
        end

        def __init_new x_a, & p

          # when the client wants to dup-and-muate a session. for now this
          # is written to allow only the argument paths to change (and etc):

          @unescaped_path_a = @unescaped_path_a.dup

          if p
            @listener = p
          end

          kp = process_argument_scanner_fully scanner_via_array x_a
          if kp
            frozen? || self._SANITY
            self
          else
            kp
          end
        end

        protected :__init_new

        def as_attributes_actor_normalize

          # assume this instance (whether prototype or session) is "done"
          # being mutated by arguments. whether or not we have zero argument
          # paths is the sole determiner of whether this is to be considered
          # a prototype or a session instance. life is easier/safer if we
          # always freeze here and only ever freeze here.

          if @unescaped_path_a.length.zero?
            @is_curry = true
            freeze
            KEEP_PARSING_
          else
            @is_curry = false
            kp = __resolve_valid_command_args
            freeze
            kp
          end
        end

        def freeze
          @unescaped_filename_a.freeze
          @unescaped_ignore_dir_a.freeze
          @unescaped_path_a.freeze
          super
        end

        attr_reader :args
        alias_method :to_command_tokens, :args  # look like grep. #todo get rid of above method

        def filename_array
          @unescaped_filename_a
        end

        def path_array
          @unescaped_path_a
        end

      private

        def filename=
          @unescaped_filename_a.clear.push gets_one
          KEEP_PARSING_
        end

        def filenames=

          # an "or" list
          x = gets_one
          if x
            @unescaped_filename_a.replace x
          else
            @unescaped_filename_a.clear
          end
          KEEP_PARSING_
        end

        def freeform_query_infix_words=

          # for now a hack to effect "-type d" etc. if we find ourselves
          # leveraging this more than once in the same "way", abstract.

          arg = _normalize_unsanititized_freeform_string_array gets_one
          arg and begin
            @sanitized_freeform_query_infix_words = arg.value   # nil OK
            KEEP_PARSING_
          end
        end

        def freeform_query_postfix_words=

          arg = _normalize_unsanititized_freeform_string_array gets_one
          arg and begin
            @sanitized_freeform_query_postfix_words = arg.value  # nil OK
            KEEP_PARSING_
          end
        end

        def ignore_dirs=
          @unescaped_ignore_dir_a.replace gets_one
          KEEP_PARSING_
        end

        def path=
          @unescaped_path_a.clear.push gets_one
          KEEP_PARSING_
        end

        def paths=
          @unescaped_path_a.clear.replace gets_one
          KEEP_PARSING_
        end

        def trusted_strings=  # WARNING the hash is not currently dup-aware
          h = ( @trusted_string_h ||= {} )
          gets_one.each do | s |
            h[ s ] = true
          end
          KEEP_PARSING_
        end

        def _normalize_unsanititized_freeform_string_array s_a

          if s_a
            __normalze_trueish_unsanitized_freeform_string_array s_a
          else
            Common_::KnownKnown[ s_a ]  # a false-ish value is valid
          end
        end

        def __normalze_trueish_unsanitized_freeform_string_array s_a

          extra_a = nil
          p = __i_am_not_to_be_trusted
          s_a.each do | s |
            if p[ s ]
              ( extra_a ||= [] ).push s
            else
              s.frozen? or s.freeze  # or change how you dup, or require
            end
          end
          if extra_a
            raise ::ArgumentError, "looks strange: #{ s_a.map( & :inspect ) } * ', ' }"
          else
            Common_::KnownKnown[ s_a ]
          end
        end

        def __i_am_not_to_be_trusted

          _TRUSTED = false ; _NOT_TRUSTED = true
          -> s do

            if FREEFORM_WORD_SANITY_RX___ =~ s
              _TRUSTED
            else
              h = @trusted_string_h
              if h && h[ s ]
                _TRUSTED
              else
                _NOT_TRUSTED
              end
            end
          end
        end

        FREEFORM_WORD_SANITY_RX___ = /\A-{0,2}[a-z0-9]+(?:-[a-z0-9]+)*\z/

      public

        def __mixed_result
          if @is_curry
            self
          elsif @args
            @when_command[ self ]
          else
            @last_error_result  # #todo
          end
        end

        def to_event
          Find_::Expression_Adapters::Event.with(
            :find_command_args, @args )
        end

        def to_path_stream_probably_ordered
          if not @args
            return  # act like pre #history-B.1
          end
          path_stream_probably_ordered_via Home_.lib_.open3
        end

        def path_stream_probably_ordered_via system_facade

          # This is a nasty but hack that's a placeholder for the idea:
          # On OS X, the filesystem seems to always order the entries, and
          # likewise in its builtin `find` utility.
          # On Ubuntu, no. the "probably" variant of these methods is to say
          # "preserve streaming if we can based on an assumption"
          # The fact that we're using which version of find to infer
          # the operating system (filesystem, actually) is probably bad

          unordered_st = _to_path_stream_unordered_via system_facade
          case _which_version_of_find
          when :BSD_find
            unordered_st
          when :GNU_find
            unordered = unordered_st.to_a
            ordered = Home_.services.maybe_sort_filesystem_paths unordered
            Common_::Stream.via_nonsparse_array ordered
          else
            fail
          end
        end

        def _to_path_stream_unordered_via system_conduit
            Find_::PathStream_via_SystemCommand___.call(
              @args,
              system_conduit,
              & @listener
            )
        end

        def __resolve_valid_command_args  # amazing hax #[#016.B]
          otr = dup
          otr.extend Command_Building_Methods__  # pattern #[#sl-003]
          x = otr.__args_via_flush
          if x
            @args = x
            if @listener
              @listener.call :info, :event, :find_command_args do
                express_under :Event
              end
            end
            ACHIEVED_
          else
            x
          end
        end

        def express_into_under y, expag
          express_under( expag ).express_into_under y, expag
        end

        def express_under modality_x
          __adapter_for( modality_x )[ self ]
        end

        def __adapter_for x
          Find_::Expression_Adapters.const_get x.intern, false
        end

        module Command_Building_Methods__

          def __args_via_flush

            if @unescaped_path_a.length.nonzero?
              __args_via_nonzero_length_list_of_paths
            else
              UNABLE_
            end
          end

          def __args_via_nonzero_length_list_of_paths

            # given any nonzero-length list of paths (and barring any
            # invalid additions to the freeform words array), we *think*
            # this is guaranteed always to build a valid find command..

            @y = [ FIND__ ]

            @y.push FOLLOW_ARGUMENT_SYMLINKS___

            __add_paths

            case _which_version_of_find
            when :GNU_find
              # nothing
            when :BSD_find
              @y.push DOUBLE_DASH___
            else
              fail
            end

            if @unescaped_ignore_dir_a.length.nonzero?
              __add_ignore_dir_phrase
            end

            s_a = @sanitized_freeform_query_infix_words
            if s_a
              @y.concat s_a
            end

            if @unescaped_filename_a.length.nonzero?
              __add_name_phrase
            end

            s_a = @sanitized_freeform_query_postfix_words
            if s_a
              @y.concat s_a
            end

            @y.freeze
          end

          DOUBLE_DASH___ = '--'.freeze
          FOLLOW_ARGUMENT_SYMLINKS___ = '-H'.freeze  # it's kind of gross
            # to hardcode this but it's what we need in one place [dt]
            # and probably what we want always. if not, can be optionized

          def __add_paths
            case _which_version_of_find
            when :GNU_find
              # when targeting Ubuntu, gnu findutils 4.8.0 doesn't have
              # a '-f' option (indicating a startingpoint). So we don't know
              # how we would target a file with a '-' as the first character
              on_each_path = -> path do
                @y.push path.freeze
              end
            when :BSD_find
              on_each_path = -> path do
                @y.push F__, path.freeze  # ( we used to :+#escape here )
              end
            else
              fail
            end

            @unescaped_path_a.each(& on_each_path)
            NIL_
          end

          F__ = '-f'.freeze

          def __add_ignore_dir_phrase
            @y.concat %w'-not ( -type d ( -mindepth 1 -a'
            _add_OR_list_via_unescaped_value_array @unescaped_ignore_dir_a
            @y.concat %w') -prune )'
          end

          def __add_name_phrase
            @y.push '('
            _add_OR_list_via_unescaped_value_array @unescaped_filename_a
            @y.push ')'
          end

          def _add_OR_list_via_unescaped_value_array string_ary

            st = Common_::Stream.via_times string_ary.length do | d |
              [ NAME_OPERATOR__, string_ary.fetch( d ) ]  # ( we used to :+#escape here )
            end

            s_a = st.gets
            if s_a
              @y.concat s_a
            end

            begin
              s_a = st.gets
              s_a or break
              @y.push OR_OPERATOR__
              @y.concat s_a
              redo
            end while nil
            NIL_
          end

          NAME_OPERATOR__ = '-name'.freeze
          OR_OPERATOR__ = '-o'.freeze

        end

        def _which_version_of_find
          if @@_which_version_of_find.nil?
            Find_._resolve_which_version_of_find
          end
          return @@_which_version_of_find
        end

        FIND__ = 'find'.freeze

        Autoloader_[ Expression_Adapters = ::Module.new ]

        Find_ = self
      # -
    # -

    # ==

    class Statuser__  # (this is in need of a better name. it's "satus"-"er",
      # (*not* "stat user") as in, "a thing that produces statuses.")

      # because the find command is immutable (stateless) and the stream is
      # just a stream, then the onus moves to the client to jump through
      # the hoops of eventing to determine whether the command emitted any
      # errors (otherwise it is impossible to know if (for example) receiving
      # nothing from the first `gets` mean the empty stream or a failure.)
      #
      # this is an experimental salve for that, but not perfect because the
      # client still has to know a lot to use this.

      def initialize p

        did = -> do
          @ok = false
        end

        @to_proc = -> * i_a, & x_p do
          if :error == i_a.fetch(0)
            did[]
          end
          if p
            p[ * i_a, & x_p ]
          end
          :_sy_unreliable_
        end

        @ok = true  # it *must* be innocent til proven guilty
      end

      attr_reader(
        :ok,  # we would say "is" or "was" but that is misleading
        :to_proc,
      )
    end
  end
end
# #history-B.1: target Ubuntu not OS X
# :+#posterity :+#tombstone `collapse` was an early ancestor of the n11n pattern
# :+#posterity :+#tombstone the find node that used to be in [st] deleted
