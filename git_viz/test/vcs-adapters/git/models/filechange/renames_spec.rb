require_relative '../../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - filechange - renames" do

    extend TS_
    use :story_01

    it "simple change looks good" do

      fc = _h.fetch 'simple-after.txt'
      fc.source_path.should eql 'simple-before.txt'
    end

    it "head-anchored change looks good" do

      fc = _h.fetch 'same-name.txt'
      fc.source_path.should eql 'from-here/same-name.txt'
      ::File.dirname( fc.destination_path ).should eql 'to-here'
    end

    it "tail-anchored change looks good" do

      fc = _h.fetch 'after-at-tail-of-path.txt'
      fc.source_path.should eql 'some-dir/before-at-tail-of-path.txt'
      ::File.dirname( fc.destination_path ).should eql 'some-dir'
    end

    it "infix change looks good" do

      fc = _h.fetch 'same-name-again.txt'
      fc.source_path.should eql 'lvl-1/lvl-2/same-name-again.txt'
      ::File.dirname( fc.destination_path ).should eql 'lvl-1/lvl-2-B'
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
        mock_system_conduit,
        stubbed_filesystem,
      )

      _repo.fetch_commit_via_identifier( 'head' ).filechanges.each do | fc |
        h[ ::File.basename fc.destination_path ] = fc
      end

      h
    end
  end
end
