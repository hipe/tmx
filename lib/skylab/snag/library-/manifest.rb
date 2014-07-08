module Skylab::Snag

  class Library_::Manifest

    def initialize pathname
      @pathname = ( ::Pathname.new pathname if pathname )
      @manifest_file = @tmpdir_pathname = nil
    end

    def pathname
      @pathname or fail "sanity - no pathname"
    end

    def curry_enum *a
      ea = self.class::Enum_.new  @pathname, -> { manifest_file }
      ea._FIXME_9_absrb( *a )
      ea
    end

    def add_node_notify node, *a
      self::class::Adder_[ node, :callbacks, get_callbacks, *a ]
    end

    def change_node_notify node, *a
      self::class::Changer_[ node, :callbacks, get_callbacks, *a ]
    end

  private

    def get_callbacks
      self.class::Callbacks_.new :render_lines_p, method( :render_line_a ),
        :manifest_file_p, method( :manifest_file ), :pathname, @pathname,
          :file_utils_p, get_file_utils_p, :tmpdir_p, get_tmpdir_p,
            :curry_enum_p, method( :curry_enum )
    end

    def render_line_a node, identifier_d=nil
      identifier_d and node.build_identifier! identifier_d, ID_NUM_DIGITS_
      line_a = [ "#{ node.identifier.render } #{ node.first_line_body }" ]
      line_a.concat node.extra_line_a
      line_a
    end

    ID_NUM_DIGITS_ = 3

    def manifest_file
      @manifest_file ||= begin
        @pathname or fail "sanity - pathname should be set by now"
        Models::Manifest::File.new @pathname
      end
    end

    def get_file_utils_p

      # using a hacky regex, scan all msgs emitted by the file utils client
      # and with any string that looks like an aboslute path run it through
      # `escape_path_p` proc (*of the modality client*, e.g). in turn, call_digraph_listeners
      # these messages as info to `info_p`, presumably to the same modality
      # client. This hack grants us the novelty of letting FileUtils render
      # its own messages (which it does heartily) while attempting possibly
      # to mask full filenames for security reasons. but at the end of day,
      # it is still a hack!

      FU_curry_.method( :[] )
    end

    class FU_curry_
      MetaHell::Funcy[ self ]
      Snag_::Lib_::Basic_fields[ self, :escape_path_p, :be_verbose, :info_p ]
      def execute
        rx = Headless::CLI::PathTools::FUN::ABSOLUTE_PATH_HACK_RX
        Headless::IO::FU.new -> s do
          @info_p[ s.gsub( rx ) { @escape_path_p[ $~[ 0 ] ] } ] if @be_verbose
        end
      end
    end

    def get_tmpdir_p
      -> *a do
        @tmpdir_pathname ||= Headless::System.defaults.tmpdir_pathname.join TMP_DIRNAME_
        Tmpdir_Curry_[ :tmpdir_pathname, @tmpdir_pathname, *a ]
      end
    end

    TMP_DIRNAME_ = 'snag-production-tmpdir'

    class Funcy_

      MetaHell::Funcy[ self ]

    private

      def bork msg
        @error_p[ msg ]
        false
      end

      def info msg
        @info_p[ msg ]
        nil
      end
    end

    Manifest = self
  end
end
