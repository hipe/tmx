module Skylab::System

  class Services___::Filesystem

    class Normalizations_::Path_Based  # read [#004.G] near states
    private

      class << self

        def begin_ filesystem
          # hi.
          new filesystem
        end

        private :new  # all n11ns must begin by being begun (formally)
      end  # >>

      Callback_::Actor.methodic self

      def initialize filesystem

        @do_recognize_common_string_patterns_ = false
        @filesystem = filesystem
        @path_arg_was_explicit_ = false
      end

    public

      def against_path path, & oes_p

        if frozen?
          _otr = dup
          _otr.against_path path, & oes_p
        else
          if oes_p
            @on_event_selectively = oes_p
          end
          _accept_path path
          kn = execute
          if kn
            kn.value_x
          else
            kn
          end
        end
      end

      def new_with * x_a, & oes_p  # assume "edit" state

        kp = process_iambic_fully_ x_a, & oes_p
        if kp
          freeze  # or more
        else
          kp
        end
      end

      def edit_with * x_a, & oes_p  # assume "edit" state

        kp = process_iambic_fully_ x_a, & oes_p
        if kp
          self
        else
          kp
        end
      end

      def with * x_a, & oes_p

        if frozen?

          receive_call_when_curry_ x_a, & oes_p
        else
          __receive_call_when_editing x_a, & oes_p
        end
      end

      def byte_whichstream_identifier_for open_IO, up_or_down  # courtesy

        _cls = case up_or_down
        when :down
          Home_::IO::Byte_Downstream_Identifier
        when :up
          Home_::IO::Byte_Upstream_Identifier
        else
          raise ::ArgumentError, up_or_down
        end

        _cls.new_via_open_IO open_IO
      end

      # ~ (( BEGIN :+#experiment a callable undifferentiated base actr [tr]

      def receive_call_when_curry_ x_a, & x_p

        # :+#experiment: call on an undifferentiated base actor. by [tr]

        st = Callback_::Polymorphic_Stream.via_array x_a
        if :up_or_down != st.current_token
          raise ::ArgumentError, "required first term: `up_or_down`"
        end
        st.advance_one
        send :"__call_for__#{ st.gets_one }__", st, & x_p
      end

      def __call_for__up__ st, & x_p

        _call_this_guy Normalizations_::Upstream_IO, st, & x_p
      end

      def __call_for__down__ st, & x_p

        _call_this_guy Normalizations_::Downstream_IO, st, & x_p
      end

      def _call_this_guy cls, st, & oes_p

        ivars = instance_variables
        me = self
        ok = false

        o = cls.begin_ nil  # :+#would-change-class
        o.instance_exec do

          ivars.each do | ivar |
            instance_variable_set ivar, me.instance_variable_get( ivar )
          end

          if oes_p
            @on_event_selectively = oes_p
          end

          ok = process_polymorphic_stream_fully st
        end

        ok && o.execute
      end

      # ~ END ))

      def __receive_call_when_editing x_a, & oes_p

        kp = process_iambic_fully_ x_a, & oes_p
        if kp
          execute
        else
          kp
        end
      end

      def process_iambic_fully_ x_a, & oes_p  # ssume we are in "edit" state

        if oes_p
          @on_event_selectively = oes_p
        end

        process_iambic_fully x_a
      end

    private

      def path=
        _accept_path gets_one_polymorphic_value
      end

      def path_arg=
        @path_arg = gets_one_polymorphic_value
        @path_arg_was_explicit_ = true
        KEEP_PARSING_
      end

      def recognize_common_string_patterns=
        @do_recognize_common_string_patterns_ = true  # #note-01
        KEEP_PARSING_
      end

      def _accept_path path

        if path
          @path_arg = Callback_::Qualified_Knownness.via_x_and_i path, :path
        else
          self._COVER_ME
          @path_arg = Callback_::Known::UNKNOWN
        end

        KEEP_PARSING_
      end

      # ~ support for the commonest `execute`s

      def init_exception_and_open_IO_ mode_d

        @open_IO_ = @filesystem.open path_, mode_d
          # :#open-filehandle-1 - don't loose track
        @exception_ = nil
        NIL_

      rescue ::SystemCallError => @exception_  # Errno::EISDIR, Errno::ENOENT etc

        @open_IO_ = false
        NIL_
      end

      def init_exception_and_stat_ path

        # :+[#021] (common maneuver). see [#.I]: there is no locking here.

        @stat_ = @filesystem.stat path
        @exception_ = nil
        ACHIEVED_
      rescue ::Errno::ENOENT, Errno::ENOTDIR => @exception_  # #todo assimilate the others
        @stat_ = UNABLE_
        UNABLE_
      end

      # ~ feature: recognize conventional shorthands

      def via_path_arg_match_common_pattern_

        RX___.match path_
      end

      RX___ = /\A (?:
        (?<integer>\d) (?=>\z) |
        (?<dash>-) \z
      ) /x

      def via_common_pattern_match_ md

        if md[ :dash ]
          send :"when__#{ @dash_means_ }__by_way_of_dash"
        else
          d_s = md[ :integer ]
          if d_s
            via_system_resource_identifier_ d_s.to_i
          else
            self.via_matchdata_ md
          end
        end
      end

      def when_invalid_system_resource_identifier_ d, * expecting

        same = :invalid_system_resource_identifier

        maybe_send_event :error, same do

          build_not_OK_event_with( same,

            :actual_value, d,
            :expecting_values, expecting,
            :which_stream, which_stream_

          ) do | y, o |

            _s_a = o.expecting_values.map( & method( :val ) )

            y << "system resource identifier for #{ o.which_stream } #{
              }cannot be #{ ick o.actual_value }, it must be #{
                }#{ or_ _s_a }."
          end
        end
        UNABLE_
      end

      # ~

      def build_wrong_ftype_event_ path, stat, expected_ftype_s

        build_not_OK_event_with(
          :wrong_ftype,
          :actual_ftype, stat.ftype,
          :expected_ftype, expected_ftype_s,
          :path, path,

        ) do | y, o |

          y << "#{ pth o.path } exists but is not #{
           }#{ indefinite_noun o.expected_ftype }, #{
            }it is #{ indefinite_noun o.actual_ftype }"
        end
      end

      # ~ support

      def maybe_emit_missing_required_properties_event_

        maybe_send_event :error, :missing_required_properties do

          build_missing_required_properties_event_
        end
      end

      def wrap_exception_ e, * xtra

        Callback_::Event.wrap.exception e, :path_hack,
          :event_property, :path_arg, @path_arg, * xtra
      end

      def produce_result_via_open_IO_ io

        Callback_::Known.new_known io
      end

      def path_
        @path_arg.value_x
      end

      Callback_::Event.selective_builder_sender_receiver self

    end
  end
end
