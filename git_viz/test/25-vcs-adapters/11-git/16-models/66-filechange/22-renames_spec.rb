require_relative '../../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - filechange - renames" do

    TS_[ self ]
    use :story_01

    it "simple change looks good" do

      fc = _h.fetch 'simple-after.txt'
      expect( fc.source_path ).to eql 'simple-before.txt'
    end

    it "head-anchored change looks good" do

      fc = _h.fetch 'same-name.txt'
      expect( fc.source_path ).to eql 'from-here/same-name.txt'
      expect( ::File.dirname fc.destination_path ).to eql 'to-here'
    end

    it "tail-anchored change looks good" do

      fc = _h.fetch 'after-at-tail-of-path.txt'
      expect( fc.source_path ).to eql 'some-dir/before-at-tail-of-path.txt'
      expect( ::File.dirname fc.destination_path ).to eql 'some-dir'
    end

    it "infix change looks good" do

      fc = _h.fetch 'same-name-again.txt'
      expect( fc.source_path ).to eql 'lvl-1/lvl-2/same-name-again.txt'
      expect( ::File.dirname fc.destination_path ).to eql 'lvl-1/lvl-2-B'
    end

    define_method :_h, -> do
      x = nil
      -> do
        x ||= __produce_hash
      end
    end.call

    def __produce_hash

      h = {}

      _repo = Home_.repository.new_via(
        '/the/repo',
        stubbed_system_conduit,
        stubbed_filesystem,
      )

      _repo.fetch_commit_via_identifier( 'head' ).filechanges.each do | fc |
        h[ ::File.basename fc.destination_path ] = fc
      end

      h
    end
  end
end
