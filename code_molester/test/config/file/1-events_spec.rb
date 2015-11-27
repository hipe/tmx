require_relative '../../test-support'

module Skylab::CodeMolester::TestSupport

  describe "[cm] config file events" do

    TS_[ self ]
    use :tmpdir
    use :config_file

    def build_config_file_

      x_a = []
      x = path
      if x
        x_a.push :path, x
      end

      x = input_string
      if x
        x_a.push :string, x
      end

      if x_a.length.zero?
        fail
      else
        config_file_class.new_via_iambic x_a
      end
    end

    def input_string
      NIL_
    end

    def path
      NIL_
    end

    context "reading a file that doesn't exist" do

      share_file_as_config_

      it "out of the box, you see full paths in the exception msg" do

        _rx = %r(\ANo such file or directory .+/not-here\.file\z)
        cfg = config

        begin
          cfg.read
        rescue ::Errno::ENOENT => e
        end

        e.message.should match _rx
      end

      it "capture such events" do

        cfg = config

        s = nil
        x = cfg.read do |o|
          o.no_ent = -> ev do
            s = ::File.basename( ev.path )
            :_jeepers_
          end
        end

        s.should eql 'not-here.file'
        x.should eql :_jeepers_
      end

      def path
        not_here_file_
      end
    end

    context "try to read a file when the path is actually a directory" do

      share_file_as_config_

      it "out of the box, raises a runtime error" do

        _rx = %r(.+/empty-esque-directory\.d» #{
          }exists but is not a file, it is a directory\b)

        o = config
        begin
          o.valid?
        rescue ::RuntimeError => e
        end

        e.message.should match _rx
      end

      it "if you defined a custom handler for read_error, result is that" do

        str = nil
        res = config.read do |on|
          on.read_error = -> ev do
            str = "oh noes: #{ ::File.basename( ev.path ) } was #{ ev.actual_ftype }"
            :nope
          end
        end

        str.should eql 'oh noes: empty-esque-directory.d was directory'
        res.should eql(:nope)
        # note that asking if 'valid?' will sill raise around the same issues
      end

      def path
        some_directory_
      end
    end

    context "when file (on disk) is invalid at line 1 column N" do

      share_file_as_config_

      it "not valid" do

        config_is_not_valid_
      end

      it "invalid reason cites file and line number" do

        _exp = 'Expecting "=" in boeuf.conf:1 at the end of "who h"'
        _act = config.invalid_reason.to_s
        _act.should eql _exp
      end

      it "eew (this needs expags)" do

        _rx = %r(\bin <<boeuf\.conf>>:1\b)

        _ = config.invalid_reason.render(
          escape_path: -> pn do
            "<<#{pn.basename}>>"
          end
        )

        _.should match _rx
      end

      def path

        tmpdir = self.tmpdir

        tmpdir.clear.patch <<-HERE.unindent
          diff --git a/boeuf.conf b/boeuf.conf
          new file mode 100644
          index 0000000..19364ae
          --- /dev/null
          +++ b/boeuf.conf
          @@ -0,0 +1 @@
          +who hah pow
        HERE
        # (result is `true`)

        ::File.join tmpdir.path, 'boeuf.conf'
      end
    end

    context "when string (not on disk) is invalid at line 1 column 1" do

      share_file_as_config_

      it "not valid" do
        config_is_not_valid_
      end

      it "invalid reason cites file and line number" do
        _exp = 'Expecting "#", "\n" or "[" at the beginning of line 1'
        _ = config.invalid_reason.to_s
        _.should eql _exp
      end

      def input_string
        '@foo = bar'
      end
    end

    context "on the use of `modified?`" do

      it "do not ask this of instances with no pathname" do

        _rx = /\bit is meaningless to ask\b/

        o = build_config_file_with_ :string, 'foo = bar'

        begin
          o.modified?
        rescue ::RuntimeError => e
        end

        e.message.should match _rx
      end

      it "do not ask this of instances that are not valid" do

        _rx = /\bthe wrong question to ask\b/

        _path = not_here_file_

        o = build_config_file_with_(
          :string, '@foo = bar',
          :path, _path,
        )

        begin
          o.modified?
        rescue ::RuntimeError => e
        end

        e.message.should match _rx
      end
    end

    context "valid string provided, path doesn't exist" do

      share_file_as_config_

      it "reports that it is valid" do
        config.valid?.should eql true
      end

      it "it reports that it is modified" do
        config.should be_modified
      end

      it "has not weirdly written itself to disk" do
        config.pathname.exist?.should eql false
      end

      def input_string
        "one = two\nthree = \"four five\""
      end

      def path
        not_here_file_
      end
    end

    context "creating a new file" do

      context "when the object is (or would be) valid" do

        def input_string
          'foo=bar'
        end

        context "when the target path does not exist" do

          context "when the containing dir exists" do

            dangerous_memoize :path do
              ::File.join tmpdir.path, 'some.conf'
            end

            context "when call `write` with no event handlers" do

              share_subject :_result_of_write do

                tmpdir.prepare

                _config = build_config_file_

                _x = _config.write

                _x
              end

              it "the path is written to" do

                _result_of_write
                path_exists_
              end

              it "result is the number of bytes" do

                _result_of_write.should eql 7
              end
            end

            context "when you call `write` with event handlers" do

              share_file_as_config_

              share_subject :_state_after_write do  # assume danger memo'd

                tmpdir.prepare

                _effect_common_state
              end

              it "the path now exists" do
                _state_after_write
                path_exists_
              end

              it "the before write event has the `path` member" do

                _o = _state_after_write
                _exp = path
                _act = _o.before_create_event.resource.path
                _act.should eql _exp
              end

              it "progressive output happens in order for both events" do

                _rx = %r(\Acreated «[^»]+» \(#{ _d } bytes\)\z)

                _o = _state_after_write
                black_and_white( _o.after_create_event ).should match _rx
              end

              it "the two events happend one before the other" do

                _rx = %r(\Acreating \(pth "[^"]+"\) \.\. done \(#{ _d } bytes\)\.\z)

                _o = _state_after_write

                _o.progressive_string.should match _rx
              end

              it "the result is the number of bytes written" do

                _o = _state_after_write
                _o.result_x.should eql _d
              end

              def _d
                7
              end
            end

            context "with `dry_run`" do

              share_file_as_config_

              share_subject :_state do  # assume danger memo

                _effect_common_state
              end

              it "the path was not written to" do
                path_does_not_exist_
              end

              it "after event still looks good" do

                _rx = %r(\Acreated «[^»]+» \(#{ _d } dry bytes\)\z)
                black_and_white( _state.after_create_event ).should match _rx
              end

              it "still results in the would-have-been number of bytes" do
                _state.result_x.should eql _d
              end

              def _d
                7
              end

              def path
                not_here_file_
              end

              def is_dry_run
                true
              end
            end
          end

          context "when the containing dir does not exist" do

            share_file_as_config_

            it "w/o an error handler, does not raise. results in false only" do

              _ = config
              _x = _.write
              _x.should eql false
            end

            it "you may want to set error handler (#todo the UI msg is unhelpful here)" do

              _rx = %r(\Aparent directory must exist - «[^»]+»\z)

              o = _effect_common_state
              o.result_x.should eql false
              black_and_white( o.error_event ).should match _rx
            end

            def path
              ::File.join not_here_directory_, 'some.conf'
            end
          end
        end
      end

      context "when the object is not valid" do

        def config
          build_config_file_
        end

        it "won't even let you try to write the thing, before it looks at fs" do

          _rx = %r(\battempt to write invalid\b)

          _o = _effect_common_state

          black_and_white( _o.error_event ).should match _rx
        end

        def input_string
          '@foo=bar'
        end

        def path
          '/never/see'
        end
      end
    end

    context "an archetypal use case - read file, make changes, write" do

      dangerous_memoize :path do
        ::File.join tmpdir.path, 'wiz.conf'
      end

      def self._share_state

        share_file_as_config_

        share_subject :_state do

          ___prepare_wiz_conf
          _effect_common_state
        end
      end

      def ___prepare_wiz_conf

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

        _share_state

        it "result is false" do

          _state.result_x.should eql false
        end

        it "error says it won't override a path that was not read first" do

          _rx = %r(\Asanity - won't overwrite a path that was not first read\b)

          black_and_white( _state.error_event ).should match _rx
        end

        def input_string
          'wiff=waff'
        end
      end

      context "no input string, only path. writing with no handlers" do

        _share_state

        it "having written the one element is reflected" do

          config[ 'foo' ].should eql 'baz'
        end

        it "unparses ok" do

          config.string.should eql "foo=baz\n"
        end

        it "content on filesystem looks OK" do

          _s = read_path_ _state.before_update_event.resource.path
          _s.should eql "foo=baz\n"
        end

        it "result is bytes written" do
          _state.result_x.should eql 8
        end

        def build_config_file_
          o = super
          o[ 'foo' ] = 'baz'
          o
        end
      end

      context "no input string, only path, writing with handlers" do

        _share_state

        it "result is 10 (bytes)" do

          _state.result_x.should eql _d
        end

        it "progressive string looks good" do

          _rx = %r(\bupdating \(pth "[^"]+wiz\.conf"\) #{
            }\.\. done \(#{ _d } bytes\)\.\z)

          _state.progressive_string.should match _rx
        end

        def _d
          10
        end

        def build_config_file_
          o = super
          o[ 'foo' ] = 'boffo'
          o
        end
      end
    end

    def _effect_common_state

      o = ___common_state_struct_class.new

      o.progressive_string = ''

      _x = config.write do |w|

        if is_dry_run
          w.dry_run = true
        end

        w.on_error do |ev|

          o.error_event = ev

          :_not_seen_
        end

        w.on_before_update do |ev|

          o.before_update_event = ev

          o.progressive_string.concat render_as_codified_ ev.renderable
        end

        w.on_before_create do |ev|

          o.before_create_event = ev

          o.progressive_string.concat render_as_codified_ ev.renderable
        end

        same = -> ev do
          " .. done (#{ ev.bytes } bytes)."
        end

        w.on_after_create do |ev|

          o.progressive_string << same[ ev ]

          o.after_create_event = ev
        end

        w.on_after_update do |ev|

          o.progressive_string << same[ ev ]

          o.after_update_event = ev
        end
      end

      o.result_x = _x
      o
    end

    memoize :___common_state_struct_class do

      CF_Common_State = ::Struct.new(

        :after_create_event,
        :after_update_event,
        :before_create_event,
        :before_update_event,
        :error_event,
        :progressive_string,
        :result_x,
      )
    end

    def is_dry_run
      false
    end
  end
end
