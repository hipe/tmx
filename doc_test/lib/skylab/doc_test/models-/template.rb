module Skylab::DocTest

  class Models_::Template

    # wrap the counterpart vendor library because:
    #
    #   • insulate our internal API for templates from that of the
    #     vendor lib so both may change independently.
    #
    #   • our "template" is stateful (holding parameter assignments)
    #     in contrast to vendor lib templates which are essentially
    #     stateless functions.
    #
    #   • we cache some calculations about templates.
    #
    #   • we experiment with something wild near multiline dootilies

    class << self
      alias_method :via_full_path, :new
      undef_method :new
    end  # >>

    def initialize full_path

      @_reflection = Lookup_cached_template_function___[ full_path ]
      @_settings_box = Common_::Box.new
    end

    def set_multiline_template_variable st, sym

      _para = @_reflection._lookup_parameter sym
      _big_s = Big_string_via_multiline_etc___[ st, _para ]
      _write_setting _big_s, sym
    end

    def set_simple_template_variable s, sym

      @_reflection._lookup_parameter sym  # assert it exists
      _write_setting s, sym
    end

    def _write_setting s, sym
      @_settings_box.add sym, s
      NIL_
    end

    # --

    def flush_to_line_stream

      _sbx = remove_instance_variable :@_settings_box

      _big_string = @_reflection.__express_into_against "", _sbx.h_

      Home_.lib_.basic::String.line_stream _big_string
    end

    # ==

    # every time we need to use the same "template function" (what
    # in the vendor lib is called a "template") for a different subject
    # instance (what we call "template" for now),
    # we don't want to open the same template file and parse the
    # same bytes, searching for parameters and margins, etc over and
    # over again for each subject instance based on the same file.
    # this "solution" has issues (it won't free up the memory it uses,
    # it won't detect filesystem changes), but it will probably suffice
    # for the lifetime of this project..

    template_cache = {}
    Lookup_cached_template_function___ = -> normal_path do
      _vt = Home_.lib_.basic::String::Template.via_path normal_path
      x = TemplateFunction___.new _vt
      template_cache[ normal_path ] = x
      x
    end

    # ==

    module Big_string_via_multiline_etc___ ; class << self

      def call st, para

        x = st.gets
        if x
          __when_some x, st, para
        else
          EMPTY_S_
        end
      end
      alias_method :[], :call

      def __when_some buffer, st, para

        margin_s = para.margins.first  # or last or whatever..

        # we want the user (not us) to decide whether tabs are used

        # the first line does not get deepend (because in the template
        # (presumably) that "line" spot is already marginated)

        # any remaining lines *do* get deepened:

        st.reduce_into_by buffer do |m, line|

          if ZERO_LENGTH_LINE_RX_ =~ line
            # it is almost certainly the case that when there is a "blank"
            # line in the source document, it should not get deepened.
            # use the user's LTS
            m << line
          else
            # since there is content in the line, do this shim sham
            m << "#{ margin_s }#{ line }"
          end
        end

        # finally, don't add any final LTS in addition to
        # the one that is presumably in the template

        buffer.chomp!
        buffer
      end
    end ; end

    # ==

    class TemplateFunction___

      # model parameter occurrences margin data

      def initialize vt

        bx = Common_::Box.new

        st = vt.to_parameter_occurrence_stream
        begin
          occu = st.gets
          occu or break

          bx.touch occu.name_symbol do |sym|
            ParameterOccurrences___.new sym
          end.add_margin occu.margin_string
          redo
        end while nil

        @_parameter_occurrences_box = bx
        @_vendor_template = vt
      end

      def __express_into_against y, h
        @_vendor_template.express_into_against y, h
      end

      def _lookup_parameter sym
        @_parameter_occurrences_box.fetch sym
      end
    end

    # ==

    class ParameterOccurrences___

      def initialize sym
        @margins = []
        @name_symbol = sym
      end

      def add_margin s
        @margins.push s
      end

      attr_reader(
        :margins,
        :name_symbol,
      )
    end

    # ==
  end
end
