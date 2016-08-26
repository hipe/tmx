require_relative 'test-support'

module Skylab::TestSupport::TestSupport

  # the bootstrapping problem here is obvious. Gödel would have
  # something to say about this..

  # ordinarily, if r.s has been loaded by the time the subject loads,
  # it in effect disables itself. however in the below tests we want
  # always to be testing against our own `should` method and not that
  # of r.s. to this end we instead make this method called `shld` and
  # that is what we test against. in this manner you can use r.s to
  # run these tests (or the subject if the subject isn't broken.)

  ::Kernel.module_exec do
    def shld predicate
      predicate.matches? self
    end
  end

  describe "[ts] quickie" do

    TS_[ self ]

    last_id = 0

    let :context do

      o = _subject_module

      ctx = ::Class.new o::Context__

      TS_.const_set "X_Q_CTX_#{ last_id += 1 }", ctx

      _desc_a = [ "desc xyzizzy #{ last_id }" ]

      o::Init_context__[ ctx, _desc_a, nil, Home_::EMPTY_P_ ]

      ctx.new runtime
    end

    _Emission = ::Struct.new :type, :txt, :count

    X_Q_Emission = _Emission

    let :runtime do

      _pass = -> & msg do
        add_output _Emission.new( :pass, msg[] )
      end

      _fail = -> failed_eg_count, & msg do
        add_output _Emission.new( :fail, msg[], failed_eg_count )
      end

      _pend = -> do
        add_output _Emission.new :pend
      end

      _subject_module::Runtime__.new _pass, _fail, _pend
    end

    def add_output e

      if do_debug
        debug_IO.puts "GOT OUTPUT: #{ e.inspect }"
      end

      ( @output ||= [ ] ) << e
    end

    attr_reader :output

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

    def _subject_module
      Home_::Quickie
    end
  end
end
