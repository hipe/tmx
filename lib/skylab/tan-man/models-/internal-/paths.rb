module Skylab::TanMan

  module Models_::Internal_

    class Paths

      Callback_::Actor.call self, :properties,

        :path_i, :verb_i, :call

      Brazen_.event.sender self

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
        _ev = build_not_OK_event_with :unrecognized_verb, :verb_i, @verb_i
        @call.event_receiver.receive_event _ev
      end

      def when_bad_noun
        _ev = build_not_OK_event_with :unknown_path, :path_i, @path_i
        @call.event_receiver.receive_event _ev
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

        TanMan_::Lib_::System[].filesystem.normalization.existent_directory(
          :path, _app_tmpdir_path,
          :on_event, -> ev do
            ev = ev.with_message_string_mapper MSG_MAP__
            @call.event_receiver.receive_event ev
            UNABLE_  # info events won't ride all the way out
          end,
          :create_if_not_exist,
          :max_mkdirs, 1 )  # you may make the [tm] directory only.
      end

      MSG_MAP__ = -> s do
        "#{ highlight 'while resolving [tm] generated grammar dir' }: #{ s }"
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
