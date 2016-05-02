module Skylab::System
  # -
    class Services___::Grep  # [#017] (presently no content in document)

      PARAMS___ = Attributes_actor_.call( self,
        do_ignore_case: [ :known_known, :optional ],
        freeform_options: :optional,
        grep_extended_regexp_string: :optional,
        ignore_case: [ :flag_of, :do_ignore_case, :optional, ],
        path: [ :singular_of, :paths, :optional, ],
        paths: :optional,
        ruby_regexp: :optional,
      )

      class << self

        def for_mutable_args_ x_a, & oes_p
          o = new( & oes_p )
          o.__init_via_iambic x_a
          o.execute
        end

        private :new
      end  # >>

      def initialize & p

        @system_conduit = Home_.lib_.open3  # etc

        @_any_oes_p = p
      end

      def __init_via_iambic x_a
        PARAMS___.init self, x_a
        NIL_
      end

      # -- normalization of state

      def execute
        _ok = ___resolve_regexp
        _ok && freeze
      end

      def ___resolve_regexp

        if @grep_extended_regexp_string
          __resolve_regexp_via_egrep_string
        else
          ___resolve_regexp_via_ruby_regexp
        end
      end

      def ___resolve_regexp_via_ruby_regexp

          opts = Home_.lib_.basic::Regexp.options_via_regexp @ruby_regexp
          xtra_i_a = nil
          if opts.is_multiline
            ( xtra_i_a ||= [] ).push :MULTILINE
          end
          if opts.is_extended
            ( xtra_i_a ||= [] ).push :EXTENDED
          end

        if xtra_i_a
          ___when_no_support_for_ruby_regexp_options xtra_i_a.freeze
        else

          if ! @do_ignore_case
            @do_ignore_case = Callback_::Known_Known[ opts.is_ignorecase ]
          end

          @_use_as_grep_extended_regexp = @ruby_regexp.source
          ACHIEVED_
        end
      end

      def ___when_no_support_for_ruby_regexp_options i_a

        p = @_any_oes_p
        if p
          p.call :error, :regexp_option_not_supported do

            Callback_::Event.inline_not_OK_with(
              :non_convertible_regexp_options,
              :option_symbols, i_a,
              :regexp, @ruby_regexp,
            )
          end
        end
        UNABLE_
      end

      def __resolve_regexp_via_egrep_string

        if ! @do_ignore_case
          @do_ignore_case = Callback_::Known_Known[ false ]  # ..
        end

        s = @grep_extended_regexp_string

        if s
          @_use_as_grep_extended_regexp = s
          ACHIEVED_
        else
          s
        end
      end

      # -- command building & execution

      def to_output_line_content_stream

        cmd = to_command
        if cmd
          line_content_stream_via_command cmd
        else
          cmd
        end
      end

      def to_command_string
        _of_command :command_string
      end

      def to_command_tokens
        _of_command :command_tokens
      end

      def _of_command m
        cmd = to_command
        if cmd
          cmd.send m
        else
          cmd
        end
      end

      def to_command

        cmd = Home_::Command.begin

        cmd.push GREP___, E_OPTION___

        if @do_ignore_case.value_x
          cmd.push IGNORE_CASE_OPTION__
        end

        a = @freeform_options
        if a
          cmd.concat a
        end

        cmd.push @_use_as_grep_extended_regexp

        a_ = @paths
        if a_
          cmd.concat a_
        end

        cmd.close
      end

      E_OPTION___ = '-E'.freeze
      GREP___ = 'grep'.freeze
      IGNORE_CASE_OPTION__ = '--ignore-case'.freeze

      def line_content_stream_via_command cmd

        _tokens = cmd.command_tokens ; cmd = nil

        _Stream = Callback_::Stream
        thread = nil

        _resource_releaser = _Stream::Resource_Releaser.new do
          if thread && thread.alive?
            thread.exit
          end
          ACHIEVED_
        end

        p = -> do

          _, o, e, thread = @system_conduit.popen3( * _tokens )

          main_p = -> do
            s = o.gets
            if s
              s.chop!
              s
            else
              p = -> { s }
              s
            end
          end

          err_s = e.gets
          if err_s && err_s.length.nonzero?
            o.close
            p = -> { UNABLE_ }
            ___when_system_error err_s
          else
            p = main_p
            p[]
          end
        end

        _Stream.new _resource_releaser do
          p[]
        end
      end

      def ___when_system_error err_s

        p = @_any_oes_p
        if p
          p.call :error, :system_call_error do
            Callback_::Event.inline_not_OK_with :system_call_error,
              :message, err_s, :error_category, :system_call_error
          end
        end
        UNABLE_
      end
    end
  # -
end
