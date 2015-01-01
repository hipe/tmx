module Skylab::TanMan

  module Models_::Internal_

    Actions = ::Module.new

    class Paths

      # reminder: there is no magic here, no API affiliations. this is just
      # a plain old actor implementing an action internally whose surface
      # form is a proc with corresponding parameters as the below four.

      Callback_::Actor.call self, :properties,

        :path_i,
        :verb_i,
        :call

      Brazen_.event.selective_builder_sender_receiver self

      def execute
        case @verb_i
        when :retrieve
          retrieve
        else
          when_bad_verb
        end
      end

      def retrieve
        m = :"retrieve_#{ @path_i }_path"
        if respond_to? m
          send m
        else
          when_bad_noun
        end
      end

      def when_bad_verb
        @call.maybe_receive_event :error, :unrecognized_verb do
          build_not_OK_event_with :unrecognized_verb, :verb_i, @verb_i
        end
      end

      def when_bad_noun
        @call.maybe_receive_event :error, :unknown_path do
          build_not_OK_event_with :unknown_path, :path_i, @path_i
        end
      end

      def retrieve_generated_grammar_dir_path
        td = Memoized_GGD_tmpdir__[]
        td ||= Memoize_GGD_tmpdir__[ build_GGD_tmpdir ]
        td and td.to_path
      end

      -> do
        _TMPDIR = nil
        Memoized_GGD_tmpdir__ = -> { _TMPDIR }
        Memoize_GGD_tmpdir__ = -> tmpdir do
          _TMPDIR = tmpdir
        end
      end.call

      def build_GGD_tmpdir

        _app_tmpdir_path = app_tmpdir_path

        valid_arg = TanMan_.lib_.system.filesystem.normalization.existent_directory(
          :path, _app_tmpdir_path,
          :create_if_not_exist,
          :max_mkdirs, 1  # you may make the [tm] directory only.
        ) do | * i_a, & ev_p |
          maybe_receive_event_via_channel i_a do
            _ev = ev_p[]
            _ev.with_message_string_mapper MSG_MAP__
          end
          UNABLE_  # info events won't ride all the way out only errors
        end

        valid_arg and valid_arg.value_x

      end

      MSG_MAP__ = -> s, line_index, * do
        if line_index.zero?
          "#{ highlight 'while resolving [tm] generated grammar dir' }: #{ s }"
        else
          s
        end
      end

      def app_tmpdir_path
        lib = TanMan_::Lib_

        _tmpdir_head_pathname = lib::System[].defaults.dev_tmpdir_pathname
        _stem = lib::Tmpdir_stem[]

        _tmpdir_head_pathname.join( _stem ).to_path
      end
    end
  end
end
