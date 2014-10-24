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
        td.to_path
      end

      -> do
        _TMPDIR = nil
        Memoized_GGD_tmpdir__ = -> { _TMPDIR }
        Memoize_GGD_tmpdir__ = -> tmpdir do
          _TMPDIR = tmpdir
        end
      end.call

      def build_GGD_tmpdir
        resolve_GGD_tmpdir
        if ! @GGD_tmpdir.exist?   # :+[#hl-022] will get you
          @GGD_tmpdir.prepare_when_not_exist
        end
        @GGD_tmpdir
      end

      def resolve_GGD_tmpdir
        via_library_init_ivars
        _app_tmpdir_path = app_tmpdir_path
        _debug_IO_pxy = debug_IO_proxy

        @GGD_tmpdir = @filesystem.tmpdir :path, _app_tmpdir_path,
          :be_verbose, true,
          :debug_IO, _debug_IO_pxy,
          :max_mkdirs, 1
        nil
      end

      def via_library_init_ivars
        @lib = TanMan_::Lib_
        @sys = @lib::System[]
        @filesystem = @sys.filesystem
      end

      def app_tmpdir_path
        _tmpdir_head_pathname = @sys.defaults.dev_tmpdir_pathname
        _stem = @lib::Tmpdir_stem[]
        _tmpdir_head_pathname.join( _stem ).to_path
      end

      def debug_IO_proxy

        @lib::Proxy_lib[].inline :puts, -> s do

          _ev = Event_[].inline_with :tmpdir_message,
              :message_string, s do |y, o|

            y << "« while loading grammar » #{ o.message_string }"  # :+#guillemets
          end

          @call.event_receiver.receive_event _ev
        end
      end
    end
  end
end
