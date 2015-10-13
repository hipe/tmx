require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] modality integrations - CLI" do

    # (somewhat at odds with other nearby test nodes,
    #  this is testing *our* tmx, and not *the* tmx)

    extend TS_
    use :modalities_CLI

    _ARG = 'ping'.freeze
    _FLAG = '--ping'.freeze

    it "beauty salon" do
      _against 'beauty-salon', _ARG
      _expect_common
    end

    it "bnf2treetop" do
      _against 'bnf2treetop', _FLAG
      _expect_common
    end

    it "breakup - capture3" do
      _against 'git', 'breakup', _FLAG
      _expect_succeeded
    end

    it "callback" do
      _against 'callback', _ARG
      _expect_common
    end

    it "citxt" do
      _against 'git', 'citxt', _FLAG
      _expect_succeeded
    end

    it "css-convert" do

      _against 'css-convert', 'convert', _FLAG
      @_slug = 'css-convert'
      _expect_common
    end

    it "cull" do
      _against 'cull', _ARG
      _expect_common
    end

    it "file metrics" do
      _against 'file-metrics', _ARG
      _expect_common
    end

    it "flex2treetop" do
      _against 'flex2treetop', _ARG
      _expect_common
    end

    it "git" do
      _against 'git', _ARG
      _expect_common
    end

    it "permute" do
      _against 'permute', _ARG
      _expect_common
    end

    it "quickie" do

      invoke 'test-support', 'quickie', '-ping'

      expect :e, /\bquickie daemon is already running\b/
      expect "hello from quickie."
      expect_no_more_lines
      @exitstatus.should eql 0
    end

    it "slicer" do
      _against 'slicer', _ARG
      _expect_common
    end

    it "snag" do
      _against 'snag', _ARG
      _expect_common
    end

    it "sub tree" do

      _against 'sub-tree', _ARG
      expect :styled, :e, "hello from sub tree."
      @exitstatus.should eql :hello_from_sub_tree
    end

    it "test support" do
      _against 'test-support', _ARG
      _expect_common
    end

    it "tan man" do
      _against 'tan-man', _ARG
      _expect_common
    end

    it "treemap" do
      _against 'treemap', _ARG
      _expect_common
    end

    it "uncommit" do
      _against 'git', 'uncommit', _FLAG
      _expect_succeeded
    end

    it "xargs-ish-i" do
      _against 'xargs-ish-i', _FLAG
      _expect_succeeded
    end

    it "yacc2treetop" do
      _against 'yacc2treetop', _FLAG
      _expect_common
    end

    def _against * argv

      invoke( * argv )
      @_argv = argv
      NIL_
    end

    _DASH = '-'
    _SPACE = ' '
    _UNDERSCORE = '_'

    define_method :_expect_common do

      _expect_common_start

      @exitstatus.should eql :"hello_from_#{ @_s_a.join _UNDERSCORE }"
    end

    define_method :_expect_succeeded do

      _expect_common_start
      @exitstatus.should be_zero
    end

    define_method :_expect_common_start do

      @_slug ||= @_argv.fetch( -2 )
      @_s_a = @_slug.split _DASH

      expect :e, "hello from #{ @_s_a.join _SPACE }."

      expect_no_more_lines
    end

    def subject_CLI
      Home_::CLI
    end
  end
end
