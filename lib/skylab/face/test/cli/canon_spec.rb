require_relative 'test-support'

module Skylab::Face::TestSupport::CLI

  describe "#{ Face }::CLI - " do

    extend CLI_TestSupport

    as :invite_as_branch_opt,
      /\ATry wtvr -h \[sub-cmd\] for help\.?\z/i, :styled

    as :options_header_plural,  /\Aoptions:\z/i, :styled

    as :options_header_singular,  /\Aoption:\z/i, :styled

    as :help_item,
      /\A +-h, --help \[cmd\] +this screen.+or sub-command help/i, :nonstyled

    as :command_header_singular, /\Acommand:\z/i, :styled

    as :terminal_opts_addendum, /\A +wtvr \{-h \[cmd\]\}\z/, :nonstyled

    as :invite_as_branch_req,
      /\ATry wtvr -h <sub-cmd> for help on a particular command\.?\z/i, :styled

    as :invalid_option_foo, /\Ainvalid option: -k\z/i, :styled

    context "client from empty class" do

      with_body { }

      as :expecting_nothing, /\AExpecting nothing\.?\z/i, :nonstyled

      context 'zip' do
        ptrn '0'
        argv
        desc "no args"
        expt :expecting_nothing, :invite_as_branch_opt
        it does do
          invoke argv
          expect expt
        end
      end

      as :unrecog_reason,
        /\AUnrecognized command: "zippers". Expecting: nothing\z/i, :nonstyled

      one_point_one = [ :unrecog_reason,
                        :invite_as_branch_opt ]
      context 'bar arg' do
        ptrn '1.1'
        desc "bad arg"
        argv 'zippers'
        expt(* one_point_one )
        it does do
          invoke argv
          expect expt
        end
      end

      context 'bad args' do
        ptrn '2.1xX'
        desc "bad args - (identical to 1.1)"
        argv 'zippers', 'zap'
        expt(* one_point_one )
        it does do
          invoke argv
          expect expt
        end
      end

      # for '1.3' - there is no such thing as a good arg when you have
      # no subcommands.

      context 'bad opt' do
        ptrn '1.2'
        desc "bad opt"
        argv '-k'
        expt :invalid_option_foo, :invite_as_branch_opt
        it does do
          invoke argv
          expect expt
        end
      end

      as :options_header_singular, /\Aoption:\z/i, :styled

      as :usage_with_terminal_opt, /\Ausage: wtvr \[-h \[cmd\]\]\z/i, :styled

      context "help (and it's the only valid option)" do
        ptrn '1.4'
        desc 'help'
        argv '-h'
        expt :usage_with_terminal_opt, :options_header_singular, :help_item
        it does do
          invoke argv
          expect expt
        end
      end
    end

    as :usage_with_one_subcmd,
      /\Ausage: wtvr \{fiz\} \[opts\] \[args\]\z/i, :styled

    as :command_item_with_syntax,
      /\A +fiz  +usage: wtvr fiz\z/i, :styled

    context "client with one public function" do

      as :expecting_one_subcmd, /\AExpecting:? fiz\.?\z/i, :styled

      with_body do
        def fiz
          @out.puts "ok fiz."
          :you_did_foo
        end
      end

      context 'no args' do
        ptrn '0'
        desc "no args"
        argv
        expt :expecting_one_subcmd, :invite_as_branch_opt
        it does do
          invoke argv
          expect expt
        end
      end

      as :unrec_foo_expecting_bar,
        /\AUnrecognized command: "wizzle"\. Expecting: fiz\z/i, :styled

      context 'bad arg' do
        ptrn '1.1'
        desc "bad arg"
        argv 'wizzle'
        expt :unrec_foo_expecting_bar, :invite_as_branch_opt
        it does do
          invoke argv
          expect expt
        end
      end

      context 'good arg - invokes. 3 axis ok' do
        ptrn '1.3'
        desc "good arg"
        argv 'fiz'
        it does do
          res = invoke argv
          stderr_lines.should be_empty
          stdout_lines.should eql( [ 'ok fiz.' ] )
          res.should eql( :you_did_foo )
        end
      end

      context '-h to the branch' do
        ptrn '1.4'
        desc "-h to branch"
        argv '-h'
        expt :usage_with_one_subcmd,        # usage: foo {bar} [opts] [args]
             :terminal_opts_addendum,       #        foo {-h [cmd]}
             :options_header_singular,      # option:
             :help_item,                    #   -h, --help [cmd]   this scree
             :command_header_singular,      # command:
             :command_item_with_syntax,     #   fiz usage: wtv fiz
             :invite_as_branch_req          # Try wtv -h <sub-cmd> for help
        expt_desc 'full help screen (with terminal opts addendum)'
        it does do
          invoke argv
          expect expt
        end
      end

      as :unrecog_reason,
        /\AUnrecognized command: "pizzle". Expecting: fiz\z/i, :styled

      context '-h as prefix (help with bad arg)' do
        ptrn "2.4x1"
        desc "-h prefixed (help with bad arg)"
        argv '-h', 'pizzle'
        expt :unrecog_reason, :invite_as_branch_opt
        it does do
          invoke argv
          expect expt
        end
      end

      as :fully_qualified_usage_line, /\Ausage: wtvr fiz\z/i, :styled

      context '-h as prefix (help with good arg)' do
        ptrn "2.4x3"
        desc "-h prefixed (help with good arg)"
        argv '-h', 'fiz'
        expt :fully_qualified_usage_line
        it does do
          invoke argv
          expect expt
        end
      end

      as :_unexpected_argument, /\AUnexpected argument: "biz"\z/i, :nonstyled
      as :_custom_usage_msg, /\Ausage: wtvr -h \[cmd \[sub-cmd \[\.\.\]\]\]\z/i,
        :styled

      context '-h prefixed with good arg then foo' do
        ptrn "3.4x3x1"
        desc "-h prefixed with good arg then foo"
        argv '-h', 'fiz', 'biz'
        expt :_unexpected_argument, :_custom_usage_msg, :invite_as_branch_opt
        expt_desc 'insane custom error'
        it does do
          invoke argv
          expect expt
        end
      end

      context "**-h postfix hack** for a node with no o.p" do
        ptrn '2.4xH'
        desc '-h postfix hack'
        argv 'fiz', '-h'
        expt :fully_qualified_usage_line
        it does do
          invoke argv
          expect expt
        end
      end

      as :wrong_number_of_args_reason,
        /\Awrong number of arguments \(1 for 0\)\z/i, :nonstyled

      as :invite_as_leaf, /\ATry wtvr -h fiz for help\.?\z/i, :styled

      as :subcommand_usage, /wizzle/, :styled

      context '1 (extraneous) arg to subcommand)' do
        ptrn "2.3x1"
        desc "1 (extraneous) arg"
        argv 'fiz', 'biz'
        expt :wrong_number_of_args_reason, :fully_qualified_usage_line,
          :invite_as_leaf
        it does do
          invoke argv
          expect expt
        end
      end
    end

    context "func with 1 arg (required)" do
      with_body do
        def fiz baz
          @y << "your baz is: #{ baz }."
          :fizzed
        end
      end

      as :command_item_with_1_arg_syntax,
        /\A +fiz  +usage: wtvr fiz <baz>\z/i, :styled

      context 'help at level 0' do
        ptrn '1.4'
        desc 'help'
        argv '-h'
        expt :usage_with_one_subcmd,
          :terminal_opts_addendum,
          :options_header_singular,
          :help_item,
          :command_header_singular,
          :command_item_with_1_arg_syntax,
          :invite_as_branch_req
        expt_desc 'help screen'
        it does do
          invoke argv
          expect expt
        end
      end

      context '1 arg goes to subcommand' do
        ptrn '2.3x3'
        desc 'take that one good arg'
        argv 'fiz', 'biz'
        expt_desc 'works'
        it does do
          res = invoke argv
          stderr_lines.should eql( ["your baz is: biz."] )
          res.should eql( :fizzed )
        end
      end

      context "missing required argument" do
        ptrn '1.3'
        desc 'whines'
        argv 'fiz'
        expt_desc 'first line is whining'
        it does do
          res = invoke argv
          expect_nonstyled_line( /\Awrong number of arguments \(0 for 1\)\z/i )
        end
      end
    end

    context "empty o.p" do
      with_body do
        option_parser do
        end
        def fiz
          :ok
        end
      end

      context '-h to branch with one node' do
        ptrn '1.4'
        desc 'help as -h'
        argv '-h'
        expt_desc "penultimate line is command item with syntax"
        it does do
          invoke argv
          expect_line_at_index_to_be( -2, :command_item_with_syntax )
        end
      end

      context 'strange option to branch' do
        ptrn '1.2'
        desc 'strange opt'
        expt :invalid_option_foo
        argv '-k'
        it does do
          invoke argv
          expect_partial expt
        end
      end

      context 'the name of the command and nothing more' do
        ptrn '1.3'
        argv 'fiz'
        desc 'the name of the command and nothing more'
        expt_desc 'works'
        it does do
          invoke( argv ).should eql( :ok )
          expect_no_more_output
        end
      end
    end

    context "cmd with 2 opts, and 1 optional arg" do
      with_body do
        option_parser do |o|
          @param_h ||= { }
          @param_h[:merf] = :nerk
          o.on '-j', '--j-date', 'the website called j-date' do
            @param_h[:j_date] = 'meet jewish singles in your area'
          end
          o.on '--some-val VAL' do |v|
            @param_h[:someval] = v
          end
        end
        def fiz meh=nil
          [ meh, @param_h ]
        end
      end

      as :command_item_with_syntax, /\A
        [ ]+fiz[ ]+usage:[ ]wtvr[ ]fiz[ ]
          \[-j\][ ]
          \[--some-val[ ]VAL\][ ]\[<meh>\][ ]\[\.\.\]
      \z/x, :styled  # sweet mujoseph eyeblood

      context 'help to branch' do
        ptrn '1.4'
        desc  'help to tha branch'
        argv '-h'
        expt_desc 'penultimate line is command item with syntax with opts'
        it does do
          invoke argv
          line = expect_line_at_index( -2 )
          ln = expect_styled line
          ohai = as[ :command_item_with_syntax ]
          expect_match ln, ohai.rx
        end
      end

      context(
        '1 good arg to subcommand - fires up o.p even tho no opts b.c..') do
        ptrn "2.3x3"
        desc 'good arg to subcommand'
        argv 'fiz', 'biz'
        expt_desc 'works'
        it does do
          c = client
          arg1, param_h = c.run argv.dup
          expect_no_more_output
          arg1.should eql( 'biz' )
          param_h.fetch( :merf ).should eql( :nerk )
        end
      end

      context 'one good opt to subcommmand (without arg, short)' do
        ptrn "2.3x4s"
        desc 'one good short opt'
        argv 'fiz', '-j'
        expt_desc 'works'
        it does do
          x, h = invoke argv
          expect_no_more_output
          x.should eql( nil )
          (!! h[:j_date] ).should eql( true )
        end
      end

      context 'one good opt to subcommmand (without arg, long)' do
        ptrn "2.3x4l"
        desc 'one good long opt'
        argv 'fiz', '--j-date'
        expt_desc 'works'
        it does do
          x, h = invoke argv
          expect_no_more_output
          x.should eql( nil )
          (!! h[:j_date] ).should eql( true )
        end
      end

      context 'one good opt to subcommmand (with arg) ajoined' do
        ptrn "2.3x4a"
        desc 'one goot optarg'
        argv 'fiz', '-sohai'
        expt_desc 'works'
        it does do
          x, h = invoke argv
          expect_no_more_output
          h.fetch( :someval ).should eql( 'ohai' )
        end
      end

      as :usage_line,
        /\Ausage: wtvr fiz \[-j\] \[--some-val VAL\] \[<meh>\]\z/i, :styled

      as :opt_item_1,
        /\A +-j, --j-date +the website called j-date\z/, :nonstyled

      as :opt_item_2,
        /\A +--some-val VAL\z/, :nonstyled

      context "help as postfix option, o.p didn't specify -h explicitly" do
        ptrn '2.3x4h'
        desc 'help as postfix option'
        argv 'fiz', '-h'
        expt :usage_line, :options_header_plural, :opt_item_1, :opt_item_2
        it does do
          res = invoke argv
          res.should eql( nil )
          expect expt
        end
      end

      context 'everything, all args and opts and opt args' do
        ptrn '3.omni'
        desc 'everything'
        argv 'fiz', '-jshallo', 'merbles'
        expt_desc 'works'
        it does do
          x, h = invoke argv
          expect_no_more_output
          x.should eql( 'merbles' )
          [ :merf, :someval ].map { |k| h[k] }.should eql( [ :nerk, 'hallo' ] )
          h.fetch( :j_date ).should be_include( 'your area')
        end
      end
    end

    context "one opt, 1 arg" do

      with_body do

        option_parser do |o|
          @param_h = { }
          o.on '-x' do @param_h[:ex] = true end
        end

        def fiz arg1
          [ arg1, @param_h ]
        end
      end

      as :usage_line, /\Ausage: wtvr fiz \[-x\] <arg1>\z/, :styled
      as :option_header_singular, /\Aoption:\z/i, :styled
      as :option_item, /\A +-x\z/, :nonstyled

      context "it gets smart about arg parsing when terminal opts invoked" do
        ptrn '2.4x3'
        argv 'fiz', '-h'
        desc 'requesting help..'
        expt :usage_line, :option_header_singular, :option_item
        expt_desc 'does *not* trip a complaint about missing arg'
        it does do
          res = invoke argv
          res.should eql( nil )
          expect expt
        end
      end

      as :wrong_number_of_args_reason,  # (0 for 1, not 1 for 0)
        /\Awrong number of arguments \(0 for 1\)\z/i, :nonstyled

      context "only when we didn't request help does the error trigger" do
        ptrn '1.3'
        argv 'fiz'
        desc 'not requesting help..'
        expt_desc '*does* trip a complaint about missing arg'
        it does do
          invoke argv
          expect_partial [ :wrong_number_of_args_reason ]
          stderr_lines.length.should eql( 2 )
        end
      end
    end
  end
end
