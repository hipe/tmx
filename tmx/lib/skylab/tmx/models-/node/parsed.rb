module Skylab::TMX

  class Models_::Node::Parsed

    module Parser

      class << self

        def new sel, ind, & p

          Home_.lib_.JSON  # require 'json'

          Parsed___.begin_prototype sel, ind, p
        end
      end  # >>
    end

    PathMethods__ = ::Module.new

    Parsed___ = self
    class Parsed___

      class << self
        alias_method :begin_prototype, :new
        undef_method :new
      end  # >>

      def initialize sel, ind, p

        @__attributes_to_parse = sel.get_attributes_to_parse__
        @index = ind
        @_emit = p
      end

      def parse unparsed
        dup.__execute unparsed
      end

      def __execute unparsed
        @_json_file_ = unparsed._json_file_
        if __parse_json_file
          if __there_are_no_unrecognized_components
            __place_the_selected_components_into_a_box
          else
            __whine_about_unrecognized_attributes
          end
        else
          __whine_about_failed_to_parse
        end
      end

      # --

      def __place_the_selected_components_into_a_box

        box = Common_::Box.new

        h = remove_instance_variable :@_raw_hash
        remove_instance_variable :@index

        remove_instance_variable( :@__attributes_to_parse ).each do |attr|
          _hum = attr.name.as_human
          had = true
          x = h.fetch _hum do
            had = false
          end
          if had
            if x.nil?
              Home_._DECIDE
            else
              box.add attr.normal_symbol, x
            end
          end
        end

        remove_instance_variable :@_emit
        @box = box
        self
      end

      # --

      def __there_are_no_unrecognized_components

        extra = nil
        @_raw_hash.each_key do |s|
          if ! @index.is_parsable_via_human__ s
            ( extra ||= [] ).push s
          end
        end
        if extra
          @__extra_humans = extra
          UNABLE_
        else
          ACHIEVED_
        end
      end

      def __whine_about_unrecognized_attributes

        _s_a = remove_instance_variable :@__extra_humans
        _json_file = remove_instance_variable :@_json_file_

        @index.explain_why_is_not_parsable__ _s_a, _json_file, & @_emit
        UNABLE_
      end

      # --

      def __parse_json_file

        _big_string = ::File.read @_json_file_
        begin
          h = ::JSON.parse _big_string
        rescue ::JSON::ParserError => @__exception
        end
        _store :@_raw_hash, h
      end

      def __whine_about_failed_to_parse

        e = remove_instance_variable :@__exception
        json_file = remove_instance_variable :@_json_file_

        @_emit.call :error, :expression, :parse_error do |y|
          y << "    ( while parsing #{ json_file }"
          s_a = e.message.split NEWLINE_
          s_a.each do |s|
            y << "      #{ s }"
          end
          y << "    )"
        end
        UNABLE_
      end

      # --

      def filesystem_directory_entry_string
        @___normal_name_string ||= get_filesystem_directory_entry_string.freeze
      end

      include PathMethods__

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # --

      attr_reader(
        :box,
      )
    end

    # ==

    class Unparsed

      # ==
      Stream_via_json_file_stream = -> file_stream do
        file_stream.map_by do |path|
          Unparsed.via_json_file_path path
        end
      end
      # ==

      class << self
        alias_method :via_json_file_path, :new
        undef_method :new
      end  # >>

      def initialize json_file
        @_json_file_ = json_file
      end

      def express_into y
        y << get_filesystem_directory_entry_string
      end

      include PathMethods__

      attr_reader(
        :_json_file_,
      )
    end

    # ==

    module PathMethods__

      # (the methods names are per [#bs-028]:B)

      def get_filesystem_directory_entry_string
        s = @_json_file_
        d = s.rindex( ::File::SEPARATOR ) - 1
        s[ s.rindex( ::File::SEPARATOR, d ) + 1 .. d ]
      end

      def get_filesystem_directory
        ::File.dirname @_json_file_
      end
    end

    # ==
  end
end
