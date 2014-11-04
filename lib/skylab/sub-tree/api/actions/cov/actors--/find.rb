module Skylab::SubTree

  SubTree::Library_::Shellwords.class  # #kick

  class API::Actions::Cov

    class Actors__::Find  # :+[#hl-171] first scan-based implementation

      Callback_::Actor.call self, :properties,
        :path,
        :selective_listener

      def execute
        ok = normalize
        ok &&= rslv_command
        ok && via_command_execute
      end

    private

      def normalize
        @path && TEST_DIR_NAME_A_.length.nonzero?
      end

      def rslv_command
        _o_parts = TEST_DIR_NAME_A_.map do |s|
          "-name #{ s.shellescape }"
        end
        _o = _o_parts * ' -o '
        @command_s = "find #{ @path.shellescape } -type dir \\( #{ _o } \\)"
        @selective_listener.maybe_receive_event :info, :find_command do
          build_find_command_event
        end
        PROCEDE_
      end

      def build_find_command_event

        SubTree_::Lib_::Event_lib[].inline_with :find_command,
            :find_command_string, @command_s,
            :ok, nil do |y, o|

          y << "generated `find` command: #{ o.find_command_string }"
        end
      end

      def via_command_execute
        p = -> do
          _, sout, serr = SubTree::Library_::Open3.popen3 @command_s
          error_s = serr.read
          if error_s.length.zero?
            p = -> do
              x = sout.gets
              if x
                x.chomp!
                x = ::Pathname.new x  # #experimental
              else
                p  = EMPTY_P_
              end
              x
            end
            p.call
          else
            maybe_send_error_via_find_error_string error_s
            p = -> { UNABLE_ }
            UNABLE_
          end
        end
        Callback_.scan do
          p[]
        end
      end

      def maybe_send_error_via_find_error_string error_s
        @selective_listener.maybe_receive_event :error, :find_error do
          SubTree_::Lib_::Event_lib[].inline_with :find_error,
            :message, error_s, :ok, false
        end ; nil
      end
    end
  end
end
