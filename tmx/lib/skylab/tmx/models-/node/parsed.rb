module Skylab::TMX

  class Models_::Node::Parsed

    module Parser

      class << self

        def new sa, ind, & p
          Parsed___.begin_prototype sa, ind, p
        end
      end  # >>
    end

    # ==

    Parsed___ = self
    class Parsed___

      class << self
        alias_method :begin_prototype, :new
        undef_method :new
      end  # >>

      def initialize sa, ind, p
        @index = ind
        @selected_attributes = sa
        @_emit = p
      end

      def parse unparsed
        dup.__execute unparsed
      end

      def __execute unparsed
        @_json_file = unparsed._json_file
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
        sa = remove_instance_variable :@selected_attributes
        remove_instance_variable :@index

        sa.each do |attr|
          name = attr.name
          _hum = name.as_human
          had = true
          x = h.fetch _hum do
            had = false
          end
          if had
            if x.nil?
              Home_._DECIDE
            else
              box.add name.as_lowercase_with_underscores_symbol, x
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
          @index.has_via_human s and next
          ( extra ||= [] ).push s
        end
        if extra
          @__extra_humans = extra
          UNABLE_
        else
          ACHIEVED_
        end
      end

      def __whine_about_unrecognized_attributes

        s_a = remove_instance_variable :@__extra_humans
        json_file = remove_instance_variable :@_json_file

        @_emit.call :error, :expression, :parse_error do |y|
          y << "unrecognized attribute(s) #{ s_a.inspect } in #{ json_file }"
        end
        UNABLE_
      end

      # --

      def __parse_json_file
        _big_string = ::File.read @_json_file
        begin
          h = ::JSON.parse _big_string
        rescue ::JSON::ParserError => @__exception
        end
        _store :@_raw_hash, h
      end

      def __whine_about_failed_to_parse

        e = remove_instance_variable :@__exception
        json_file = remove_instance_variable :@_json_file

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

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # --

      def get_filesystem_directory_entry_string
        ::File.basename ::File.dirname @_json_file
      end

      attr_reader(
        :box,
      )
    end

    # ==

    class Unparsed

      class << self
        alias_method :via_json_file_path, :new
        undef_method :new
      end  # >>

      def initialize json_file
        @_json_file = json_file
      end

      def express_into y
        y << get_filesystem_directory_entry_string
      end

      def get_filesystem_directory_entry_string
        ::File.basename ::File.dirname @_json_file
      end

      attr_reader(
        :_json_file,
      )
    end

    # ==
  end
end
