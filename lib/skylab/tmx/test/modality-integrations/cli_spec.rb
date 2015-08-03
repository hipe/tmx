require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] modality integrations - CLI" do

    # (somewhat at odds with other nearby test nodes,
    #  this is testing *our* tmx, and not *the* tmx)

    extend TS_
    use :modalities_CLI

    _FLAG = '--ping'.freeze
    _PING_ARG = 'ping'.freeze

    it "beauty salon" do
      go :beauty_salon, _PING_ARG
    end

    it "bnf2treetop" do
      go :bnf2treetop, _FLAG
    end

    it "breakup - capture3" do
      go_ :breakup, _FLAG
    end

    it "callback" do
      go :'callback', _PING_ARG
    end

    it "citxt" do
      go_ :citxt, _FLAG
    end

    it "css-convert", wip: true do
      go :'css-convert', _FLAG
    end

    it "cull" do
      go :cull, _PING_ARG
    end

    it "file metrics" do
      go :file_metrics, _PING_ARG
    end

    it "flex2treetop" do
      go :flex2treetop, _PING_ARG
    end

    it "git" do
      go :git, _PING_ARG
    end

    it "permute" do
      go :permute, _PING_ARG
    end

    it "quickie" do

      invoke "quickie", "-ping"

      expect :e, /\bquickie daemon is already running\b/
      expect "hello from quickie."
      expect_no_more_lines
      @exitstatus.should eql 0
    end

    it "slicer" do
      go :slicer, _PING_ARG
    end

    it "snag" do
      go :snag, _PING_ARG
    end

    it "sub tree" do

      _go :styled, true, [ :sub_tree, _PING_ARG ]
    end

    it "test support" do
      go :"test-support", _PING_ARG
    end

    it "tan man" do
      go :tan_man, _PING_ARG
    end

    it "treemap" do
      go :treemap, _PING_ARG
    end

    it "uncommit" do
      go_ :uncommit, _FLAG
    end

    it "xargs-ish-i" do
      go_ :'xargs-ish-i', _FLAG
    end

    it "yacc2treetop" do
      go :'yacc2treetop', _FLAG
    end

    def go * argv
      _go true, argv
    end

    def go_ * argv
      _go false, argv
    end

    define_method :_go, -> do

      _DASH = '-'
      _SPACE = ' '
      _UNDERSCORE = '_'

      -> * x_a, yes, argv do

        a = argv.first.id2name.split _UNDERSCORE

        argv[ 0 ] = a.join _DASH

        invoke( * argv )

        expect( * x_a, :e, "hello from #{ a.join _SPACE }." )

        expect_no_more_lines

        x = @exitstatus
        if yes

          _sym = :"hello_from_#{ a.join _UNDERSCORE }"
          x.should eql _sym
        else
          x.should eql 0
        end
      end
    end.call

    def subject_CLI
      Home_::CLI
    end
  end
end
