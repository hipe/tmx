module Skylab::CodeMolester

module Config  # #borrow x 1
                                  # if you somehow got here without sexp
  S = self::Sexp                  # load it here and now / shorten it
                                  # we especially need it for registering

  module Sexps                    # isn't it nice to see a plain old module
  end                             # so docile

  class Sexps::Enumerator < ::Enumerator

    def each &blk
      if 2 != blk.arity then super else
        super do |l|
          blk[ l.key, l.value ]
        end
      end
    end

  private

    def initialize host, &blk
      @host = host
      super( & blk )
    end

    def host ; @host end
  end

  class Sexps::Enumerator::Hashish < Sexps::Enumerator

    def [] k
      item = detect do |i|
        k == i.key
      end
      if item
        item.value
      end
    end

    def keys
      map( & :key )
    end

    def []= k, v
      @host.set_mixed k, v
    end
  end

  class Sexps::Enumerator::Hashish::Sections < Sexps::Enumerator::Hashish

    extend MetaHell::DelegatesTo

    def [] k
      detect do |i|
        k == i.item_name
      end
    end

    -> do  # `set_section_with_hash`  ( a.k.a `[]=` ), `insert_after`

      append_to_parent = nil
      define_method :set_section_with_hash do |key, body_data_pairs|
        if ! body_data_pairs.respond_to? :each_pair
          raise ::ArgumentError, "When assigning to an entire section, #{
            }expected hash-like, had #{ body_data_pairs.class }"
        end
        sec = self[ key ] || append_to_parent[ @host, key ]
        body_data_pairs.each_pair do |k, v|
          sec[ k.to_s ] = v
        end
        sec
      end

      create = nil
      define_method :insert_after do |sect_name, body_data_pairs, before|
        sec = create[ sect_name, @host, body_data_pairs ]
        @host.insert_after sect_name, sec, before
      end

      define_method :append_section do |sect_name, body_data_pairs=nil|
        sec = create[ sect_name, @host, body_data_pairs ]
        @host << sec  # pray
        sec
      end

      append_to_parent = -> parent, name do
        sect = create[ name, parent ]
        # parent.push "\n" # this probably breaks syntax, let's see if it's ok
        # SEE TESTS re above)
        parent << sect
        sect
      end

      create = -> name, parent, body_data_pairs=nil do
        tmpl = parent.rchild :section
        if tmpl
          sl = tmpl.child( :header ).child( :section_line )
          s0 = sl[1]
          s1 = sl[3][1]
        else
          s0 = '['
          s1 = ']'
        end
        sec = S[ :section,
          S[ :header,
            S[ :section_line, s0, S[ :name, name.to_s ], S[ :n_3, s1 ] ]
          ],
          S[ :items, "\n" ]
        ]
        if body_data_pairs
          body_data_pairs.each_pair do |k, v|
            k = k.to_s  # it is time
            sec[ k ] = v
          end
        end
        sec
      end

      alias_method :[]=, :set_section_with_hash

    end.call

    delegates_to :host, :remove
  end

  class Sexps::ContentItemBranch < Sexp

    # note that for now this is hard-coded to assume string and not symbol keys!
    # (the test below cannot simply test for Fixnum-based key b/c it also must
    # take ranges)

    def [] kx, *kxa  # ::Array supports arguments like arr[ 0, 1 ]
      if kxa.length.zero? and kx.respond_to? :ascii_only?
        lookup_with_s_else_p kx, false
      else
        super
      end
    end

    def lookup_with_s_else_p key_s, any_else_p  # like fetch, but leave it alone (for ary)
      sx = content_items.detect do |sexp|
        key_s == sexp.item_name
      end
      if sx
        if sx.item_leaf?
          sx.item_value
        else
          sx
        end
      elsif any_else_p
        any_else_p[]
      elsif false != any_else_p
        raise ::KeyError.exception "key not found: #{ key_s.inspect }"
      end
    end

    def []= kx, *kxa, v
      if kxa.length.zero? and kx.respond_to? :ascii_only?
        set_mixed kx, v
        v
      else
        super
      end
    end

    def item_leaf?
      false
    end

    def key? name
      !! content_items.detect { |ii| name == ii.item_name }
    end

    def set_mixed name_str, x
      if x.respond_to? :each_pair
        sections.set_section_with_hash name_str, x
      else
        item = content_items.detect do |i|
          name_str == i.item_name
        end
        if item
          _update_value item, x
        else
          _create_value name_str, x
        end
      end
    end

    def value_items
      Sexps::Enumerator::Hashish.new self do |y|
        _assignments_sexp.children(:assignment_line).each do |sx|
          y << sx
        end
      end
    end

    def any_names_notify
      set = CodeMolester::Services::Set.new
      value_items.each do |sx|
        set.add? sx.item_name
      end
      if set.length.nonzero? then set.to_a end
    end
  end

  class Sexps::FileSexp < Sexps::ContentItemBranch
    Sexp[:file] = self
    delegates_to :nosecs, :prepend_comment
    # delegates_to :sections, :append_comment # e.g.
    def _assignments_sexp
      self[1]
    end
    def content_items
      a = self[1]
      a2 = a.content_items
      b = self[2]
      b2 = b.content_items
      [*a2, *b2]
      # [*self[1].content_items, *self[2].content_items]
    end
    def _create_value name, value
      # we could try try dynamically add the node if necessary, but it
      # is less hacky to just assume it is there.  "Should" be there for all such valid trees.
      sec = nosecs or fail "Invalid file sexp: child not found: nosecs"
      Sexps::AssignmentLine.create name, value, sec
      nil
    end
    def nosecs
      child :nosecs
    end
    def sections
      child( :sections ).enumerator
    end

    def get_section_scanner_with_map_reduce_p p
      child( :sections ).get_scanner_with_map_reduce_p p
    end

    def _update_value assmt, value
      assmt.set_item_value value
    end

    MEMBER_I_A__ = %i( nosecs sections ).freeze
  end

  class Sexps::Nosecs < Sexps::ContentItemBranch

    Sexp[:nosecs] = self

    def content_items
      select_children :assignment_line
    end

    def prepend_comment line
      o = build_comment_line(line) or return false
      self[ 1, 0 ] = [o] # supreme hackery
      o
    end

    MEMBER_I_A__ = %i( content_items ).freeze
  end

  class Sexps::Sections < Sexp

    Sexp[:sections] = self

    def enumerator
      Sexps::Enumerator::Hashish::Sections.new self do |y|
        select_children( :section ).each do |sx|
          y << sx
        end
      end
    end

    alias_method :content_items, :enumerator

    def insert_after sect_name, item, before_sexp
      if before_sexp
        here = before_sexp.section_name
        pos = nil
        with_scanner_for_symbol :section do |scn|
          while x = scn.gets
            if here == x.section_name
              pos = scn.pos
              break
            end
          end
        end
        pos or raise ::KeyError, "after? - #{ here }"
      else
        pos = 0  # insert after this position (strict sexps)
      end
      self[ pos + 1 , 0 ] = [ item ]
      nil
    end

    MEMBER_I_A__ = %i( content_items ).freeze
  end

  class Sexps::Section < Sexps::ContentItemBranch

    def key
      item_name
    end

    Sexp[:section] = self
    def content_items
      self[2].select_children :assignment_line
    end
    def _create_value name, value
      # see comment at other implementation of this method
      items = child :items
      items or fail "Invalid section sexp: child not found: items"
      Sexps::AssignmentLine.create(name, value, items)
    end
    def item_leaf?
      false
    end
    def item_name
      self[1][1][2][1]
    end
    alias_method :section_name, :item_name
    def item_name= str
      self[1][1][2][1] = str
    end
    alias_method :section_name=, :item_name=
    def _update_value assmt, value # c/p
      assmt.set_item_value value
    end

    MEMBER_I_A__ = %i( section_name content_items )
  end

  class Sexps::Section

    # (used to have hellof builders here, but it was an API liability)

  end

  class Sexps::AssignmentLine < Sexp
    Sexp[:assignment_line] = self
    NAME = 2
    VALUE = 4
    TRAILING_WHITESACE = 5
    @default_indent = '  '
    def item_leaf?
      true
    end
    def item_value
      self[VALUE][1]
    end
    alias_method :value, :item_value  # #comport
    def item_name
      self[NAME][1]
    end
    alias_method :key, :item_name  # #comport
    def set_item_value value
      self[VALUE][1] = value.to_s
    end
    MEMBER_I_A__ = %i( item_name item_value ).freeze
  end

  class << Sexps::AssignmentLine
    def create name, value, parent
      # use the whitespace formatting of the previous item if you can
      tmpl = parent.rchild :assignment_line
      if tmpl
        # anything?
      else
        tmpl = [nil, default_indent, nil, ' = ', nil]
      end
      al = self[:assignment_line, tmpl[1], S[:name, name.to_s], tmpl[3], S[:value, value.to_s]]
      if parent.size > 1 and parent.last.respond_to?(:symbol_name) and :assignment_line == parent.last.symbol_name
        parent.push "\n" # this is so bad
      end
      parent.push al
      parent.push "\n" # per the grammar
      nil
    end
    attr_accessor :default_indent
  end

  class Sexps::Comment < Sexp
    Sexp[:comment] = self
    # node_reader :body
  end
end
end
