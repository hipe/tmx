require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Client

  describe "[hl] CLI client" do

    extend TS__

    context "with a minimal, monadic app" do

      before :all do

        class Foo

          Headless::CLI::Client[ self, :DSL, :three_streams_notify ]

          def initialize i, o, e
            three_streams_notify i, o, e
            @parm_h = { }
            super()
          end

          option_parser do |o|
            o.on '-x', '--ex <wat-fun>', 'ohai' do |x|
              @parm_h[ :ex ] = x
            end
          end

          def wen_kel bar
            errstream.puts "«#{ bar } with #{ @parm_h.inspect }»"
            :yerp
          end
        end
      end

      def client_class
        Foo
      end

      it "ohai" do
        client
        @result = @client.invoke %w( wenkel biz )
        errstring.should eql "«biz with {}»\n"
        @result.should eql :yerp
      end

      it "infix (not trailing) option" do
        invoke %w( wen-kel -x bix biz )
        expect_same
      end

      it "trailing (not infix) option" do
        invoke %w( wen-kel biz -x bix )
        expect_same
      end

      def expect_same
        errstr.should eql '«biz with {:ex=>"bix"}»'
        @result.should eql :yerp
      end
    end

    def invoke * argv
      argv.flatten!
      @result = client.invoke argv ; nil
    end

    def client
      @client ||= client_class.new( * triad.to_a )
    end

    def triad
      @triad ||= begin
        t = TestSupport::IO::Spy::Triad.new
        do_debug and t.debug!
        t
      end
    end

    def errstring
      triad.errstream.string
    end

    def errstr
      errstring.strip
    end
  end
end
