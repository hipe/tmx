require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions

  # @todo waiting for permute [#056]
  #

  describe "[tm] CLI action `status`", tanman: true, cli_action: true, wip: true do

    extend TS_

    def prepare_configs *whichs
      prepare_tanman_tmpdir
      whichs.each do |which|
        case which
        when :global
          TMPDIR.touch('global-conf-file')
        when :local_dir
          TMPDIR.mkdir('local-conf.d')
        when :local_file
          TMPDIR.touch('local-conf.d/config')
        else
          fail("no")
        end
      end
    end

    def match_one str
      input 'status'
      re = ::Regexp.new( /\A#{ ::Regexp.escape str }/ )
      lines = output.lines.map(&:string).select { |s| re =~ s }
      lines.size.should eql(1)
      lines.first
    end

    context 'no global' do
      before :each do
        prepare_configs
      end
      it "says that global not found" do
        match_one('global ').should match(/global.+not found/)
      end
    end

    context 'yes global' do
      before :each do
        prepare_configs :global
      end
      it 'says that global exists' do
        match_one('global ').should be_include('global-conf-file')
      end
    end

     context 'no local dir' do
      it 'says that local not found' do
        prepare_configs
        match_one('local ').should be_include('local conf dir not found')
      end
    end

    context 'yes local dir no file' do
      before :each do
        prepare_configs :local_dir
      end
      it 'should list the directory (*with a trailing slash*)' do
        match_one('local ').should be_include('local-conf.d/')
      end
    end

    context 'yes local dir yes file' do
      before :each do
        prepare_configs :local_dir, :local_file
      end
      it 'should herp a derp' do
        match_one('local ').should be_include('local-conf.d/config')
      end
    end

    context 'yes local dir as file' do
      before :each do
        prepare_tanman_tmpdir.touch('local-conf.d')
      end
      it 'complain that a folder was expected where a file was found' do
        input 'status'
        output.lines[0].string.should match(/not a directory.+local-conf\.d/)
        output.lines[1].string.should be_include('local conf dir not found')
      end
    end
  end
end
