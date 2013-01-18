require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  # le Quickie.

  describe "#{ Snag::CLI } actions todo find" do
    extend Actions_TestSupport

    setup = -> ctx do
      o = ctx.tmpdir_clear
      o.write 'ferbis.rb', <<-O.unindent
        alpha
        beta #todo
        gamma
      O
      o.write 'jerbis/one.rb', <<-O.unindent
        line one #todo
        line two
        line three #todo
      O
      setup = -> _ { o } # oh maman
      o
    end

    invocation = [ 'todo', 'find' ]

    define_method :invoke do |*argv|
      @pn = setup[ self ]
      invoke_from_tmpdir( *invocation, *argv )
    end

    def expect name, rx
      line = output.lines.shift
      line.name.should eql( name )
      line.string.should match( rx )
    end

    it "regular style - works, is hard to read" do
      invoke '-p', '#todo\>', '.'
      expect :pay, %r{^\./ferbis\.rb:2:beta #todo$}
      expect :pay, %r{jerbis/one.rb.*\b1\b}
      expect :pay, %r{jerbis/one\.rb.*\b3\b}
      expect :info, /found 3 items/
    end

    it "tree style - works" do
      invoke '-t', '-p', '#todo\>', '.'
      expect :info, /found 3 items/
      expect :pay, /\.$/
      expect :pay, /\bferbis\.rb\b/
      expect :pay, /2.*beta #todo/
      expect :pay, /\bjerbis\b/
      expect :pay, /\bone\.rb\b/
    end
  end
end
