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

        mutable = _cls.allocate

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
        kn and kn.value_x  # part of the deal is the convenience of this
      end

      def _accept_path path

        if path
          @qualified_knownness_of_path = Common_::Qualified_Knownness.via_value_and_symbol path, :path
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
        @do_recognize_common_string_patterns_ = true  # #note-01
        KEEP_PARSING_
      end





  private

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

      # ~ #[#021] (both branches) a common maneuver..

      def init_exception_and_locked_file_ path

        io = @filesystem.open path, ::File::RDONLY

        # this spot between the above line and the below line is the
        # subject of [#004.I] (the atomicity of all things)

        d = io.flock ::File::LOCK_EX | ::File::LOCK_NB
        if d.zero?
          @exception_ = nil
          @locked_IO_ = io ; ACHIEVED_
        else
          self._COVER_ME__failed_to_acquire_lock__  # alas it is but a sketch
        end
      rescue ::Errno::ENOENT, Errno::ENOTDIR => @exception_
        @stat_ = UNABLE_ ; UNABLE_
      end

      def init_exception_and_stat_ path

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

        ) do | y, o |

          y << "#{ pth o.path } exists but is not #{
           }#{ indefinite_noun o.expected_ftype }, #{
            }it is #{ indefinite_noun o.actual_ftype }"
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

        Common_::Event.wrap.exception e, :path_hack,
          :event_property, :qualified_knownness_of_path, @qualified_knownness_of_path, * xtra
      end

      def produce_result_via_open_IO_ io

        Common_::Known_Known[ io ]
      end

      def path_
        @qualified_knownness_of_path.value_x
      end

      include Common_::Event::ReceiveAndSendMethods

      Sibling__ = Normalizations
    end
  end
end
