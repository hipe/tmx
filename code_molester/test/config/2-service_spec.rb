require_relative '../test-support'

module Skylab::CodeMolester::TestSupport

  describe "[cm] config service" do

    TS_[ self ]

    context "provide some arguments" do

      memoize :__require_constants do

        module SVC_1
          class Client
            Home_::Config::Service.enhance self do
              filename 'foo.config'
              search_num_dirs do 3 end
            end
          end
        end
        NIL_
      end

      it "you can retrieve them" do

        __require_constants

        c = SVC_1::Client.new
        c.config.filename.should eql( 'foo.config' )
        c.config.search_num_dirs.should eql( 3 )
      end
    end

    context "just accept raw defaults" do

      memoize :__require_constants do

        module SVC_2
          class Client
            Home_::Config::Service.enhance self
          end
        end
        NIL_
      end

      share_subject :cfg do

        __require_constants
        _ = SVC_2::Client.new
        _.config
      end

      memoize :_pwd do
        ::Dir.pwd   # EEW
      end

      it "the number of search dirs is 3 !!??" do

        _ = cfg.search_num_dirs
        _.should eql 3
      end

      it "the search path is the PWD !??" do

        cfg.search_start_path.should eql _pwd
      end

      it "the default init director is the PWD" do
        cfg.default_init_directory.should eql _pwd
      end

      it "the filename is 'config'" do
        cfg.filename.should eql( 'config' )
      end
    end

    context "`search_search_path` vs. `get_search_start_pathname`" do

      memoize :_require_constants do

        module SVC_3
          class Client
            Home_::Config::Service.enhance self do
              search_start_path '/wizzo'
            end
          end
        end
        NIL_
      end

      share_subject :cfg do
        _build_it
      end

      it "you can set the search start path" do
        cfg.search_start_path.should eql( '/wizzo' )
      end

      it "you can get it as a pathname" do

        _ = cfg.get_search_start_pathname.join( 'pizzo' ).to_path
        _.should eql '/wizzo/pizzo'
      end

      it "the other is not memoized - set the one, changes the other" do

        cfg = _build_it

        pn1 = cfg.get_search_start_pathname

        cfg.search_start_path = '/foo'

        pn2 = cfg.get_search_start_pathname

        pn1.to_path.should eql '/wizzo'

        pn2.to_path.should eql '/foo'
      end

      def _build_it
        _require_constants
        SVC_3::Client.new.config
      end
    end
  end
end
