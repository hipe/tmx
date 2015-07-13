require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - filesystem - flock first avail[..]" do

    extend TS_

    it "simple - OK" do
      _init_tmppdir
      f = _same
      ::File.basename( f.path ).should eql 'foo.yep'
      _cleanup f

    end

    it "when first file is occupied" do
      _init_tmppdir
      @td.touch 'foo.yep'  # (pn)
      f = _same
      ::File.basename( f.path ).should eql 'foo-02.yep'
      _cleanup f
    end

    def _init_tmppdir

      fs = services_.filesystem

      _path = ::File.join fs.tmpdir_path, 'hl-flock-etc'

      @td = fs.tmpdir(
        :path, _path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )

      @td.clear

      nil
    end

    def _same
      _subject.call_with(
        :first_item_does_not_use_number,
        :beginning_width, 2,
        :template, '{{ head }}{{ sep if ID }}{{ ID }}{{ ext }}',
        :head, "#{ @td.to_path }/foo",
        :sep, '-',
        :ext, '.yep' )
    end

    def _cleanup f
      f.close
      ::FileUtils.rm f.path
      nil
    end

    def _subject
      services_.filesystem.flock_first_available_path
    end
  end
end
