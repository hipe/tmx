require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Namespace

  ::Skylab::Face::TestSupport::CLI[ Namespace_TestSupport = self ]

  include CONSTANTS

  module CONSTANTS
    SANDBOX = CLI_TestSupport::SANDBOX  # please be careful
  end

  extend TestSupport::Quickie

  describe "#{ Face }::CLI - namespaces" do

    extend Namespace_TestSupport

    it "the `namespace` \"macro\" needs 1 arg" do
      kls = SANDBOX.produce_subclass
      -> do
        kls.class_exec do
          namespace
        end
      end.should raise_error( ::ArgumentError, /wrong number.+0 for 1/ )
    end

    it "(note you don't have to add a block or mod, it will bork later)" do
      kls = SANDBOX.produce_subclass
      kls.class_exec do
        namespace :foo
      end
    end

    context "namespace as block" do

      with_body do
        def fap_tastic
        end
        namespace :bar do
          option_parser do |o|
            o.on '-x'
          end
          def baz wing, wang
            [ wing, wang ]
          end
        end
      end

      as :expecting_reason, /\AExpecting fap-tastic or bar\.\z/i, :styled

      as :invite, /\ATry wtvr -h \[sub-cmd\] for help\.\z/i, :styled

      as :invite_deeper,
        /\ATry wtvr bar -h <sub-cmd> for help on a particular command\.?\z/i,
        :styled

      context do
        ptrn '0'
        desc 'nothing'
        argv
        expt :expecting_reason, :invite
        expt_desc "shows them in right order"
        it does do
          invoke argv
          expect_partial expt
        end
      end

      context do

        as :expecting, /\AExpecting baz\.\z/i, :styled
        as :invite, /\ATry wtvr bar -h \[sub-cmd\] for help\.\z/i, :styled

        ptrn '1.3'
        desc 'just the branch name, terminal'
        argv 'bar'
        expt :expecting, :invite
        it does do
          invoke argv
          expect expt
        end
      end

      as :usage,      /\Ausage: wtvr bar \{baz\} \[opts\] \[args\]\z/i, :styled
      as :adtl_usage, /\A       wtvr bar \{-h \[cmd\]\}\z/, :nonstyled
      as :opt_hdr_singular, /\Aoption:\z/i, :styled
      as :opt_item, /\A {2,}-h, --help \[cmd\] {2,}.+sub-co.+ help/, :nonstyled
      as :cmd_hdr_singular, /\Acommand:\z/i, :styled
      as :cmd_item,
        /\A {2,}baz {2,}usage: wtvr bar baz \[-x\] <wing> <wang> \[\.\.\]\z/i,
        :styled

      context do
        ptrn '2.4x3'
        desc 'help prefix'
        argv '-h', 'ba'
        expt :usage, :adtl_usage,
             :opt_hdr_singular, :opt_item,
             :cmd_hdr_singular, :cmd_item,
             :invite_deeper
        expt_desc 'branch full sreen'
        it does do
          invoke argv
          expect expt
        end
      end

      as :usage_deep, /\Ausage: wtvr bar baz \[-x\] <wing> <wang>\z/, :styled

      as :option_header_singular,  /\Aoption:\z/i, :styled

      as :option_item, /\A {2,}-x\z/, :nonstyled

      context do
        ptrn '3.3x4x3'
        desc "deep help conventional"
        argv 'bar', '-h', 'baz'
        expt :usage_deep, :option_header_singular, :option_item
        it does do
          invoke argv
          expect expt
        end
      end

      context do
        ptrn '3.3x3x4'
        desc "deep help postfix"
        argv 'bar', 'baz', '-h'
        expt :usage_deep, :option_header_singular, :option_item
        it does do
          invoke argv
          expect expt
        end
      end

      context do
        ptrn '3.4x3x3'
        desc "deep help RECURSIVE"
        argv 'bar', 'baz', '-h'
        expt :usage_deep, :option_header_singular, :option_item
        it does do
          invoke argv
          expect expt
        end
      end
    end
  end
end
