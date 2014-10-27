require_relative 'test-support'

module Skylab::CodeMolester::TestSupport::Config::File

  describe "[cm] config file edge (actualy just old rspec-only tests)" do  # :+#rspec-only because: specify is too crazy

    extend TS_

    context "B-asic overall grammar check:" do

      context "grammar check: many values" do

        let :content do
          "a=b\nc=d\ne=f"
        end

        specify do
          parses_and_unparses_OK
        end
      end

      context "grammar check: one section" do

        let :content do
          '[nerp]'
        end

        specify do
          parses_and_unparses_OK
        end
      end

      context "grammar check: two sections" do

        let :content do
          "[nerp]\n[derp]"
        end

        specify do
          parses_and_unparses_OK
        end
      end

      context "grammar check: blearg" do

        let :content do
          "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]\nfoo = buz"
        end

        specify do
          parses_and_unparses_OK
        end
      end
    end

    context "with a file with some sections" do

      let :content do
        "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]\nfoo = buz"
      end

      specify do
        parses_OK
      end

      context "when you use [] to get a section that exists" do

        let :subject do
          config[ 'bizzo' ]
        end

        specify do
          subject.should be_respond_to :get_names
        end

        specify do
          subject.section_name.should eql 'bizzo'
        end

        context "when you use [] to get a child value that exists" do
          it "works" do
            o = subject[ 'foo' ]
            o.should eql 'biz'
          end
        end
      end
    end
  end
end
