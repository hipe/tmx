require_relative 'cli/test-support'

describe "#{Skylab::Bnf2Treetop} CLI integration" do
  extend ::Skylab::Bnf2Treetop::TestSupport::CLI

  def error msg_re
    err.shift.should match(msg_re)
  end

  def usage
    unstyle(err.shift).should eql(
      'usage: bnf2treetop [options] { <bnf-file> | - }')
  end

  def invite
    unstyle(err.shift).should eql('bnf2treetop -h for help')
  end

  def no_payload
    out.length.should eql(0)
  end

  def options_listing
    unstyle(err.shift).should eql('options:')
    (10..17).should cover(err.length)
    err.detect { |s| /\A[[:space:]]/ !~ s }.should eql(nil)
  end

  context 'doing nothing' do
    invoke do
      error( /expecting <bnf-file> had 0 args/i )
      usage
      invite
      no_payload
    end
  end

  context 'asking for help' do
    invoke '-h' do
      usage
      options_listing
      no_payload
    end
  end

  context 'giving 2 args' do
    invoke 'one', 'two' do
      error( /expecting <bnf-file> had 2 args/i )
      usage
      invite
      no_payload
    end
  end

  context 'giving it a nonexistant filename' do
    invoke 'not-there.bnf' do
      error( /\bfile not found: not-there\.bnf\b/i )
      usage
      invite
      no_payload
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
