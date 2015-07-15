require_relative '../../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] services - filesystem - bridges - patch - model" do

    extend TS_

    it 'loads' do
      patch
    end

    context "changes (\"c\")" do

      it "two non-contiguous single lines" do

        pa = _new_patch_via_file_content_before "one\ntwo\nthree"

        pa.change_line 1, 'ONE'
        pa.change_line 3, 'THREE'

        _to_s( pa ).should eql <<-O.unindent
          1c1
          < one
          ---
          > ONE
          3c3
          < three
          ---
          > THREE
        O
      end

      it "at end change one line to two" do

        pa = _new_patch_via_file_content_before "one\ntwo"

        pa.change_lines 2, [ 'TWO', 'THREE' ]

        _to_s( pa ).should eql <<-O.unindent
          2c2,3
          < two
          ---
          > TWO
          > THREE
        O
      end
    end

    context "removes (\"d\")" do

      it "two non-contiguous inner chunks" do

        pa = _new_patch_via_file_content_before "one\ntwo\nthree\nfour\nfive\nsix\nseven"

        pa.change_lines 2..4, EMPTY_A_
        pa.change_lines 6, EMPTY_A_

        _to_s( pa ).should eql <<-O.unindent
          2,4d1
          < two
          < three
          < four
          6d2
          < six
        O
      end

      it "two at beginning" do

        pa = _new_patch_via_file_content_before "one\ntwo\nthree"

        pa.change_lines 1..2, EMPTY_A_

        _to_s( pa ).should eql <<-O.unindent
          1,2d0
          < one
          < two
        O
      end

      it "one at end" do

        pa = _new_patch_via_file_content_before "one\ntwo\nthree"

        pa.change_lines 3, EMPTY_A_

        _to_s( pa ).should eql <<-O.unindent
          3d2
          < three
        O
      end
    end

    context "adds (\"a\")" do

      it "two in middle" do

        pa = _new_patch_via_file_content_before "one\ntwo\nfive\nsix"

        pa.change_lines 3...3, [ 'three', 'four' ]

        _to_s( pa ).should eql <<-O.unindent
          2a3,4
          > three
          > four
        O
      end

      it "one at begin" do

        pa = _new_patch_via_file_content_before "two\nthree"

        pa.change_lines 1...1, [ 'one' ]

        _to_s( pa ).should eql "0a1\n> one\n"
      end

      it "one at end" do

        pa = _new_patch_via_file_content_before "one\ntwo"

        pa.change_lines 3...3, [ 'three' ]

        _to_s( pa ).should eql "2a3\n> three\n"
      end

    end

    def _new_patch_via_file_content_before whole_file_s

      real_filesystem_.patch.new_via_file_content_before whole_file_s
    end

    def _to_s pa
      pa.to_patch_string
    end

    def patch
      services_.filesystem.patch
    end
  end
end
