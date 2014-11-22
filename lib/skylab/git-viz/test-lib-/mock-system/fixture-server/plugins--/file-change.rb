module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Plugins__::File_Change

      def initialize client
        @a = [] ; @be_on = true
        @cb_p = client.method :clear_cache_for_manifest_pathname
        @h = {} ; @serr = client.get_qualified_serr
        @raw_y = client.stderr_line_yielder
        @y = client.get_qualified_stderr_line_yielder
      end

      def on_build_option_parser op
        op.on '--no-listen', "by default the server listens for changes #{
         }in the manifest file", "and re-parses the file as necessary #{
          }(which is just amazing, btw.)", "this option tells the server #{
           }not to engage in that behavior." do
          @be_on = false
        end
      end

      def on_front_responder_initted responder
        if @be_on
          GitViz_._lib.listen  # kick it early just to fail fast
          @responder = responder
          listen_for_manifests_being_added_to_the_manifest_collection
        else
          @y << say_not_gonna_do_it
          CONTINUE_
        end
      end

      def say_not_gonna_do_it
        "listener DEACTIVATED per request"
      end

      def listen_for_manifests_being_added_to_the_manifest_collection
        @responder.on_manifest_added( & method( :listen_to_file_of_manifest ) )
        @y<< say_gonna_do_it
        CONTINUE_
      end

      def say_gonna_do_it
        "listener will listen for changes on each parsed manfest file"
      end

      def listen_to_file_of_manifest mani
        entry = Entry__.new mani
        Add_Listener__.new( self, @a, @h, entry ).add_listener
      end
    public
      def already_listening entry
        @y << "still listening to #{ entry.path }." ; nil
      end
      def modified entry
        if 1 < entry.changes.length
          change, change_ = entry.changes[ -2..-1 ]
          last_two_were_not_deletes = change.MD5 && change_.MD5
        end
        if last_two_were_not_deletes && change.MD5 == change_.MD5
          @y << "detected \"modification\" (with no change in content):#{
            } #{ entry.path }"
        else
          @y << "detected modification, clearing any cached #{ entry.path }"
        end
        @cb_p[ entry.pn ] ; nil  # ignore any failure rc
      end
      def added entry
        @y << "added: #{ entry.path }"
      end
      def removed entry
        @y << "removed : #{ entry.path }"
        @cb_p[ entry.pn ] ; nil  # ignore any failure rc
      end

      def on_shutdown
        if ! @be_on
          CONTINUE_
        elsif @a.length.zero?
          @y << "(not listening to any files. nothing to do)"
          CONTINUE_
        else
          shutdown_each_listener
        end
      end
    private
      def shutdown_each_listener
        @a.each do |k|
          entry = @h.fetch k
          @serr.write "shutting down listener for #{ entry.path } .."
          x = entry.listener.stop
          @raw_y << " done (#{ x.inspect })"
        end
        CONTINUE_
      end

      class Entry__
        def initialize mani
          @changes = []
          @pn = mani.manifest_pathname
          @path = @pn.to_path.freeze
        end
        attr_accessor :listener
        attr_reader :changes, :path, :pn
        def add_change x
          @changes << x
        end
      end

      class Add_Listener__
        def initialize listener, a, h, entry
          @a = a ; @listener = listener ; @h = h ; @entry = entry
        end
        def add_listener
          @h.fetch @entry.path do |path|
            @h[ path ] = @entry ; @a << path
            listen_to_entry ; false
          end and when_added_already
        end
        def when_added_already
          @listener.already_listening @entry ; nil
        end
        def listen_to_entry
          pn = @entry.pn
          _dirpath = pn.dirname.to_path
          _rx = %r(\A#{ ::Regexp.escape pn.basename.to_path }\z)
          listener = ::Listen.to( _dirpath, only: _rx ) do |m, a, r|
            _preterite = m.length.nonzero? ? :modified :
              a.length.nonzero? ? :added : :removed
            change = Change__.new _preterite, @entry.pn
            @entry.add_change change
            @listener.send change.preterite, @entry
          end
          $CELLULOID_DEBUG = true  # #avoid-warnings:from:celluloid
          listener.instance_variable_set :@stopping, nil
          @entry.listener = listener
          listener.start
        end
      end

      class Change__
        def initialize preterite, pn
          @preterite = preterite
          :removed == preterite or init_MD5( pn )
        end
        attr_reader :preterite, :MD5
      private
        def init_MD5 pn
          @MD5 = GitViz_._lib.MD5.hexdigest pn.read
        end
      end
    end
  end
end
