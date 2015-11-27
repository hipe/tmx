require_relative '../../test-support'

module Skylab::CodeMolester::TestSupport

  describe "[cm] config file edge" do

    TS_[ self ]
    use :config_file

    context "B-asic overall grammar check:" do

      context "grammar check: many values" do

        it "parses and unparses OK" do
          parses_and_unparses_OK_
        end

        memoize :input_string do
          "a=b\nc=d\ne=f"
        end
      end

      context "grammar check: one section" do

        it "parses and unparses OK" do
          parses_and_unparses_OK_
        end

        memoize :input_string do
          '[nerp]'
        end
      end

      context "grammar check: two sections" do

        it "parses and unparses OK" do
          parses_and_unparses_OK_
        end

        memoize :input_string do
          "[nerp]\n[derp]"
        end
      end

      context "grammar check: blearg" do

        it "parses and unparses OK" do
          parses_and_unparses_OK_
        end

        memoize :input_string do
          "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]\nfoo = buz"
        end
      end
    end

    context "with a file with some sections" do

      share_file_as_config_

      memoize :input_string do
        "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]\nfoo = buz"
      end

      it "parses and unparses OK" do
        parses_and_unparses_OK_
      end

      it "get child value OK" do
        config[ 'bizzo' ][ 'foo' ].should eql 'biz'
      end
    end

    def config
      build_config_file_
    end

    def path
      NIL_
    end
  end
end
