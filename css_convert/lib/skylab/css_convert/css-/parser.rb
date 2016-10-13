module Skylab::CSS_Convert

  class CSS_::Parser < Home_::Parser_::Common_Base

    ENTITY_NOUN_STEM = 'css file'

    same = "Skylab::CSS_Convert::CSS_::Grammar"

    a = []

    PARSERS___ = a

    a.push(
      converter: :flex_to_treetop,
      flex_file: 'css2.1.flex',
      treetop_file: 'css2.1.flex.treetop',
      wrap_in_grammar: "#{ same }::Tokens",
    )

    a.push(
      converter: :yacc_to_treetop,
      grammar_includes: [ :Tokens ],
      yacc_file: 'css2.1.yacc3wc',
      treetop_file: 'css2.1.yacc.treetop',
      wrap_in_grammar: "#{ same }::CSS_Document",
    )

    if false  # if the below were ever used, it was pre july 2012
    a.push(
      converter: :flex_to_treetop,
      flex_file: 'tokens.flex',
      treetop_file: 'tokens.flex.treetop',
      wrap_in_grammar: "#{ same }::Tokens",
    )
    a.push(
      converter: :yacc_to_treetop,
      yacc_file: 'selectors.yaccw3c',
      treetop_file: 'selectors.yacc.treetop',
      wrap_in_grammar: "#{ same }::Selectors",
    )
    end

    def produce_parser_class

      @_indir = ::File.join Home_.dir_path, 'css-/parser'

      if ! ::File.directory? @out_dir_head
        ::Dir.mkdir @out_dir_head
      end

      x = nil

      _involved_parsers.each do | h |

        w = Work___.new

        w.treetop_path = ::File.join @out_dir_head, h.fetch( :treetop_file )

        x = send :"__touch__#{ h.fetch :converter  }__parser_class", w, h
        x &&= __require_generated_treetop_file w, h
        x or break
      end

      x
    end

    def __touch__flex_to_treetop__parser_class w, h

      treetop_path = w.treetop_path

      _do = ! ::File.exist?( treetop_path )

      if _do

        x = Home_.lib_.flex_to_treetop.translate(
          :resources, @resources,
          :flex_file, ::File.join( @_indir, h.fetch( :flex_file ) ),
          :force,
          :output_path, treetop_path,
          :wrap_in_grammar, h.fetch( :wrap_in_grammar ),

        ) do | * i_a, & ev_p |
          if :error == i_a.first
            raise ev_p[].to_exception
          end
        end

        :translated == x or fail "Uh oh: #{ x.inspect }"
      else
        ACHIEVED_
      end
    end

    def __touch__yacc_to_treetop__parser_class w, h

      treetop_path = w.treetop_path

      if ::File.exist? treetop_path
        # (would do) flag = ::File::WRONLY
      else
        do_ = true
        down_flag = ::File::CREAT | ::File::WRONLY
      end

      if do_

        _upstream_path = ::File.join @_indir, h.fetch( :yacc_file )
        downstream_IO = ::File.open treetop_path, down_flag

        sym_a = h[ :grammar_includes ]
        if sym_a
          includes_of_grammars = []
          sym_a.each do | sym |
            includes_of_grammars.push :include_grammar, sym
          end
        end

        d = Home_.lib_.yacc_to_treetop.translate(

          :downstream_IO, downstream_IO,

          * includes_of_grammars,

          :wrap_in_grammar, h.fetch( :wrap_in_grammar ),
          :yacc_file, _upstream_path,

        ) do | * i_a, & ev_p |
          if :error == i_a.first
            raise ev_p[].to_exception
          else
            @on_event_selectively[ * i_a, & ev_p ]
          end
        end

        if d.zero?
          downstream_IO.close
          ACHIEVED_
        else
          self._COVER_ME_we_have_nonzero_exitstatus
        end
      else
        ACHIEVED_
      end
    end

    # reminder of how treetop loader works: if input path is absolute,
    # output file will be placed right next to the input file. otherwise,
    # you must supply *both* the input and output path heads in order
    # to derelativize both an input and output path from the path tail.
    # we always want the latter, because we never want the generated files
    # to sit next to the hand-written files, but rather to sit in a tmpdir.

    def __require_generated_treetop_file w, h

      # since it's generated, assume it is in some kind of tmpdir. we don't
      # need to provide "head" paths because the provided treetop path is
      # absolute - the generated ruby file will be put alongside it.

      o = start_treetop_require_
      o.add_treetop_grammar w.treetop_path
      o.add_parser_enhancer_module Home_::Parser_::Parser_Instance_Methods

      o.execute
    end

    Work___ = ::Struct.new :treetop_path

    def _involved_parsers
      PARSERS___
    end
  end
end

# (was [#sl-115] request to clean up via functionalizing!??)
