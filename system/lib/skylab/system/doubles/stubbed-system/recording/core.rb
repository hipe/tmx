module Skylab::System

  module Doubles::Stubbed_System

    class Recording  # exacty [#036]

      class << self
        alias_method :via, :new
        undef_method :new
      end  # >>

      def initialize out, real_system

        @_rendering = Here_::Rendering_.new out
        @_use_this_expression_engine = :StreamBasedExpressionEngine___
        yield self
        @_rendering.become_finished__

        # --

        @__real_sysem = real_system
        @_receive_popen3 = :__receive_first_popen3
      end

      def cache_dont_stream
        @_use_this_expression_engine = :CacheBasedExpressionEngine___ ; nil
      end

      def holler_back s
        @_rendering.receive_holler_back__ s ; nil
      end

      def wrap_in_module * s_a
        @_rendering.receive_wrap_in_module__ s_a
      end

      def popen3 * argv
        send @_receive_popen3, argv
      end

      def __receive_first_popen3 argv
        _real_sys = remove_instance_variable :@__real_sysem
        _rendering = remove_instance_variable :@_rendering
        _engine_const = remove_instance_variable :@_use_this_expression_engine
        _engine_class = Here_.const_get _engine_const, false
        @_engine = _engine_class.new _rendering, _real_sys
        @_receive_popen3 = :__receive_subsequent_popen3
        @_engine.receive_first_popen3_ argv
      end

      def __receive_subsequent_popen3 argv
        @_engine.receive_subsequent_popen3_ argv
      end

      def receive_done
        @_engine.receive_done_
      end

      # ==

      class ReadStreamProxy_
        def initialize gets
          @gets = gets
        end
        def gets
          @gets.call
        end
      end

      class WaitProxy_
        def initialize read
          @read = read
        end
        def value
          self
        end
        def exitstatus
          @read.call
        end
      end

      # ==

      Here_ = self
    end
  end
end
# #history: renamed and rewritten after only one commit!
# #history: born as a blind rewrite of the other one
