module Skylab::System


    class Services___::Filesystem

      class Find__  # see [#171].

        # synopsis:
        #
        #   • this is a :+[#ba-027]:#normal-normalizer: once built this entity
        #     is :+[#bs-018] immutable, effecting :+[#sl-016] spawn-and-mutate
        #
        #   • when successful the entity holds a tokenized array of strings
        #     (the "command args") obviating the need to shellescape here
        #     (but know what you're doing!! major :+#security concern)
        #
        #   • this node itself is concerned with modeling the entity not
        #     finding the files, however producing an array of paths for
        #     the latter is the default behavior for some forms of call.
        #     as well there exists (recommended) progressive streaming.

        class << self

          def mixed_via_iambic_ x_a, & oes_p
            new do
              @on_event_selectively = oes_p
              process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
            end.__mixed_result
          end

          private :new
        end  # >>

        Callback_::Actor.methodic self, :properties, :as_normal_value
          # (and see many iambic writers below)

        def initialize & edit_p

          @as_normal_value = DEFAULT_AS_NORMAL_VALUE_PROC___
          @on_event_selectively = DEFAULT_ON_EVENT_SELECTIVELY___

          @sanitized_freeform_query_infix_words = nil
          @sanitized_freeform_query_postfix_words = nil

          @unescaped_filename_a = []
          @unescaped_ignore_dir_a = []
          @unescaped_path_a = []

          instance_exec( & edit_p )
          _decide_if_curry_and_resolve_command_args
          freeze
        end

        DEFAULT_AS_NORMAL_VALUE_PROC___ = -> cmd do
          cmd.to_path_stream.to_a
        end

        DEFAULT_ON_EVENT_SELECTIVELY___ = -> i, * _, & ev_p do
          if :info != i
            raise ev_p[].to_exception
          end
        end

        def new_with * x_a, & oes_p
          dup.__init_new x_a, & oes_p
        end

        def initialize_copy _otr_

          # do not freeze here or make ivar dups here, this dup is for
          # internal copies whose existing ivars are read-only but who
          # must themselves reamain mutable, see #note-130

        end

      protected def __init_new x_a, & oes_p

          # for now this is hand-written to allow only the paths to change:

          @unescaped_path_a = @unescaped_path_a.dup

          oes_p and accept_selective_listener_proc oes_p

          ok = process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a

          ok and begin
            _decide_if_curry_and_resolve_command_args
            freeze
          end
        end

        private def accept_selective_listener_proc p  # #hook-out for [ca]
          @on_event_selectively = p ; nil
        end

        def _decide_if_curry_and_resolve_command_args
          if @unescaped_path_a.length.zero?
            @is_curry = true
          else
            @is_curry = false
            __resolve_valid_command_args
          end
          NIL_
        end

        def freeze
          @unescaped_filename_a.freeze
          @unescaped_ignore_dir_a.freeze
          @unescaped_path_a.freeze
          super
        end

        attr_reader :args

        def filename_array
          @unescaped_filename_a
        end

        def path_array
          @unescaped_path_a
        end

      private

        def filename=
          @unescaped_filename_a.clear.push gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def filenames=

          # an "or" list
          x = gets_one_polymorphic_value
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

          arg = _normalize_unsanititized_freeform_string_array gets_one_polymorphic_value
          arg and begin
            @sanitized_freeform_query_infix_words = arg.value_x   # nil OK
            KEEP_PARSING_
          end
        end

        def freeform_query_postfix_words=

          arg = _normalize_unsanititized_freeform_string_array gets_one_polymorphic_value
          arg and begin
            @sanitized_freeform_query_postfix_words = arg.value_x  # nil OK
            KEEP_PARSING_
          end
        end

        def ignore_dirs=
          @unescaped_ignore_dir_a.replace gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def path=
          @unescaped_path_a.clear.push gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def paths=
          @unescaped_path_a.clear.replace gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def trusted_strings=  # WARNING the hash is not currently dup-aware
          h = ( @trusted_string_h ||= {} )
          gets_one_polymorphic_value.each do | s |
            h[ s ] = true
          end
          KEEP_PARSING_
        end

        def _normalize_unsanititized_freeform_string_array s_a

          if s_a
            __normalze_trueish_unsanitized_freeform_string_array s_a
          else
            Callback_::Known.new_known s_a  # a false-ish value is valid
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
            Callback_::Known.new_known s_a
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
            @as_normal_value[ self ]
          else
            @last_error_result  # #todo
          end
        end

        def to_path_stream
          @args and begin
            Find__::Actors_::Build_path_stream[ @args, & @on_event_selectively ]
          end
        end

        def express_into_under y, expag

          express_under( expag ).express_into_under y, expag
        end


        def __resolve_valid_command_args  # amazing hax #note-130

          otr = dup
          otr.extend Command_Building_Methods__  # pattern :+[#sl-144]
          @args = otr.__args_via_flush
          if @args && @on_event_selectively
            @on_event_selectively.call :info, :event, :find_command_args do

              express_under :Event
            end
          end
          NIL_
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

            __add_paths

            @y.push DOUBLE_DASH___

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
          FIND__ = 'find'.freeze

          def __add_paths

            @unescaped_path_a.each do | path |
              @y.push F__, path.freeze  # ( we used to :+#escape here )
            end
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

            st = Callback_::Stream.via_times string_ary.length do | d |
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

        Autoloader_[ Expression_Adapters = ::Module.new ]

        Find_ = self
      end
    end
end
# :+#posterity :+#tombstone `collapse` was an early ancestor of the n11n pattern
# :+#posterity :+#tombstone the find node that used to be in [st] deleted
