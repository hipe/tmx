require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  # le Quickie.

  describe "[sg] CLI actions todo find" do
    extend Actions_TestSupport

    setup = -> ctx do
      o = ctx.tmpdir_clear
      o.write 'ferbis.rb', <<-O.unindent
        alpha
        beta ##{}todo
        gamma
      O
      o.write 'jerbis/one.rb', <<-O.unindent
        line one ##{}todo
        line two
        line three ##{}todo
      O
      setup = -> _ { o } # oh maman
      o
    end

    define_method :setup do setup[ self ] end

    invocation = [ 'todo', 'find' ]

    define_method :invoke do |*argv|
      @pn = self.setup
      invoke_from_tmpdir( *invocation, *argv )
    end

    def expect name, rx
      line = output.lines.shift
      line.stream_name.should eql( name )
      line.string.should match( rx )
    end

    it "regular style - works, is hard to read" do
      invoke '-p', "##{}todo\\>", '.'
      expect :pay, %r{^\./ferbis\.rb:2:beta ##{}todo$}
      expect :pay, %r{jerbis/one.rb.*\b1\b}
      expect :pay, %r{jerbis/one\.rb.*\b3\b}
      expect :info, /found 3 items/
    end

    it "tree style - works" do
      invoke '-t', '-p', "##{}todo\\>", '.'
      expect :info, /found 3 items/
      expect :pay, /\.$/
      expect :pay, /\bferbis\.rb\b/
      expect :pay, /2.*beta ##{}todo/
      expect :pay, /\bjerbis\b/
      expect :pay, /\bone\.rb\b/
    end

    it "show command - works" do
      invoke '--cmd', '.'
      expect :pay, /\Afind .+ grep\b/
    end

    context "pretty tree style" do

      def setup
        ctx = self
        o = ctx.tmpdir_clear
        o.write 'meeple.rb', <<-O.unindent
          one # %delegates %todo:#100.200.1
        O
        o
      end

      it "colorizes pretty -tt style even if ##{}todo is not at beginning" do
        invoke '-p', '%todo\>', '-tt', '.'
        output.lines.first.string.should match( /found 1 /)
      end
    end
  end
end
