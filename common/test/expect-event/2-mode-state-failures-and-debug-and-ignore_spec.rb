require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] expect event - (2) mode state failure, debug, ignore" do

    TS_.etc_ self
    use :expect_event_meta
    use :expect_event

    it "mode-state failure - you can't set an option after the first emission" do

      send_potential_event_ :hi do
        :_no_see_
      end

      _expect_same_failure_by do
        @event_log.set_hash_of_terminal_channels_to_ignore Home_::EMPTY_H_
      end
    end

    it "mode-state failure - you can't emit after the first gets" do

      send_potential_event_ :hi do
        :_no_see_
      end

      _em = @event_log.gets

      :hi == _em.channel_symbol_array.fetch( 0 ) or fail

      _expect_same_failure_by do
        send_potential_event_ :hi do
          :_no_see_
        end
      end
    end

    def _expect_same_failure_by

      begin
        yield
      rescue ::NoMethodError => e
      end

      e.message.should eql "undefined method `[]' for nil:NilClass"
    end

    context "the ignore option" do

      it "ignore all events whose terminal channels are in a particular set" do

        _this_same_ignoration_test
      end

      attr_reader :_hash_of_terminal_channels_for_expev_to_ignore  # 1 of 2
    end

    context "when `do_debug` is on" do

      # (no you can't turn debugging on for these..)

      it "when not expression, reports channel and expresses event" do

        ev = -> y, expag do
          expag.calculate do
            y << "fake event #{ highlight 'hello' }"
          end
        end
        ev.singleton_class.send :alias_method, :express_into_under, :call

        send_potential_event_ :x, :wazoo_wee do
          ev
        end

        @debug_IO.string == "[:x, :wazoo_wee] fake event ** hello **\n" or fail

        _em = @event_log.gets

        _em.channel_symbol_array.fetch( 1 ) == :wazoo_wee or fail
      end

      it "when expression, reports channel and expresses expression" do

        send_potential_event_ :x, :expression, :y do |y|
          y << "hello #{ highlight 'hi' }"
        end

        @debug_IO.string == "[:x, :expression, :y] hello ** hi **\n" or fail

        _em = @event_log.gets

        _em.channel_symbol_array == [ :x, :expression, :y ] or fail
      end

      def do_debug
        true
      end

      def debug_IO
        @debug_IO ||= Home_.lib_.string_IO.new
      end

      context "the ignore option" do

        it "when ignore AND debug is on, the ignoration is expressed" do

          _this_same_ignoration_test

          io = @debug_IO
          io.rewind
          io.gets == "[:event_ignored, :expression, :zizzo] (ignored this emission)\n" or fail
          io.gets == "[:zizzo, :expression, :zIZZo] ** zeez **\n" or fail  # not ignored
          io.gets == "[:event_ignored, :expression, :hi, :zizzo] (ignored this emission)\n" or fail
          io.gets and fail
        end

        attr_reader :_hash_of_terminal_channels_for_expev_to_ignore  # 2 of 2
      end
    end

    _IGNORE_ZIZZO = { zizzo: true }

    define_method :_this_same_ignoration_test do

      @_hash_of_terminal_channels_for_expev_to_ignore = _IGNORE_ZIZZO

      send_potential_event_ :zizzo do
        self._NEVER
      end

      send_potential_event_ :zizzo, :expression, :zIZZo do |y|
        y << highlight( 'zeez' )
      end

      send_potential_event_ :hi, :zizzo do
        self._NEVER
      end

      @event_log.gets.channel_symbol_array == [ :zizzo, :expression, :zIZZo ] or fail

      @event_log.gets and fail
    end
  end
end