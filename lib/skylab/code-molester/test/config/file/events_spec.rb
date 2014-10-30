require_relative 'test-support'

module Skylab::CodeMolester::TestSupport::Config::File

  describe "[cm] config file events" do

    extend TS_

    def self.expect desc, exp, *tags, &block
      it "#{ desc } - #{ exp }", *tags do
        instance_exec exp, &block
      end
    end

    context "reading a file that doesn't exist" do

      let :o do
        build_config_file_with :path, tmpdir.join( 'not-exist.conf' )
      end

      it "out of the box, you see full paths in the exception msg" do
        _rx = %r(\ANo such file or directory .+/not-exist\.conf\z)
        -> do
          o.read
        end.should raise_error ::Errno::ENOENT, _rx
      end

      it "capture such events" do
        s = nil
        x = o.read do |o|
          o.no_ent = -> ev do
            s = ev.pathname.basename.to_s
            :_jeepers_
          end
        end
        s.should eql 'not-exist.conf'
        x.should eql :_jeepers_
      end
    end

    context "try to read a file when the path is actually a directory" do

      before :each do
        tmpdir.clear.mkdir 'some-dir' # sorry
        init_o_with :path, tmpdir.join( 'some-dir' )
      end

      it "out of the box, raises a runtime error" do

        _rx = %r(.+/some-dir\W exists but is not a file, it is a directory\b)

        -> do
          o.valid?
        end.should raise_error _rx
      end

      it "if you defined a custom handler for read_error, result is that" do
        str = nil
        res = o.read do |on|
          on.read_error = -> ev do
            str = "oh noes: #{ ::File.basename( ev.path ) } was #{ ev.actual_ftype }"
            :nope
          end
        end
        str.should eql('oh noes: some-dir was directory')
        res.should eql(:nope)
        # note that asking if 'valid?' will sill raise around the same issues
      end
    end

    expect "when file (on disk) is invalid at line 1 column N",
      'Expecting "=" in boeuf.conf:1 at the end of "who h"' do |exp|

      tmpdir.clear.patch <<-HERE.unindent
        diff --git a/boeuf.conf b/boeuf.conf
        new file mode 100644
        index 0000000..19364ae
        --- /dev/null
        +++ b/boeuf.conf
        @@ -0,0 +1 @@
        +who hah pow
      HERE

      init_o_with :path, tmpdir.join('boeuf.conf')
      b = o.valid?
      b.should eql(false)
      str = o.invalid_reason.to_s
      str.should eql( exp )
      str = o.invalid_reason.render escape_path: -> pn { "<<#{pn.basename}>>" }
      str.should match( /in <<boeuf\.conf>>:1/ )
    end

    expect "when string (not on disk) is invalid at line 1 column 1",
      'Expecting "#", "\n" or "[" at the beginning of line 1' do |x|
      init_o_with :string, '@foo = bar'
      b = o.valid?
      b.should eql(false)
      str = o.invalid_reason.to_s
      str.should eql(x)
    end

    context "on the use of `modified?`" do

      it "do not ask this of instances with no pathname" do
        init_o_with :string, 'foo = bar'
        ->{ o.modified? }.should raise_error( ::RuntimeError,
          /it is meaningless to ask/ )
      end

      it "do not ask this of instances that are not valid" do
        init_o_with :string, '@foo = bar', :path, tmpdir.join( 'some.conf' )
        ->{ o.modified? }.should raise_error( ::RuntimeError,
          /the wrong question to ask/ )
      end
    end

    context "valid string provided, path doesn't exist" do

      let :o do
        build_config_file_with :path, pathname.to_s,
          :string, "one = two\nthree = \"four five\""
      end

      let :pathname do
        tmpdir.join 'weee.conf'
      end

      it "reports itself as valid, modified" do
        tmpdir.prepare  # #ick sorry
        pathname.exist?.should eql(false)
        o.valid?.should eql(true)
        pathname.exist?.should eql(false) # does not weirdly write self to disk
        o.modified?.should eql(true)
      end
    end

    context "creating a new file" do

      context "when the object is (or would be) valid" do

        let :o do
          build_config_file_with :string, 'foo=bar', :path, path
        end

        context "when the target path does not exist" do

          context "when the containing dir exists" do

            let :path do
              tmpdir.join 'some.conf'
            end

            it "when calling `write` with no event handlers - works" do
              tmpdir.clear # ick
              path.exist?.should eql(false)
              res = o.write
              res.should eql(7) # the number of bytes written!
              path.exist?.should eql(true)
            end

            it "when calling `write` with some event handlers - works" do
              tmpdir.clear # ick
              path.exist?.should eql(false)
              str1 = '' ; ohai = str2 = nil
              res = o.write do |w|
                w.on_before_create do |e|
                  ohai = e.resource.pathname.basename.to_s
                  str1.concat render_as_codified e.renderable
                end
                w.on_after_create do |ev|
                  str1 << " .. done (#{ ev.bytes } bytes)."
                  str2 = black_and_white ev
                end
              end
              ohai.should eql('some.conf')
              res.should eql(7) # the number of bytes written!

              str1.should match %r(\Acreating \(pth "[^"]+"\) \.\. done \(#{ num_bytes } bytes\)\.\z)
              str2.should match %r(\Acreated «[^»]+» \(7 bytes\)\z)

              path.exist?.should eql( true )
            end

            it "when employing `dry_run` - does not write file" do
              tmpdir.clear  # ick
              path.exist?.should eql( false )
              yep = nil
              o = self.o
              bytes = o.write do |w|
                w.dry_run = true
                w.on_after_create do |ev|
                  yep = black_and_white ev
                end
              end
              bytes.should be_kind_of( ::Fixnum )
              yep.should match %r(\Acreated «[^»]+» \(#{ num_bytes } dry bytes\)\z)
              path.exist?.should eql( false )
            end
          end

          context "when the containing dir does not exist" do

            let :path do
              tmpdir.join 'some-dir-not-there/some.conf'
            end

            it "does not raise a runtime error - just results in false" do
              x = o.write
              x.should eql false
            end

            it "you may want to set error handler (#todo the UI msg is unhelpful here)" do
              s = nil
              x = o.write do |w|
                w.on_error do |ev|
                  s = black_and_white ev
                  :_not_seen_
                end
              end
              x.should eql false
              # _rx = /parent directory does not exist, will not write.+co-mo/
              s.should match %r(\ANo such file or directory - «[^»]+»\z)
            end
          end

          def num_bytes
            7
          end
        end
      end

      context "when the object is not valid" do

        let :o do
          build_config_file_with :string, '@foo=bar', :path, '/never/see'
        end

        it "won't even let you try to write the thing, before it looks at fs" do
          s = nil
          o.write do |w|
            w.on_error do |ev|
              s = black_and_white ev
            end
          end
          s.should match %r(\battempt to write invalid\b)
        end
      end
    end

    context "an archetypal use case - read file, make changes, write" do

      let :path do
        tmpdir.join 'wiz.conf'
      end

      def prepare_wiz_conf
        tmpdir.clear.patch <<-HERE.unindent
          diff --git a/wiz.conf b/wiz.conf
          new file mode 100644
          index 0000000..74d0a43
          --- /dev/null
          +++ b/wiz.conf
          @@ -0,0 +1 @@
          +foo=bar
        HERE
      end

      context "when both path and string, and path existed" do

        it 'raises an exception talking about "won\'t overwrite"' do
          prepare_wiz_conf
          init_o_with :path, path, :string, 'wiff=waff'
          o.valid?.should eql(true)
          s = nil
          x = o.write do |w|
            w.on_error do |ev|
              s = black_and_white ev
            end
          end
          x.should eql false
          s.should match %r(\Asanity - won't overwrite a path that was not first read\b)
        end
      end

      context "with only path (of file that existed)" do

        it "`write` works with no event handlers, result is bytes" do
          prepare_wiz_conf
          path.exist?.should eql(true)
          init_o_with :path, path
          o.exist?.should eql(true)
          o['foo'].should eql('bar')
          o['foo'] = 'baz'
          o['foo'].should eql('baz')
          o.string.should eql("foo=baz\n")

          s = nil
          x = o.write do |w|
            w.on_error do |ev|
              s = black_and_white ev
            end
          end
          s.should be_nil
          x.should eql 8
          o.pathname.read.should eql("foo=baz\n")
        end

        it "`write` works with event handlers" do
          prepare_wiz_conf
          init_o_with :path, path
          o['foo'] = 'boffo'
          str = ''
          res = o.write do |w|
            w.on_before_update do |e|
              str << "updating #{ e.resource.pathname.basename }"
            end
            w.on_after_update do |e|
              str << " .. done (#{ e.bytes } bytes)."
            end
          end
          res.should eql(10)
          str.should eql("updating wiz.conf .. done (10 bytes).")
        end
      end
    end
  end
end
