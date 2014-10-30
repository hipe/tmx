require_relative 'cli/test-support'

module Skylab::Flex2Treetop::MyTestSupport

  describe "[f2] CLI" do

    extend CLI::ModuleMethods ; include CLI::InstanceMethods

    context "the cannon" do

      it "0    with no args - explain what's expected" do
        invoke
        expect :styled, /\Aexpecting <flexfile> or STDIN\z/
        expect :styled, /\Ause .+ for help\z/
        expect_failed
      end

      it "1.2  with one nonsensical option - explain option not valid" do
        invoke '-x'
        expect %r(\binvalid option: -x\b)i
        expect_usage_and_invite
      end

      it "1.3   with the -h help flag - display help screen" do
        invoke '-h'
        expect_full_help_screen
      end

      def expect_full_help_screen
        expect :styled, /\busage: xyzzy .{24,} <flexfile>/i
        expect_blank
        expect_header :options
        count = skip_contiguous_chopped_lines_that_match %r(\A[[:space:]])
        ( 15 .. 19 ).should be_include count
        expect_succeeded
      end

      it "1.4  ping simple" do
        invoke '--ping'
        expect 'hello from flex2treetop.'
        expect_no_more_lines
        @result.should eql :hello_from_flex2treetop
      end

      it "2.4  ping with argument" do
        invoke '--ping=boo'
        @result.should eql '(boo)'
      end
    end

    context "API integration" do

      it "ping the API with an argument" do
        invoke '--ping=howdy', '--API'
        expect 'helo:(howdy)'
        expect_no_more_lines
        @result.should eql :_hello_from_API_
      end
    end

    context "business" do

      it "1.1  with one giberrsh arg - explain that file is not found" do
        invoke 'not-there.txt'
        expect :styled, %r(\ANo such <flexfile> - «not-there\.txt»\z)
        expect_invite
      end

      it "1.4  read flexfile, write treetop grammar to stdout" do
        invoke fixture :mini
        expect %r(\Aoutputting «paystream» with [^ ]+/mini\.flex\z)
        change_line_source_channel_to :stdout
        expect %r(\A# Autogenerated by fle)
        expect '# from flex name definitions'
        expect 'rule escape'
        num = skip_until_last_N_lines 3
        num.should eql 9
        expect 'rule _ignore_comments_'
        expect %r(\A {1,}[\[\] "\\/*^+()]+\z)
        expect 'end'
        change_line_source_channel_to :stderr
        expect %r(\bCan't deduce\b)i
        expect_no_more_lines
        @result.should be_zero
      end
    end
  end
end
