module Skylab::Common

  class Magnetics::GemspecInference_via_GemspecPath_and_Specification

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    def initialize

      @has_executables = true

      yield self

      @gemspec_path || fail

      @_dir = ::File.dirname( @gemspec_path ).freeze

      @_exe_glob = ::File.join( @_dir, 'bin', '*' ).freeze

      freeze
    end

    # -- write

    attr_writer(
      :gemspec_path,
      :has_executables,
    )

    # -- read

    def write_all_the_common_things_and_placeholders o  # o=spec

      __write_the_first_cluster o
      __write_the_second_cluster o
      __write_the_third_cluster o
      NIL
    end

    def __write_the_third_cluster o

      if @has_executables
        write_one_or_more_executables_into o
      else
        __assert_no_executables
      end

      a = to_stream_of_one_or_more_codefiles.to_a
      a.push '.for-tmx-map.json'  # you can't, you might be installing [co], but it's ::Skylab::TMX::METADATA_FILENAME
      # a.freeze  # can't, don't know why because rubygems is annoying
      o.files = a

      o.require_paths = %w( lib )
    end

    def __write_the_second_cluster o
      derive_summmary_and_description_from_README_and_write_into o
      o.homepage = "http://localhost:8080/homepage-for-co"
      o.license = "MIT"
      o.metadata[ "allowed_push_host" ] = "TODO: set to 'http://mygemserver.com'"
    end

    def __write_the_first_cluster o
      o.name = gem_name_via_gemspec_path
      o.version = version_via_VERSION_file
      o.author = "hipe"
      o.email = "«#todo»@email.com"
    end

    # -- atomic components

    # ~ (in alphabetical order by stem)

    def date_via_now
      ::Time.now.strftime '%Y-%m-%d'
    end

    ## ~~ codefiles

    def to_stream_of_one_or_more_codefiles

      head = ::File.join @_dir, EMPTY_S_
      paths = ::Dir[ "#{ head }lib/**/*.rb" ]

      if paths.length.zero?
        self._COVER_ME
      else
        r = head.length .. -1
        Home_::Stream.via_nonsparse_array( paths ).map_by do |path|
          path[ r ]
        end
      end
    end

    ## ~~ description (and summmary)

    def derive_summmary_and_description_from_README_and_write_into spec

      io = ::File.open ::File.join( @_dir, 'README.md' ), ::File::RDONLY

      paragraph_stream = Paragraph_stream_vi_IO___[ io ]
      para = paragraph_stream[]
      io.close if ! io.closed?

      spec.summary = para.fetch 0

      spec.description = para.join SPACE_

      ACHIEVED_
    end

    ## ~~ executables

    def write_one_or_more_executables_into spec

      a = spec.executables
      st = to_stream_of_one_or_more_executables
      path = st.gets
      if path
        begin
          a.push path
          path = st.gets
          path and redo
          break
        end while nil
      else
        self._COVER_ME
      end
    end

    def __assert_no_executables

      path = _to_stream_of_executables.gets
      if path
        raise __say_executables path
      end
    end

    def to_stream_of_one_or_more_executables

      st = _to_stream_of_executables

      p = -> do
        x = st.gets
        if x
          p = st.method :gets
          x
        else
          raise __say_no_executables
        end
      end

      Stream.by( ) { p[] }
    end

    def _to_stream_of_executables
      Home_::Stream.via_nonsparse_array(::Dir[ @_exe_glob ]).map_by do |path|
        ::File.basename path  # be careful
      end
    end

    def __say_executables path
      "expected no executables had #{ path } - #{ @_exe_glob }"
    end

    def __say_no_executables
      "expected one or more files had none - #{ @_exe_glob }"
    end

    ## ~~ name

    def gem_name_via_gemspec_path
      Home_::Without_extension[ ::File.basename( @gemspec_path ) ]
    end

    ## ~~ version

    def version_via_VERSION_file
      s = ::File.read ::File.join( @_dir, 'VERSION' )
      s.chomp!
      s
    end

    # -- ..

    def subject_directory
      @_dir
    end

    # ==

    Paragraph_stream_vi_IO___ = -> do

      blank_rx = /\A[[:space:]]*\z/
      header_rx = /\A#/

      sentence_rx = /[^\.:]+[\.:]\)?/  # EEK
      white_rx = /[[:space:]]+/

      -> io do

        -> do

          pending_a = nil
          sentence_a = nil

          add_pending = -> s do
            ( pending_a ||= [] ).push s ; nil
          end

          add_sentence = -> s do

            if pending_a
              pending_a.push s
              s = pending_a.join SPACE_
              pending_a = nil
            end
            ( sentence_a ||= [] ).push s ; nil
          end

          require 'strscan'

          begin

            line = io.gets
            line or break
            line.chomp!

            if header_rx =~ line || blank_rx =~ line
              ( pending_a || sentence_a ) ? break : redo
            end

            scn = ::StringScanner.new line

            begin

              sent = scn.scan sentence_rx
              if sent
                add_sentence[ sent ]
                if scn.eos?
                  break
                end
                scn.skip white_rx
                redo
              end

              add_pending[ scn.rest ]
              break
            end while above

            redo  # go to read next line
          end while above

          sentence_a
        end
      end
    end.call

    # ==
    # ==
  end
end
