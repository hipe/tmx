module Skylab::System

  module Filesystem

    class Normalizations::PathBased  # read [#004.G] near states

      Attributes_actor_[ self ]

      class << self

        # ~ make a prototype (then typically it is called with #here1)

        def with( * )
          super.freeze
        end

        # ~

        private :new  # all n11ns must now use "attributes actor" constuctors/callers
      end  # >>

      def initialize & l
        if l
          @listener = l
        end
        @do_lock_file_ = false
        @do_recognize_common_string_patterns_ = false
        @need_mutable_not_immutable_ = nil
        @path_arg_was_explicit_ = false
      end

      # -- this crazy thing: an experiment:
      #    you have a prototype that is un-differentiated. then you
      #    [#sl-023] dup-and-mutate WHILE (in effect) changing the class.
      #    :[#008.3]: #borrow-coverage from [tr]

      def via * a, & p

        frozen? || self._SANITY__this_should_always_be_called_by_a_prototype__

        scn = Scanner_[ a ]

        if :up_or_down != scn.head_as_is
          self._COVER_ME__fine_but_where__
        end

        scn.advance_one
        _cls = case scn.head_as_is
        when :down
          Sibling__::Downstream_IO
        when :up
          Sibling__::Upstream_IO
        else
          raise ::NameError, scn.head_as_is
        end
        scn.advance_one

        mutable = _cls.new_for_crazy_class_change_experiment_

        instance_variables.each do |ivar|
          mutable.instance_variable_set ivar, instance_variable_get( ivar )
        end

        _ok = mutable.send :process_argument_scanner_fully, scn, & p

        _ok && mutable.execute
      end

      def byte_whichstream_identifier_for x, up_or_down  # 1x [tr] only (part of above

        case up_or_down
        when :down
          Home_::IO::ByteDownstreamReference.via_open_IO x
        when :up
          Home_::IO::ByteUpstreamReference.via_open_IO x
        else
          raise ::NameError, up_or_down
        end
      end

      # --

      def against_path path, & p  # :#here1
        frozen? || self._WHERE
        dup.__against_path p, path
      end

      def __against_path p, path
        # assume [#sl-023] "dup and mutate" pattern
        _accept_path path
        if p
          @listener = p
        else
          # (#cov1.1 but might be #feature-island to use a listener in a prototype)
        end
        kn = execute
        kn and kn.value  # part of the deal is the convenience of this
      end

      def _accept_path path

        if path
          @qualified_knownness_of_path = Common_::QualifiedKnownKnown.via_value_and_symbol path, :path
          KEEP_PARSING_
        else
          self._COVER_ME_path_argument_was_falseish
        end
      end

    private

      def filesystem=
        # all path-based n11ns support providing your own filesystem
        @filesystem = gets_one
        KEEP_PARSING_
      end

      def path=
        _accept_path gets_one
      end

      def qualified_knownness_of_path=
        @qualified_knownness_of_path = gets_one
        @path_arg_was_explicit_ = true
        KEEP_PARSING_
      end

      def recognize_common_string_patterns=
        @do_recognize_common_string_patterns_ = true  # [#here.B]
        KEEP_PARSING_
      end

  private

      # ~ support for the commonest `execute`s

      # ~ #[#021] (both branches) a common maneuver..

      def resolve_locked_open_IO_ mode

        if resolve_non_locked_open_IO_ mode

          # these moments between when the filehandle is opened in the above
          # call and when we lock it below is the subject of [#004.9] (the
          # atomicity of all things)

          __lock_that_IO_PB
        end
      end

      def __lock_that_IO_PB

        io = remove_instance_variable :@non_locked_open_IO_
        d = io.flock ::File::LOCK_EX | ::File::LOCK_NB
        if d && d.zero?
          @locked_open_IO_ = io ; ACHIEVED_
        else
          io.close
          raise __say_locked_out
          # (hard/annoying to cover, but this happens in development)
        end
      end

      def __say_locked_out
        "can't aquire exclusive nonblocking lock (file already locked?) - #{ path_ }"
      end

      def resolve_non_locked_open_IO_ mode

        _path = path_  # hi.

        @non_locked_open_IO_ = @filesystem.open _path, mode
          # :#open-filehandle-1 - don't loose track
        ACHIEVED_
      rescue ::Errno::EEXIST => @exception_
        UNABLE_  # hi.
      rescue ::Errno::EISDIR => @exception_
        UNABLE_  # hi.
      rescue ::Errno::ENOENT => @exception_
        UNABLE_  # hi.
      rescue ::Errno::ENOTDIR => @exception_
        UNABLE_  # hi.
      end

      # ~

      def resolve_stat_
        _path = path_  # hi.
        resolve_stat_via_path_ _path
      end

      def resolve_stat_via_path_ path
        @stat_ = @filesystem.stat path
        ACHIEVED_
      rescue ::Errno::ENOENT, Errno::ENOTDIR => @exception_  # #todo assimilate the others
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

        @listener.call :error, same do

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

        ) do |y, o|

          buffer = "#{ pth o.path } exists but is not "

          simple_inflection do
            write_count_for_inflection 1
            buffer << indef( o.expected_ftype )
            buffer << ", it is "
            buffer << indef( o.actual_ftype )
          end

          y << buffer
        end
      end

      # ~ support

      def maybe_emit_missing_required_properties_event_

        @listener.call :error, :missing_required_properties do

          build_missing_required_properties_event_
        end
        UNABLE_
      end

      def wrap_exception_ e, * xtra

        Common_::Event::Via_exception.via(
          :exception, e,
          :path_hack,
          :event_property, :qualified_knownness_of_path, @qualified_knownness_of_path,
          * xtra )
      end

      def produce_result_via_open_IO_ io

        Common_::KnownKnown[ io ]
      end

      def path_
        @qualified_knownness_of_path.value
      end

      include Common_::Event::ReceiveAndSendMethods

      Sibling__ = Normalizations
    end
  end
end
