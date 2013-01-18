require_relative 'dsl/test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  # Quickie compatible. just load this file with `ruby -w` if you want

  describe "the #{ Headless }::CLI::Box::DSL - generated action instance" do
    extend DSL_TestSupport

    # ~ In this file we will be experimenting with some nerks: ~

    # ~ Part 1. Functions. ~      # these are nice because its easier at
                                  # a glance to see a function's dependencies

    memoize = -> func do
      use = -> do
        x = func.call             # actually call the client initializer
        use = -> { x }            # memoize the result for subsequent calls
        x
      end
      -> { use.call }
    end

    acts_class = -> const, nlam, block=nil do
      cls = DSL_TestSupport.const_set const, ::Class.new
      cls.class_exec do
        define_method :normalized_local_action_name do nlam end
        extend Headless::CLI::Box::DSL
        class_exec(& block ) if block
      end
      cls
    end

    build_acts = -> me, cls_func do
      spy = Headless_TestSupport::Client_Spy::CLI.new
      spy.normalized_invocation_string = 'myapp'
      spy.debug = -> { me.do_debug }
      ioa = spy.send :io_adapter
      acts = cls_func[].new spy
      me.ioa = ioa
      acts
    end

    _expect_names = -> me, ioa, *names do
      actual = ioa.emitted.map(& :name)
      actual.should me.eql( names )
      nil
    end

    _expect_strings = -> me, ioa, strings do
      strs = ioa.emitted.map(& :string)
      while str = strs.shift
        expecting = strings.shift or fail "unexpected string - #{ str }"
        if ::Regexp === expecting
          str.should me.match( expecting )
        else
          str.should me.eql( expecting )
        end
      end
      if strings.length.nonzero?
        fail "had no more strings, was expecting #{ strings.first.inspect }"
      end
      nil
    end

    # ~ Part 2. test DSL m.m's (if any) ~
                                  # they are more readable that `let`s

    def self.using cls_func
      let :cls_func do cls_func end
    end

    # ~ Part 3. i.m's that synthesize parts 1 & 2 ~
                                  # a tight little spaghetti bowl -- look!

    let :acts do
      build_acts[ self, cls_func ]
    end

    define_method :expect_strings do |*strings|
      _expect_strings[ self, ioa, strings ]
    end

    attr_accessor :ioa            # io_adapter

    def invoke *argv
      acts.invoke argv
    end

    # ~ Part 4. is the money ~

    usage_rx = /\Ausage: myapp acts-\d-\d \[action\] \[args \[\.\.\]\]\z/

    invite_rx = /\Ause myapp acts-\d-\d -h \[<action>\] for help\z/

    context "0. with nothing" do
      expecting_nothing_rx = /expecting \{\}/

      acts_0_0 = memoize[ -> do
        acts_class[ :Acts_0_0, 'acts-0-0' ]
      end ]

      using acts_0_0

      it "   0. nothing - error / usage / invite" do
        invoke
        _expect_names[ self, ioa, :error, :help, :help ]
        expect_strings expecting_nothing_rx, usage_rx, invite_rx
      end

      it " 1.1. funky action - jizz / jazz / other" do
        invoke 'jenkum'
        msg = ioa.emitted.first.string
        msg.should match( expecting_nothing_rx )
        msg.include?( 'there is no "jenkum" action.' ).should eql( true )
      end
    end

    context "1. with nothing but a method definition" do

      acts_1_0 = memoize[ -> do
        acts_class[ :Acts_1_0, 'acts-1-0', -> do
          def yowzaa
            emit :foofie, 'doofie'
            :koofie
          end
         end
        ]
      end ]

      expecting_rx = /expecting \{yowzaa\}/

      it "internally an action class is created - (..::Actions::Yowzaa)" do
        acts_1_0[]::Actions::Yowzaa # absence of exceptions means passing
      end

      using acts_1_0

      it "the action object itself gives an `option_parser` with a -h" do
        action = acts_1_0[]::Actions::Yowzaa.new acts
        op = action.send :option_parser # the action object has an option parser
        (!! op).should eql( true )
        op.top.list.length.should eql( 1 ) # which has only 1 element
        op.top.list.first.short.first.should eql( '-h' ) # which is '-h'
        op.parse '--hel'
        action.send( :queue ).should eql( nil )
        acts.send( :queue ).length.should eql( 1 )
        acts.send( :queue ).clear
      end

      it "  0. nothing - error / usage / invite" do
        invoke
        expect_strings 'expecting {yowzaa}', usage_rx, invite_rx
      end

      it "1.1. invalid action - e / u / i" do
        invoke 'nonsense'
        expect_strings(
          /there is no "nonsense" action. #{ expecting_rx.source }/,
          usage_rx, invite_rx )
      end

      it "1.2. invalid option - e / u / i" do
        invoke '-x'
        expect_strings 'invalid option: -x', usage_rx, invite_rx
      end

      _usage_rx = 'usage: myapp acts-1-0 yowzaa [-h]'
      _invite_rx = 'use myapp acts-1-0 -h yowzaa for help'

      it "2.1. unexpected arg - e / u / i" do
        invoke 'yowzaa', 'bing'
        expect_strings 'unexpected argument: "bing"', _usage_rx, _invite_rx
      end

      it "2.2. unexpected opt - e / u / i" do
        invoke 'yowzaa', '-x'
        expect_strings 'invalid option: -x', _usage_rx, _invite_rx
      end

      it "2.4. expected opt (help) - screen" do
        invoke 'yowzaa', '-h'
        expect_strings 'usage: myapp acts-1-0 yowzaa [-h]',
          '',
          'options:',
          /\A +-h, --help +this screen\z/
      end

      it "1.4. just `-h` - the big screen" do
        invoke '-h'
        ioa.emitted.length.should eql( 9 )
        ioa.emitted.first.string.should match( usage_rx )
        ioa.emitted.last.string.should eql(
          "use myapp acts-1-0 -h <action> for help on that action" )
      end

      it "1.3. no args as expected - works" do
        res = invoke 'yowzaa'
        ioa.emitted.length.should eql( 1 )
        ioa.emitted.first.name.should eql( :foofie )
        ioa.emitted.first.string.should eql( 'doofie' )
        res.should eql( :koofie )
      end
    end

    context "2. doing funky things with option parsers" do

      context "using the `bop` dsl call - overrides the op that is #{
        }build with `op`" do

        using memoize[ -> do
          acts_class[ :Acts_2_0, 'acts-2-0', -> do
            build_option_parser do
              o = Headless::Services::OptionParser.new
              o.on '-x', '--xylophone <foo>' do |v|
                @xylo = v
              end
              o
            end

            def wankers bankers
            end
          end ]
        end ]

        it "shows help screen with custom op" do
          invoke '-h', 'wankers'
          ioa.emitted.first.string.should eql(
            "usage: myapp acts-2-0 wankers [-x <foo>] bankers" )
          ioa.emitted.last.string.strip.should eql( '-x, --xylophone <foo>' )
        end

        it "uses custom op to parse opts" do
          invoke 'wankers', '-x', 'derk', 'fankers'
          v = acts.instance_variable_get '@xylo'
          v.should eql( 'derk' )
        end
      end

      context "`op` dsl call alone - modifies the default op" do

        using memoize[ -> do
          acts_class[ :Acts_2_1, 'acts-2-1', -> do
            option_parser do |o|
              o.on '-y', '--ylophone <var>' do |v|
                @ylophone = v
              end
            end
            def dinkle
            end
          end ]
        end ]

        it "opt parse param value - gets a box context" do
          invoke 'dinkle', '-y', 'sure'
          acts.instance_variable_get( '@ylophone' ).should eql( 'sure' )
        end

        it "you still get the builtin -h, which comes at end" do
          invoke 'dinkle', '-h'
          penult, ult = ioa.emitted[-2..-1].map(&:string)
          penult.should match( /ylophone/ )
          ult.should match( /--help +this screen/ )
        end
      end

      context "`op` after a `bop`" do
        context "if you don't run the `op` explicitly" do
          using memoize[ -> do
            acts_class[ :Acts_2_2, 'acts-2-2', -> do
              build_option_parser do
                o = Headless::Services::OptionParser.new
                o.on '-a', '--alpha'
                o
              end
              option_parser do |o|
                fail 'no'
              end
              def bizzo
              end
            end ]
          end ]

          it "- it does not run them for you", f:true do
            kls = acts.send :fetch, :bizzo
            act = kls.new acts
            op = act.send :option_parser
            op.top.list.length.should eql( 1 )
            op.top.list.last.short.first.should eql( '-a' )
          end
        end
      end
    end
  end
end
