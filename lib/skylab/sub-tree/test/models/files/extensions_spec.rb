require_relative '../../../test-support'  # #change-this-at-step:8

module Skylab::SubTree::TestSupport

  _CROOK = '└──'
  _TEE = '├──'
  _UNIT = '[acdehikmnorswy]{1,3}'

    _MTIME = "\\d+ #{ _UNIT }"

  describe "[st] API actions my-tree multi-buffer", wip: true do

    extend TS_

    it "an in-notify extension - `mtime`" do
      f = start_front.with_parameters :path_a, [ 'one' ], :mtime, true
      r = nil ; SubTree_::Library_::FileUtils.cd fixtures_dir_pn do
        r = f.flush
      end
      @e.string.should be_empty
      @a = @o.string.split "\n"
      line.should eql 'one'
      glyph_and_rest _TEE, /\Afoo\.rb #{ _MTIME }\z/
      glyph_and_rest _CROOK, /\Atest\z/
      glyph_and_rest _CROOK, /\Afoo_spec\.rb #{ _MTIME }\z/
      expect_no_more_lines
      r.should eql true
    end

    def glyph_and_rest exp_glyph, rx
      glyph, rest = line.split SPACE_, 2
      glyph.should eql exp_glyph
      rest.should match rx
    end

    it "a multi-buffer extension - `line count`" do
      f = start_front.with_parameters :path_a, [ 'one' ], :line_count, true
      r = nil ; SubTree_::Library_::FileUtils.cd fixtures_dir_pn do
        r = f.flush
      end
      @e.string.should be_empty
      a = @o.string.split "\n"
      a.shift.should eql "one                        "
      a.shift.should eql "├── foo.rb           1 line"
      a.shift.should eql "└── test                   "
      a.shift.should eql "    └── foo_spec.rb  1 line"
      r.should eql true
    end

    it "a in-notify extension and a mutli-buffer extension" do
      f = start_front.with_parameters :path_a, [ 'one' ], :line_count, true,
        :mtime, true
      r = nil ; SubTree_::Library_::FileUtils.cd fixtures_dir_pn do
        r = f.flush
      end
      @e.string.should be_empty
      @a = @o.string.split "\n"
      line.strip.should eql 'one'
      glyph_and_rest _TEE, /\Afoo\.rb[ ]{2,}#{ _MTIME } 1 line\z/
      glyph_and_rest _CROOK, /\Atest[ ]{10,}\z/
      glyph_and_rest _CROOK, /\Afoo_spec\.rb[ ]{2,}#{ _MTIME } 1 line\z/
      expect_no_more_lines
      r.should eql true
    end
  end
end
