require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - to-do - actions - to stream", wip: true do

    extend TS_

    with_invocation 'todo', 'find'

    with_tmpdir do |o|
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
    end

    it "regular style - works, is hard to read" do
      setup_tmpdir_read_only
      invoke '-p', "##{}todo\\>", '.'
      expect :pay, %r{^\./ferbis\.rb:2:beta ##{}todo$}
      expect :pay, %r{jerbis/one.rb.*\b1\b}
      expect :pay, %r{jerbis/one\.rb.*\b3\b}
      expect :info, /found 3 items/
    end

    it "tree style - works" do
      setup_tmpdir_read_only
      invoke '-t', '-p', "##{}todo\\>", '.'
      expect :info, /found 3 items/
      expect :pay, /\.$/
      expect :pay, /\bferbis\.rb\b/
      expect :pay, /2.*beta ##{}todo/
      expect :pay, /\bjerbis\b/
      expect :pay, /\bone\.rb\b/
    end

    it "show command - works" do
      setup_tmpdir_read_only
      invoke '--cmd', '.'
      expect :pay, /\Afind .+ grep\b/
    end

    context "pretty tree style" do

      with_tmpdir do |o|
        o.clear
        o.write 'meeple.rb', <<-O.unindent
          one # %delegates %todo:#100.200.1
        O
        nil
      end

      it "colorizes pretty -tt style even if ##{}todo is not at beginning" do
        invoke '-p', '%todo\>', '-tt', '.'
        output.lines.first.string.should match( /found 1 /)
      end
    end
  end
end
