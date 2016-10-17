module Skylab::CodeMetrics

  Require_brazen_[]  # 1 of 2

  class Models_::Tally < Brazen_::Action

    def self.entity_enhancement_module
      Brazen_::Modelesque::Entity
    end

    @instance_description_proc = -> y do

      _word = action_reflection.front_properties.fetch :word
      word = par _word

      _path = action_reflection.front_properties.fetch :path
      path = par _path

      y << "find every occurrence of every #{ word } in every file"
      y << "selected by every #{ path } recursively and hackishly.."
      y << nil
      y << "currently uses whole-word search against each #{ word }."
      y << "geared towards finding method calls so it is designed *not* to"
      y << "support regular expressions (for now) and will whine if words"
      y << "are used that contain regexp-y characters."
      y << nil
      y << "uses find and grep because ack wouldn't cut it."
      y << nil
      y << "outputs a report reporting (somehow) the distribution of"
      y << "all the #{ word }s in all the files.."
    end

    def description_proc_for_summary_of_under ada, exp

      # #[#br-002]:A because we reference our own properties in the above,
      # we need to create explicitly our own expag. this is nasty because
      # it jumps down to the agnostic layer and then back up ..

      ada.description_proc_for_summary_of_under__ self, exp
    end

    edit_entity_class(

      :required,
      :property, :stdout,

      :description, -> y do
        y << 'adds this as a `-name` primary to the internal find command.'
        y << "multiple will be OR'ed together."
        y << '(typically used to indicate file extensions to limit by.)'
      end,
      :argument_arity, :one_or_more,
      :property, :name,

      :description, -> y do
        y << "effectively adds \"`-not` `-path` X\" to the internal find command."
        y << "multiple will be OR'ed together."
        y << "(typically used to ignore particular files)"
      end,
      :argument_arity, :one_or_more,
      :property, :ignore_path,

      :description, -> y do
        y << "(words)"
      end,
      :required,
      :argument_arity, :one_or_more,
      :property, :word,

      :description, -> y do
        y << "(paths)"
      end,
      :required,
      :argument_arity, :one_or_more,
      :property, :path,
    )

    def produce_result

      # (imagine that you are doing the "magnetics" thing (future thing)

      @_system_conduit = Home_.lib_.open_3

      ok = __files_slice_stream_via_parameters
      ok &&= __vender_match_stream_via_files_slice_stream
      ok &&= __match_stream_via_vendor_stream
      ok &&= __graph_structure_via_match_stream
      ok && __digraph_via_graph_structure_and_parameters
    end

    def __digraph_via_graph_structure_and_parameters

      o = Here_::Magnetics_::Digraph_via_Graph_Structure_and_Parameters.new
      o.features_section_label = 'Symbols'
      o.bucket_tree_section_label = 'Files'
      o.document_label = 'the occurrence of these symbol in these files'

      o.graph_structure = remove_instance_variable :@_graph_structure

      o.upstream_line_yielder = @argument_box.fetch :stdout

      ok = o.execute

      if ok
        ACHIEVED_
      else
        ok
      end
    end

    def __graph_structure_via_match_stream

      o = Here_::Magnetics_::Graph_Structure_via_Match_Stream.new
      o.match_stream = remove_instance_variable :@_match_stream
      o.pattern_strings = @_pattern_strings
      _set_or_stop :@_graph_structure, o
    end

    def __match_stream_via_vendor_stream

      o = Here_::Magnetics_::Match_Stream_via_Vendor_Match_Stream.new
      o.pattern_strings = @_pattern_strings
      o.vendor_match_stream = remove_instance_variable :@_vendor_match_stream
      _set_or_stop :@_match_stream, o
    end

    def __vender_match_stream_via_files_slice_stream

      @_pattern_strings = @argument_box.fetch :word  # eek

      o = Here_::Magnetics_::Vendor_Match_Stream_via_Files_Slice_Stream.
        new( & @on_event_selectively )

      o.files_slice_stream = remove_instance_variable :@_files_slice_stream

      o.pattern_strings = @_pattern_strings

      o.system_conduit = @_system_conduit

      _set_or_stop :@_vendor_match_stream, o
    end

    def __files_slice_stream_via_parameters

      _o = @argument_box
      h = _o.h_

      o = Here_::Magnetics_::Files_Slice_Stream_via_Parameters.new

      o.chunk_size = 100  # etc #open [#014]  this is a thing

      o.ignore_paths = h[ :ignore_path ]

      o.name_patterns = h[ :name ]

      o.paths = h.fetch :path

      o.system_conduit = @_system_conduit

      _set_or_stop :@_files_slice_stream, o
    end

    def _set_or_stop ivar, o
      x = o.execute
      if x
        instance_variable_set ivar, x
        ACHIEVED_
      else
        x
      end
    end

    Here_ = self
  end
end
