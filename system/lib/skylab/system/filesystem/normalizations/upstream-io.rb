module Skylab::System

  module Filesystem

    class Normalizations::Upstream_IO < Normalizations::PathBased  # [#004.B].
    private

      def initialize

        @_neither_is_OK = false
        @_only_apply_ftype_expectation = false
        @_stdin = nil
        @_value_is_pathname = false
        super
      end

      def need_mutable_not_immutable=
        @need_mutable_not_immutable_ = gets_one
        KEEP_PARSING_
      end

      def do_lock_file=
        @do_lock_file_ = gets_one
        KEEP_PARSING_
      end

      def dash_means=
        @dash_means_ = gets_one
        KEEP_PARSING_
      end

      def neither_is_OK=

        # first, see [#here.E]. normally in the absence of the 2 things the
        # result is a failure to normalize. however IFF subject flag is
        # engaged we result with the unknown knownness singleton so that
        # presumably the client will take some other course of action.

        @_neither_is_OK = true
        KEEP_PARSING_
      end

      def must_be_ftype=

        x = gets_one
        if x.respond_to? :id2name
          x = Home_::Filesystem.const_get x, false
        end

        @_expected_ftype = x
        @_only_apply_ftype_expectation = true
        KEEP_PARSING_
      end

      def stat=  # used #here
        @stat_ = gets_one
        KEEP_PARSING_
      end

      def stdin=
        @_stdin = gets_one
        KEEP_PARSING_
      end

    public

      def execute

        # implement [#here.A] the common algorithm (see)

        pa = @qualified_knownness_of_path

        if pa && pa.is_known_known

          if @do_recognize_common_string_patterns_
            md_x = via_path_arg_match_common_pattern_
          end

          path_arg_represents_file = ! md_x
        end

        if md_x
          via_common_pattern_match_ md_x
        else
          io = @_stdin
          if io && ! ( io.tty? || io.closed? )

            if path_arg_represents_file
              __when_both
            else
              produce_result_via_open_IO_ io
            end
          elsif path_arg_represents_file

            via_path_arg_that_represents_file_

          elsif @_neither_is_OK

            Common_::KNOWN_UNKNOWN
          else
            maybe_emit_missing_required_properties_event_
          end
        end
      end

      def when__stdin__by_way_of_dash

        io = @_stdin
        if io.tty?  # for now ..
          @listener.call :error, :expression, :interactive_stdin do | y |
            y << "STDIN is interactive. must be non-interactive"
          end
          UNABLE_
        else
          produce_result_via_open_IO_ @_stdin
        end
      end

      def __when_both

        @listener.call :error, :ambiguous_upstream_arguments do
          __build_ambiguous_upstream_arguments_event
        end
        UNABLE_
      end

      def __build_ambiguous_upstream_arguments_event

        build_not_OK_event_with(
          :ambiguous_upstream_arguments,
          :qualified_knownness_of_path, @qualified_knownness_of_path,

        ) do | y, o |

          y << "ambiguous upstream arguments - cannot read from both #{
            }STDIN and #{ par o.qualified_knownness_of_path.association }"
        end
      end

      def build_missing_required_properties_event_

        if @_stdin
          both = true
        end

        build_not_OK_event_with(
          :missing_required_properties,
          :path_property, @qualified_knownness_of_path.association,
          :for_both, both,

        ) do | y, o |

          if o.for_both
            y << "expecting #{ par o.path_property } or STDIN"
          else
            y << "expecting #{ par o.path_property }"
          end
        end
      end

      def via_path_arg_that_represents_file_

        if @do_lock_file_
          init_exception_and_locked_file_ path_
          if @locked_IO_
            Common_::Known_Known[ remove_instance_variable :@locked_IO_ ]
          else
            _when_exception
          end
        else
          init_exception_and_stat_ path_
          if @stat_
            via_stat_execute
          else
            _when_exception
          end
        end
      end

      def _when_exception

          @listener.call :error, :stat_error do
            wrap_exception_ @exception_
          end

          UNABLE_  # result of above is unreliable
      end

      public def via_stat_execute  # :+#public-API, :#here

        if @_only_apply_ftype_expectation

          __via_stat_and_expected_ftype_exert_expectation

        elsif FILE_FTYPE == @stat_.ftype
          __via_file

        else
          @listener.call :error, :wrong_ftype do
            build_wrong_ftype_event_ path_, @stat_, FILE_FTYPE
          end
          UNABLE_  # result of above is unreliable
        end
      end

      def __via_stat_and_expected_ftype_exert_expectation

        if @_expected_ftype == @stat_.ftype

          Common_::Known_Known[ ACHIEVED_ ]
        else
          @listener.call :error, :wrong_ftype do
            build_wrong_ftype_event_ path_, @stat_, @_expected_ftype
          end
          UNABLE_
        end
      end

      def __via_file

        _mode = if @need_mutable_not_immutable_
          self._COVER_ME__probably_fine__
          ::File::RDWR
        else
          ::File::RDONLY
        end

        init_exception_and_open_IO_ _mode

        if @open_IO_
          produce_result_via_open_IO_ remove_instance_variable :@open_IO_
        else
          @listener.call :error, :exception do
            wrap_exception_ @exception_
          end
          UNABLE_
        end
      end

      def wrap_exception_ e

        if @path_arg_was_explicit_

          _xtra = [

            :search_and_replace_hack,

            %r(\bfile or directory\b),

            -> o do
              par o.qualified_knownness_of_path.association
            end,
          ]
        end

        super e, * _xtra
      end

      def which_stream_
        :upstream
      end
    end
  end
end
