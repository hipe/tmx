require_relative 'test-support'

module ::Skylab::TestSupport::TestSupport::Quickie
  ::Skylab::TestSupport::TestSupport[ Quickie_TestSupport = self ]

  include CONSTANTS

  Quickie = TestSupport::Quickie

  extend Quickie  # NOTE the *second* this gives you any grief,
  # just use rspec! Gödel would have something to say about this..
  # How we'll do it is try to build up to each more complex thing..
  #
  # (oh, actually, fuck we can't use rspec..)

  Emission = ::Struct.new :type, :txt, :count

  # OMG ick - remember how we are (necessarily) avoiding trampling on
  # RSpec's `should`? well in the below tests we want to (where
  # appropriate) *always* use our own `should` and not ::Rspec's,
  # because that is what we are testing!  (er, this is relevant b.c
  # sometimes we might use rspec to run the below tests, and in those
  # cases Quickie avoids hacking the Kernel)

  ::Kernel.module_exec do
    def shld predicate
      predicate.match self
    end
  end

  describe "#{ TestSupport }::Quickie" do

    last_id = 0

    let :context do
      ctx = Quickie_TestSupport.const_set "CTX_#{ last_id += 1 }",
        ( ::Class.new Quickie::Context )
      desc_a = [ "desc xyzzy #{ last_id }" ]
      Quickie::FUN.context_init[ ctx, desc_a, nil, -> { } ]
      ctx.new runtime
    end

    let :runtime do
      Quickie::Runtime.new( -> passed_func do
        add_output Emission.new( :pass, passed_func[] )
      end, -> fail_msg, failed_eg_count do
        add_output Emission.new( :fail, fail_msg, failed_eg_count )
      end, -> do  # pended
        add_output Emission.new( :pend )
      end )
    end

    def add_output e
      if do_debug
        $stderr.puts "GOT OUTPUT: #{ e.inspect }"
      end
      ( @output ||= [ ] ) << e
    end

    attr_reader :output

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    context "predicates, in context" do

      context "eql( )" do

        -> do
          exp = 'equals 1'

          it "when equal - passes - msg looks like: #{ exp }" do
            context.instance_exec do
              1.shld eql( 1 )
            end
            1 == output.length or fail "eql() emitted wrong number of emissions"
            :pass == output.last.type or fail "eql() did not pass."
            exp == output.last.txt or fail "eql did not render."
          end
        end.call

        -> do
          exp = 'expected 2, got 1'

          it "when not equal - fails - msg looks like: #{ exp }" do
            context.instance_exec do
              1.shld eql( 2 )
            end
            1 == output.length or fail "eql() emitted wrong number of emissons"
            :fail == output.last.type or fail "eql() did not fail, should have"
            exp == output.last.txt or fail "eql() msg is wrong"
          end
        end.call
      end

      def expect_output pass_fail, exp
        o = output
        o.length.should eql( 1 )
        o.last.type.should eql( pass_fail )
        o.last.txt.should eql( exp )
      end

      context "match( )" do

        -> do
          exp = "matches /\\Abeef.+boqueef/i"
          it "when matches - passes - msg looks like: #{ exp }" do
            context.instance_exec do
              'BEEFUS BOQUEEFUS'.shld match( /\Abeef.+boqueef/i )
            end
            expect_output :pass, exp
          end
        end.call

        -> do
          exp = 'expected /bar/, had "foo"'
          it "when not matches - fails - msg looks like: #{ exp }" do
            context.instance_exec do
              'foo'.shld match( /bar/ )
            end
            expect_output :fail, exp
          end
        end.call
      end

      context "raise_error( )" do

        -> do
          exp = "raises RuntimeError matching (?-mix:\\Ahelf\\z)"
          it "when (<class>, <rx>) and both ok - passes - msg is: #{ exp }" do
            context.instance_exec do
              -> do
                raise 'helf'
              end.shld raise_error( ::RuntimeError, 'helf' )
            end
            expect_output :pass, exp
          end
        end.call

        -> do
          exp = 'expected NoMemoryError, had RuntimeError'
          it "when (<class>, <rx>) and wrong class - fails - msg is: #{ exp }" do
            context.instance_exec do
              -> do
                raise 'helf'
              end.shld raise_error( ::NoMemoryError, 'helf' )
            end
            expect_output :fail, exp
          end
        end.call

        -> do
          exp = "expected helf to match (?-mix:dinglebat)"
          it "when (<class>, <rx>) and wrong msg - fails - msg is: #{ exp }" do
            context.instance_exec do
              -> do
                raise 'helf'
              end.shld raise_error( ::RuntimeError, /dinglebat/ )
            end
            expect_output :fail, exp
          end
        end.call

        -> do
          exp = "expected lambda to raise, didn't raise anything."
          it "when (<string>) and nothing is raised - fails - msg is: #{exp}" do
            context.instance_exec do
              -> do
                # nothing
              end.shld raise_error( 'wankerberries' )
            end
            expect_output :fail, exp
          end
        end.call

        -> do
          exp = "expected lambda to raise, didn't raise anything."
          it "when (<rx>) and nothing is raised - fails - msg is #{ exp }" do
            context.instance_exec do
              -> do
                # nothing
              end.shld raise_error( /wondertard/ )
            end
            expect_output :fail, exp
          end
        end.call
      end
    end
  end
end
