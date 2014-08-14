module Skylab::Snag

  class Models::Manifest  # [#038]

    class << self

      def build_file pathname
        self::File__.new pathname
      end

      def header_width
        HEADER_WIDTH__
      end
      HEADER_WIDTH__ = '[#867] '.length

      def line_width
        LINE_WIDTH__
      end
      LINE_WIDTH__ = 80
    end

    def initialize pathname
      @pathname = ( ::Pathname.new pathname if pathname )
      @manifest_file = @tmpdir_pathname = nil
    end

    def pathname
      @pathname or fail "sanity - no pathname"
    end

    def curry_enum * x_a
      ea = self.class::Node_Scan__.new  @pathname, -> { manifest_file }
      ea.absorb_iambic_fully x_a
      ea
    end

    def add_node_notify node, *a
      self::class::Node_add__[ node, :callbacks, get_callbacks, *a ]
    end

    def change_node_notify node, *a
      self::class::Node_edit__[ node, :callbacks, get_callbacks, *a ]
    end

  private

    def get_callbacks
      self.class::Callbacks__.new :render_lines_p, method( :render_line_a ),
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
        Models::Manifest.build_file @pathname
      end
    end

    def get_file_utils_p
      FU_curry_.method :[]  # #note-75
    end

    Entity_ = -> client, _fields_, * field_i_a do
      :fields == _fields_ or raise ::ArgumentError
      Snag_::Lib_::Basic_Fields[ :client, client,
        :absorber, :initialize,
        :field_i_a, field_i_a ]
    end

    class FU_curry_
      Snag_::Lib_::Funcy_globless[ self ]
      Entity_[ self, :fields, :escape_path_p, :be_verbose, :info_p ]
      def execute
        rx = Snag_::Lib_::CLI[]::PathTools::FUN::ABSOLUTE_PATH_HACK_RX
        Snag_::Lib_::IO_FU[].new -> s do
          @info_p[ s.gsub( rx ) { @escape_path_p[ $~[ 0 ] ] } ] if @be_verbose
        end
      end
    end

    def get_tmpdir_p
      -> *a do
        @tmpdir_pathname ||= Snag_::Lib_::Tmpdir_pathname[].join TMP_DIRNAME_
        self.class::Tmpdir_Curry__[ :tmpdir_pathname, @tmpdir_pathname, *a ]
      end
    end

    class Agent_

      Snag_::Lib_::Funcy_globless[ self ]

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

    Manifest_ = self

    TMP_DIRNAME_ = 'snag-production-tmpdir'
  end
end
