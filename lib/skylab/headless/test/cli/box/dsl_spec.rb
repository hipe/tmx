require_relative 'dsl/test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  describe "[hl] CLI box DSL" do

    extend TS__

    # ~ In this file we will be experimenting with some nerks: ~

    # ~ Part 1. Functions. ~      # these are nice because its easier at
                                  # a glance to see a function's dependencies

    memoize = MetaHell::FUN.memoize

    box_class = -> const, block=nil do
      cls = TS__.const_set const, ::Class.new
      cls.class_exec do
        @name_function = Headless::Name::Function::From::Module_Anchored.new(
          "Spoof::#{ const }", "Spoof" )
        Headless::CLI::Box::DSL[ self ]
        class_exec(& block ) if block
      end
      cls
    end

    build_box = -> me, cls_func do
      spy = Headless_TestSupport::Client_Spy::CLI.new
      spy.normalized_invocation_string = 'myapp'
      spy.debug = -> { me.do_debug }
      # ioa = spy.send :io_adapter
      ioa = spy  # ACK  #todo
      box = cls_func[].new spy
      me.ioa = ioa
      box
    end

    _expect_names = -> me, ioa, *names do
      actual = ioa.emission_a.map(& :stream_name )
      actual.should me.eql( names )
      nil
    end

    _expect_strings = -> me, ioa, strings do
      strs = ioa.emission_a.map(& me.expect_text )
      while str = strs.shift
        str = Headless::CLI::Pen::FUN.unstyle[ str ]
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
                                  # they are more readable than `let`s

    def self.using cls_func
      let :cls_func do cls_func end
    end

    # ~ Part 3. i.m's that synthesize parts 1 & 2 ~
                                  # a tight little spaghetti bowl -- look!
    let :box do
      build_box[ self, cls_func ]
    end

    define_method :expect_strings do |*strings|
      _expect_strings[ self, ioa, strings ]
    end

    def expect_styled str
      x = Headless::CLI::Pen::FUN.unstyle_styled[ str ]
      x or fail( "expected this to have some styling in it - #{ str }" )
    end

    attr_accessor :ioa            # io_adapter

    def invoke *argv
      box.invoke argv
    end

    # ~ Part 4. is the money ~

    usage_rx = /\Ausage: myapp box-\d-\d \[<action>\] \[<args> \[\.\.\]\]\z/

    invite_rx = /\Ause myapp box-\d-\d -h \[<action>\] for help\z/

    context "0. with nothing" do
      expecting_nothing_rx = /expecting \{\}/

      box_0_0 = memoize[ -> do
        box_class[ :Box_0_0 ]
      end ]

      using box_0_0

      it "   0. nothing - error / usage / invite" do
        invoke
        _expect_names[ self, ioa, :error, :help, :help ]
        expect_strings expecting_nothing_rx, usage_rx, invite_rx
      end

      it " 1.1. funky action - jizz / jazz / other" do
        invoke 'jenkum'
        msg = expect_text[ ioa.emission_a.first ]
        msg.should match( expecting_nothing_rx )
        msg.include?( 'there is no "jenkum" action.' ).should eql( true )
      end
    end

    context "1. with nothing but a method definition" do

      box_1_0 = memoize[ -> do
        box_class[ :Box_1_0, -> do
          def yowzaa
            emit :foofie, 'doofie'
            :koofie
          end
         end
        ]
      end ]

      expecting_rx = /expecting \{yowzaa\}/

      it "internally an action class is created - (..::Actions::Yowzaa)" do
        box_1_0[]::Actions::Yowzaa # absence of exceptions means passing
      end

      using box_1_0

      it "the action object itself gives an `option_parser` with a -h" do
        action = box_1_0[]::Actions::Yowzaa.new box
        op = action.send :option_parser # the action object has an option parser
        (!! op).should eql( true )
        op.top.list.length.should eql( 1 ) # which has only 1 element
        op.top.list.first.short.first.should eql( '-h' ) # which is '-h'
        op.parse '--hel'
        action.instance_variable_defined?( :@queue ).should eql( false )
        box.instance_variable_get( :@queue ).length.should eql( 1 )
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

      _usage_rx = 'usage: myapp box-1-0 yowzaa [-h]'
      _invite_rx = 'use myapp box-1-0 -h yowzaa for help'

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
        expect_strings 'usage: myapp box-1-0 yowzaa [-h]',
          '',
          'options:',
          /\A +-h, --help +this screen\z/
      end

      it "1.4. just `-h` - the big screen" do
        invoke '-h'
        ioa.emission_a.length.should eql( 9 )
        str = expect_styled expect_text[ ioa.emission_a.first ]
        str.should match( usage_rx )
        str = expect_styled expect_text[ ioa.emission_a.last ]
        str.should eql(
          "use myapp box-1-0 -h <action> for help on that action" )
      end

      it "1.3. no args as expected - works" do
        res = invoke 'yowzaa'
        ioa.emission_a.length.should eql( 1 )
        ioa.emission_a.first.stream_name.should eql( :foofie )
        expect_text[ ioa.emission_a.first ].should eql( 'doofie' )
        res.should eql( :koofie )
      end
    end

    context "2. doing funky things with option parsers" do

      context "using the `bop` dsl call - overrides the op that is #{
        }build with `op`" do

        using memoize[ -> do
          box_class[ :Box_2_0, -> do
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
          str = expect_styled expect_text[ ioa.emission_a.first ]
          str.should eql( "usage: myapp box-2-0 wankers [-x <foo>] <bankers>" )
          expect_text[ ioa.emission_a.last ].strip.
            should eql( '-x, --xylophone <foo>' )
        end

        it "uses custom op to parse opts" do
          invoke 'wankers', '-x', 'derk', 'fankers'
          v = box.instance_variable_get '@xylo'
          v.should eql( 'derk' )
        end
      end

      context "`op` dsl call alone - modifies the default op" do

        using memoize[ -> do
          box_class[ :Box_2_1, -> do
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
          box.instance_variable_get( '@ylophone' ).should eql( 'sure' )
        end

        it "you still get the builtin -h, which comes at end" do
          invoke 'dinkle', '-h'
          penult, ult = ioa.emission_a[-2..-1].map(& expect_text )
          penult.should match( /ylophone/ )
          ult.should match( /--help +this screen/ )
        end
      end

      context "`op` after a `bop`" do
        context "if you don't run the `op` explicitly" do
          using memoize[ -> do
            box_class[ :Box_2_2, -> do
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

          it "- it does not run them for you" do
            kls = box.send :fetch, :bizzo
            act = kls.new box
            op = act.send :option_parser
            op.top.list.length.should eql( 1 )
            op.top.list.last.short.first.should eql( '-a' )
          end
        end
      end
    end
  end
end
