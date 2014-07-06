require_relative '../test-support'

module Skylab::MetaHell::TestSupport::FUN::Parse::F_VS_

  ::Skylab::MetaHell::TestSupport::FUN::Parse[ self ]

  include CONSTANTS

  MetaHell = MetaHell

  describe "#{ MetaHell }::FUN parse field- values- (integration)" do

    before :all do
      module Bazzle
        Flag_ = MetaHell::FUN::Parse::Field_::Flag_
        BRANCH_ = MetaHell::FUN.parse_alternation.curry[
          :syntax, :monikate, -> a { a * ' | ' },
          :field, Flag_,
            :moniker, :help,
            :predicate, :do_help,
            :short, '-h', :long, '--help',
          :field, Flag_,
            :moniker, :server,
            :predicate, :do_server,
            :fuzzy_min, 1,
          :call, -> * input_x_a do
            _FIXME_absrb :state_x_a, input_x_a
            execute
          end,
          :constantspace, self
        ]
      end
    end

    def parse_argv any_argv
      Bazzle::BRANCH_.parse_argv any_argv
    end

    it "nil - nil" do
      parse_argv( nil ).should be_nil
    end

    STRANGE_A_ = [ 'strange' ].freeze

    it "strange token - nil and argv is left alone" do
      r = parse_argv STRANGE_A_
      r.should be_nil
    end

    it "strange token blocks parsing of subsequent recognized tokens" do
      argv = [ 'strange', '-h' ]
      r = parse_argv argv
      r.should be_nil
      argv.should eql( %w( strange -h ) )
    end

    it "one recognized token then one strange - parses and consumes" do
      argv = [ '-h', 'strange' ]
      r = parse_argv argv
      r.do_help.should eql( true )
      r.do_server.should eql( nil )
      argv.should eql( [ 'strange' ] )
    end

    it "two recognizables - only parses first b.c is a branch" do
      argv = [ 'server', '-h' ]
      r = parse_argv argv
      r.to_a.should eql( [ nil, true ] )
      argv.should eql( [ '-h' ] )
    end
  end
end
