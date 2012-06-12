require_relative 'test-support'

module Skylab::Treemap
  describe "The Treemap Module's CLI" do
    include TestSupport

    let(:tmx_cli)    { build_tmx_cli    }
    let(:out_stream) { build_stream_spy }
    let(:err_stream) { build_stream_spy }

    it "is available under the 'tmx' executable" do
      tmx_cli.run(['-h'])
      out_string.scan(/^ +treemap\b/).size.should eql(1)
    end

    context "of the actions that it lists in the help screen, it" do
      let(:names) do
        tmx_cli.run(['treema', '-h'])
        scn = StringScanner.new(err_string)
        scn.skip_until(/\nactions:\n/) or fail('failed to find "actions:" section')
        names = []
        while line = scn.scan(/^[[:space:]].*\n/) do
          if md = line.match(/^[[:space:]]+([-a-z]+)*/) # weak!
            names.push md[1]
          end
        end
        names
      end
      subject { names }
      specify { should be_include('install') }
    end
  end
end

