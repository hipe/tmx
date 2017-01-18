module Skylab::System

  module Doubles::Stubbed_System

    class Snippet_Based  # :[#037].

      class << self

        alias_method :via_path, :new
        private :new
      end  # >>

      def initialize path

        @_lookup = :__parse_and_lookup
        @__path = path
      end

      def popen3 * cmd_x_a

        block_given? and self._NOT_SUPPORTED
        send @_lookup, cmd_x_a
      end

      def __parse_and_lookup cmd_x_a

        _path = remove_instance_variable :@__path
        _file_content = ::File.read _path

        _commands = ::Kernel.eval _file_content  # this is one of the only
        # times universe-wide that we think it's "OK" to use this method.


        h = {}
        _commands.each do |command|
          k = command.fetch :command
          command.delete :command  # makes parsing assertive
          h.key? k and self._COLLISION
          h[ k ] = command
        end

        @_h = h
        @_lookup = :_lookup
        _lookup cmd_x_a
      end

      def _lookup cmd_x_a

        opt_h = ::Hash.try_convert cmd_x_a.last
        if opt_h
          cmd_x_a.pop  # CAREFUL
        end

        Popen3_Result___.new( @_h.fetch cmd_x_a ).execute
      end

      # ==

      class Popen3_Result___

        def initialize h
          @__h = h
        end

        def execute

          @_stdout_proxy = nil
          @_stderr_proxy = nil

          @__h.each_pair do |k, x|
            send k, x
          end

          _sout = @_stdout_proxy || Stubbed_IO_for_Read_.the_empty_stream_
          _serr = @_stderr_proxy || Stubbed_IO_for_Read_.the_empty_stream_

          [ NOTHING_, _sout, _serr, @__wait ]
        end

        def stdout_lines a
          @_stdout_proxy = _stream_via_array a ; nil
        end

        def stderr_lines a
          @_stderr_proxy = _stream_via_array a ; nil
        end

        def _stream_via_array a

          Stubbed_IO_for_Read_.via_nonsparse_array a
        end

        def exitstatus d
          @__wait = Stubbed_Thread.new d ; nil
        end
      end
    end
  end
end
