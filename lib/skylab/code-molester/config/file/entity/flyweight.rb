module Skylab::CodeMolester::Config::File::Entity

  class Entity::Flyweight

    include Entity::Model::InstanceMethods

    singleton_class.send :alias_method, :cm_new, :new

    def self.produce story

      ::Class.new( self ).class_exec do

        singleton_class.send :alias_method, :new, :cm_new

        define_method :entity_story do story end

        Basic::Field::Reflection.enhance( self ).with story.host_module

        MetaHell::Pool.enhance( self ).with_with_instance

        self
      end
    end

    def initialize
      @string_box = MetaHell::Formal::Box::Open.new
      @fld_box = field_box  # meh
      @miss_a = [ ] ; @xtra_a = [ ] ; @nbp_a = [ ] ; @issue_x_a = [ ]
      @had_issues = nil
    end

    def set entity_name_x, section_sexp
      if @had_issues
        flush_issues
      end
      @string_box.clear
      @is_raw = true
      @entity_name_x = entity_name_x
      @section_sexp = section_sexp
    end

    def clear_for_pool
      # NOTE - clear on set.
    end

    def natural_key
      @entity_name_x
    end

    Invalid = Face::Model::Event.new do |miss_a, xtra_a, issue_x_a|
      a = [ ]
      join = -> ar { ar.map { |x| "\"#{ x }\"" } * ', ' }
      if miss_a
        a << "missing required field(s) - #{ join[ miss_a ] }"
      end
      if xtra_a
        a << "had unrecognized field(s) - #{ join[ xtra_a ] }"
      end
      if issue_x_a
        a.concat issue_x_a
      end
      a * ' and '
    end

    # `if_valid` -
    # when the particular instance this flyweight represents at this moment
    # is indexed in the call to `index` below, we do *rudimentary* validation
    # on the "record" that was just read - we merely set `miss_a` and
    # `xtra_a` based on the composition of keys in our field box against
    # the keys of the record just read.
    # this may be useful when scanning "large" datasets to flag entities
    # that may have gone stale or corrupted b.c of changes. (when you start
    # needing to tag your entities with an API version that's probably the
    # point at which you have outgrown this library!)

    -> do  # `if_valid` -
      no = -> { nil }
      sig_h = {
        [ 0, true ] => -> _blk { [ -> { true }, no ] },
        [ 0, false ] => -> blk { [ blk, no ] },
        [ 1, true ] => -> if_yes, _blk { [ if_yes, no ] },
        [ 2, true ] => -> if_yes, if_no, _blk { [ if_yes, if_no ] }
      }
      define_method :if_valid do |*a, &b|
        if_yes, if_no = sig_h.fetch( [ a.length, b.nil? ] )[ *a, b ]
        index if @is_raw
        if @had_issues
          flush_issues if_no
        else
          if_yes[ ]
        end
      end
    end.call

    def flush_issues f
      r = nil
      if ! f
        # nothing
      elsif f.arity.zero?
        r = f[ ]
      else
        r = f[ Invalid[
          miss_a: ( @miss_a.dup if @miss_a.length.nonzero? ),
          xtra_a: ( @xtra_a.dup if @xtra_a.length.nonzero? ),
          issue_x_a: ( @issue_x_a.dup if @issue_x_a.length.nonzero? ) ] ]
      end
      @had_issues = nil ; @miss_a.clear ; @xtra_a.clear ; @issue_x_a.clear
      r
    end

    def index
      sx = @section_sexp.child :items
      if @entity_name_x
        @string_box.add :name, @entity_name_x  # aesthetics
      end
      if sx
        sx.children :assignment_line do |al|
          al.with_scanner do |scn|
            _k = scn.scan( :name ).fetch( 1 ).gsub( '-', '_' ).intern
            _v = scn.scan( :value ).fetch( 1 )
            if :name == _k
              @had_issues = true
              @issue_x_a << "can't have `name` as a body field name - #{
                }ignoring #{ _v.inspect }"
            else
              @string_box.add _k, _v
            end
          end
        end
      end
      required_field_names.each do |i|
        if ! @string_box.has? i
          @miss_a << i
          @had_issues = true
        end
      end
      @string_box._order.each do |i|
        if ! @fld_box.has? i
          @xtra_a << i
          @had_issues = true
        end
      end
      @is_raw = false
    end

    # `get_normalized_head_and_body_pairs` - compat for `jsonesque`:
    # the idea is there is a valid universal internal representation of
    # the data that we will use so that we can share behavior btwn e.g
    # flyweight and controller (flyweight data will usually e.g have been
    # read from a file and will be stringular, whereas etc.)

    def get_normalized_head_and_body_pairs
      a = @nbp_a.clear
      @nat_i ||= entity_story.natural_key_field_name
      if @nat_i
        if @entity_name_x
          a << [ @nat_i, @entity_name_x ]
        end
      end
      _get_normalized_pairs a, body_fields
      @nbp_a
    end

    -> do  # `_get_normalized_pairs` - do not re-write these.
           # they lose whitespace formatting. also there are some gothas #todo

      scn = CodeMolester::Services::StringScanner.new ''
      white = /[ \t]+/
      a = [ ]
      lit_rx = /(?:true|false)\b/
      lit_h = { 'false' => false , 'true' => true }
      bare_rx = /(?:[^",]|\\[",])+/
      comma = /,/
      escaped_double_quote_rx = /\A"(?:\"|(?!").)*"/

      define_method :_get_normalized_pairs do |y, ea|
        ea.each do |fld|
          nn = fld.local_normal_name
          @string_box.has? nn or next
          _get_token_pairs @string_box.fetch nn
          if a.length.nonzero?
            if 1 == a.length
              y << [ nn, a.fetch( 0 ) ]
            else
              y << [ nn, a ]  # ERMAHGERD IT'S MEMOIZED
            end
          end
        end
        nil
      end

      define_method :_get_token_pairs do |string|
        scn.string = string
        a.clear
        while ! scn.eos?  # loop over each token in a comma-separated list
          scn.skip white
          scn.eos? and break
          if s = scn.scan( lit_rx )
            a << lit_h.fetch( s )
          elsif s = scn.scan( bare_rx )
            a << s
          elsif s = scn.scan( escaped_double_quote_rx )
            a << s[ 1..-2 ].gsub( /\\(.)/ ) { $~[1] }  # meh
          else
            fail "sanity - test me: #{ scn.rest }"
            # but it *is* tempting, though, to just yield it
          end
          scn.skip white
          scn.eos? and break
          if ! scn.skip comma
            break
          end
        end
        if ! scn.eos?
          a.clear
          a << string  # MEH
        end
        nil
      end
    end.call
  end
end
