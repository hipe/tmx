require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI
  # @todo waiting for permute [#056]
  #

  describe "The #{TanMan::CLI} action Status", tanman: true,
                                           cli_action: true do
    extend CLI_TestSupport
    include Tmpdir::InstanceMethods

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
      re = Regexp.new(/\A#{Regexp.escape str}/)
      lines = output.map(&:string).select { |s| re =~ s }
      lines.size.should eql(1)
      lines.first
    end

    context 'no global' do
      before { prepare_configs }
      it "says that global not found" do
        match_one('global ').should match(/global.+not found/)
      end
    end

    context 'yes global' do
      before { prepare_configs :global }
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
      before { prepare_configs :local_dir }
      it 'should list the directory (*with a trailing slash*)' do
        match_one('local ').should be_include('local-conf.d/')
      end
    end

    context 'yes local dir yes file' do
      before { prepare_configs :local_dir, :local_file }
      it 'should herp a derp' do
        match_one('local ').should be_include('local-conf.d/config')
      end
    end

    context 'yes local dir as file' do
      before do
        prepare_tanman_tmpdir.touch('local-conf.d')
      end
      it 'complain that a folder was expected where a file was found' do
        input 'status'
        output[0].string.should match(/not a directory.+local-conf\.d/)
        output[1].string.should be_include('local conf dir not found')
      end
    end
  end
end
