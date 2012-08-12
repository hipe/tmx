require_relative 'test-support'

describe "#{Skylab::Bnf2Treetop} CLI integration" do
  extend ::Skylab::Bnf2Treetop::TestSupport::CLI
  context 'doing nothing' do
    invoke
    it 'shows usage' do
      should_see_usage
    end
  end

  context 'asking for help' do
    invoke '-h'
    it 'shows usage' do
      should_see_usage
    end
  end

  context 'giving 2 args' do
    invoke 'one', 'two'
    it 'shows usage' do
      should_see_usage
    end
  end

  context 'giving it a nonexistant filename' do
    invoke 'not-there.bnf'
    it 'says file not found and then shows usage' do
      err.shift.should match(/\bfile not found: not-there\.bnf\b/i)
      err.shift.should match(USAGE_RE)
      err.length.should eql(0)
    end
  end

  context 'giving it a good filename' do
    invoke self::FIXTURES.join('xml-names.bnf').to_s
    it 'works!' do
      err.length.should eql(0)
      (10..30).should cover(out.length) # e.g. 19
      out.first.should eql('  rule name_start_char')
      out.last.should eql('  end')
    end
  end
end
