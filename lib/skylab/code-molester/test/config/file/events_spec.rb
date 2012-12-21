require_relative 'test-support'

module Skylab::CodeMolester::TestSupport::Config::File
  extend TestSupport::Quickie # try running this file just with `ruby -w`

  describe "#{ CodeMolester::Config::File } events" do
    extend File_TestSupport


    def self.expect desc, exp, *tags, &block
      it "#{ desc } - #{ exp }", *tags do
        instance_exec exp, &block
      end
    end


    context "reading a file that doesn't exist" do

      let :o do
        config_file_new path: tmpdir.join( 'not-exist.conf' )
      end


      expect "out of the box, does not tell you full pathnames",
        'No such file or directory - not-exist.conf' do |exp|

        begin o.read { |o| } ; rescue ::Errno::ENOENT => e ; end
        e.message.should eql(exp)
      end

      it "with a custom `escape_path` lamda, display e.g. full pathnames" do
        begin
          o.read do |o|
            o.escape_path = ->( pn ) { "--> #{ pn.to_s } <--" }
          end
        rescue ::Errno::ENOENT => e
        end
        e.message.should match(
          %r{\ANo such file or directory - --> .+co-mo/not-exist.conf <--\z} )
      end
    end


    context "try to read a file when the path is actually a directory" do

      let :o do
        tmpdir.clear.mkdir 'some-dir' # sorry
        config_file_new path: tmpdir.join( 'some-dir' )
      end

      it "out of the box, raises a runtime error" do
        -> { o.valid? }.should raise_error(
          ::RuntimeError,
          /expected config file to be of type 'file', had directory - some-dir/
        )
      end

      it "if you defined a custom hander for read_error, result is that" do
        str = nil
        res = o.read do |x|
          x.read_error = -> pathname, type do
            str = "oh noes: #{ pathname.basename } was #{ type }"
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

      config_file_new path: tmpdir.join('boeuf.conf')
      b = o.valid?
      b.should eql(false)
      str = o.invalid_reason.to_s
      str.should eql( exp )
      str = o.invalid_reason.render escape_path: -> pn { "<<#{pn.basename}>>" }
      str.should match( /in <<boeuf\.conf>>:1/ )
    end

    expect "when string (not on disk) is invalid at line 1 column 1",
      'Expecting "#", "\n" or "[" at the beginning of line 1' do |x|
      config_file_new string: '@foo = bar'
      b = o.valid?
      b.should eql(false)
      str = o.invalid_reason.to_s
      str.should eql(x)
    end


    context "on the use of `modified?`" do

      it "do not ask this of instances with no pathname" do
        config_file_new string: 'foo = bar'
        ->{ o.modified? }.should raise_error( ::RuntimeError,
          /it is meaningless to ask/ )
      end

      it "do not ask this of instances that are not valid" do
        config_file_new string: '@foo = bar', path: tmpdir.join( 'some.conf' )
        ->{ o.modified? }.should raise_error( ::RuntimeError,
          /the wrong question to ask/ )
      end
    end


    context "valid string provided, path doesn't exist" do

      let :o do
        config_file_new path: pathname.to_s,
          string: "one = two\nthree = \"four five\""
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
          config_file_new string: 'foo=bar', path: path
        end

        context "when the target path does not exist" do
          context "when the containing dir exists - works" do
            let :path do
              tmpdir.join 'some.conf'
            end

            it "when calling `write` with no event handlers" do
              tmpdir.clear # ick
              path.exist?.should eql(false)
              res = o.write
              res.should eql(7) # the number of bytes written!
              path.exist?.should eql(true)
            end

            it "when calling `write` with some event handlers" do
              tmpdir.clear # ick
              path.exist?.should eql(false)
              str1 = '' ; ohai = str2 = nil
              res = o.write do |em|
                em.escape_path = ->( pn ) { "~~{ #{ pn.basename } }~~" }
                em.on_before_create do |e|
                  ohai = e.resource.pathname.basename.to_s
                  str1 << e.message
                end
                em.on_after_create do |e|
                  str1 << " .. done (#{ e.bytes } bytes)."
                  str2 = e.message
                end
              end
              ohai.should eql('some.conf')
              res.should eql(7) # the number of bytes written!
              str1.should eql('creating ~~{ some.conf }~~ .. done (7 bytes).')
              str2.should eql('created ~~{ some.conf }~~ (7 bytes)')
            end
          end


          context "when the containing dir does not exist" do
            let :path do
              tmpdir.join 'some-dir-not-there/some.conf'
            end

            it "raises runtime error" do
              ->{ o.write }.should raise_error( ::RuntimeError,
               /parent directory does not exist, cannot write.+co-mo/ )
            end
          end
        end
      end


      context "when the object is not valid" do

        let :o do
          config_file_new string: '@foo=bar', path: '/never/see'
        end

        it "won't even let you try to write the thing, before it looks at fs" do
          -> { o.write }.should raise_error( ::RuntimeError,
                                            /attempt to write invalid/ )
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
          config_file_new path: path, string: 'wiff=waff'
          o.valid?.should eql(true)
          ->{ o.write }.should raise_error( ::RuntimeError,
            /won't overwrite a pathname that was not first read/i
          )
        end
      end


      context "with only path (of file that existed)" do


        it "`write` works with no event handlers, result is bytes" do
          prepare_wiz_conf
          path.exist?.should eql(true)
          config_file_new path: path
          o.exist?.should eql(true)
          o['foo'].should eql('bar')
          o['foo'] = 'baz'
          o['foo'].should eql('baz')
          o.string.should eql("foo=baz\n")
          b = o.write
          b.should eql(8)
          o.pathname.read.should eql("foo=baz\n")
        end

        it "`write` works with event handlers" do
          prepare_wiz_conf
          config_file_new path: path
          o['foo'] = 'boffo'
          str = ''
          res = o.write do |em|
            em.on_before_edit do |e|
              str << "updating #{ e.resource.pathname.basename }"
            end
            em.on_after_edit do |e|
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
