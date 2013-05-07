require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Option

  ::Skylab::Face::TestSupport::CLI[ Option_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module CONSTANTS
    Sandbox = CLI_TestSupport::Sandbox  # please be careful
  end

  describe "#{ Face }::CLI - options, officous" do

    extend Option_TestSupport

    context 'the time has come for this' do

      with_body do

        story.option_parser do |o|
          @queue_a = [ ]
        end

        on '-x', '--ex [ARG]' do |v|
          @queue_a << [ :ex, v ]
        end

        def fiz arg1
          [ :fiz, arg1 ]
        end

      protected

        def ex arg1
          [ nil, arg1 ]  # don't stay
        end
      end

      as :expecting, /\AExpecting fiz\.\z/i, :styled
      as :usage, /\Ausage: wtvr \{fiz\} \[opts\] \[args\]\z/, :styled

      context do
        ptrn '0'
        desc 'nothing'
        expt :expecting
        argv
        it does do
          invoke argv
          expect_partial expt
        end
      end

      context do
        ptrn '2.4x3'
        desc 'opt with arg **OPT WINS, NO SUBCOMMAND**'
        argv '-x', 'win'
        expt_desc 'the opt has it'
        it does do
          x = invoke argv
          expect_no_more_output
          x.should eql( 'win' )
        end
      end

      as :unrecognized_command, /\AUnrecognized command:? \"piz\"/i, :styled

      context do
        ptrn '1.1'
        desc 'bad arg'
        argv 'piz'
        expt :unrecognized_command
        it does do
          invoke argv
          expect_partial expt
        end
      end

      context do
        ptrn '2.3x3'
        desc 'good arg'
        argv 'fiz', 'a1'
        expt_desc 'works'
        it does do
          x = invoke argv
          expect_no_more_output
          x.should eql( [ :fiz, 'a1' ] )
        end
      end
    end

    context "officious - version" do

      context "out of box" do

        with_body { }

        it "`class.version` - no method error" do
          -> do
            self.class.client_class.version
          end.should raise_error( ::NameError, /undefined method `get_vers/ )
        end

        it "client does not respond to `show_version`" do
          client.respond_to?( :show_version ).should eql( false )
        end
      end

      context "you can't set the version multiple times per class" do

        let :kls do
          Sandbox.produce_subclass
        end

        def raise_the_error
          raise_error ::ArgumentError, /won't overwrite.+version/i
        end

        it "block block - no" do
          kls.class_exec { version { } }
          -> do
            kls.class_exec { version { :again } }
          end.should raise_the_error
        end

        it "block arg - no" do
          kls.class_exec { version { } }
          -> do
            kls.class_exec { version :foo }
          end.should raise_the_error
        end

        it "arg arg - no" do
          kls.class_exec { version :foo }
          -> do
            kls.class_exec { version :foo }
          end.should raise_the_error
        end

        it "arg block - no" do
          kls.class_exec { version :foo }
          -> do
            kls.class_exec { version { } }
          end.should raise_the_error
        end

        it "parent arg, child arg - ok" do
          kls.class_exec do
            version :foo
          end
          kl2 = ::Class.new kls
          kl2.version.should eql( :foo )
          kl2.class_exec do
            version :bar
          end
          kl2.version.should eql( :bar )
        end

        it "parent block, child block - ok" do
          kls.class_exec do
            version do :wiz end
          end
          kl2 = ::Class.new kls
          kl2.version.should eql( :wiz )
          kl2.class_exec do
            version do :bang end
          end
          kl2.version.should eql( :bang )
        end
      end

      context "but when it works" do

        with_body do
          version '1.2.3'
        end

        as :version_output, /\Awtvr 1.2.3\z/, :nonstyled, :out

        ptrn '1.4'
        desc 'version switch'
        argv '-v'
        expt :version_output

        it does do
          invoke argv
          expect expt
        end
      end
    end

    context "BAD TEST - as a ridiculous demonstration of many things" do
      with_body do
        version '1.1.1'

        namespace :wizzle do

          namespace :wazzle do

            def plow wiz, wang=nil
            end

            def blau weeple
              @y << "wepple wopped"
              out.puts 'weeple weeped'
              [ :weeple, weeple ]
            end
          end
        end
      end

      as :usage,   /\Ausage: wtvr \{wizzle\} \[opts\] \[args\]\z/, :styled
      as :adtl_usage, /\A {2,}wtvr \{-h \[cmd\]\|--version\}\z/, :nonstyled
      as :opt_hdr_plur, /\Aoptions:\z/i, :styled
      as :opt_item_help, /\A {2,}-h, --help \[cmd\] {2,} this.+sub/, :nonstyled
      as :opt_item_vers, /\A {2,}--version {2,} .+version/, :nonstyled
      as :cmd_hdr_sing, /\Acommand:/i, :styled
      as :cmd_item,
        /\A {2,}wizzle {2,}usage: wtvr wizzle \{wazzle\} \[op/, :styled
      as :invite,
        /\ATry wtvr -h \<sub-cmd> for help on a particular command\.\z/i,
        :styled

      context do
        ptrn '1.4'
        desc 'help at level 0'
        argv '-h'
        expt :usage, :adtl_usage,
          :opt_hdr_plur, :opt_item_help, :opt_item_vers,
          :cmd_hdr_sing, :cmd_item,
          :invite
        expt_desc "the most beautiful help screen ever"
        it does do
          invoke argv
          expect expt
        end
      end

      context do
        ptrn '4.3x3x3x3'
        argv 'wizzle', 'wazzle', 'blau', 'flau'
        desc "execute at three levels in"
        expt_desc "writes to stdout, sterr, result in result"
        it does do
          res = invoke argv
          stderr_gets.should eql( 'wepple wopped' )
          stdout_gets.should eql( 'weeple weeped' )
          expect_no_more_output
          res.should eql( [ :weeple, 'flau' ] )
        end
      end

      as :ver, /\Awtvr 1\.1\.1\z/i, :nonstyled, :out
      as :us1, /\Ausage: wtvr wizzle wazzle plow <wiz> \[<wang>\]\z/, :styled
      as :us2, /\Ausage: wtvr wizzle wazzle blau <weeple>\z/, :styled

      context do
        ptrn '9.4x3x3x3x4x4x3x3x3'
        desc 'ask for help on 2 deep nodes, and ask for version in the middle'
        argv '-h', 'wizzle', 'wazzle', 'plow', '-v',
          '-h', 'wizzle', 'wazzle', 'blau'
        expt :us1, :ver, :us2
        expt_desc 'the three lines'
        it does do
          invoke argv
          expect expt
        end
      end
    end
  end
end
