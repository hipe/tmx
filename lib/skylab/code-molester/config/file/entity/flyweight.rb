module Skylab::CodeMolester::Config::File::Entity

  class Entity::Flyweight

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
      @box = MetaHell::Formal::Box::Open.new
      @fld_box = field_box  # meh
      @miss_a = [ ] ; @xtra_a = [ ]
    end

    def inflection
      entity_story.inflection
    end

    def set entity_name_x, section_sexp
      @box.clear
      @miss_a.clear
      @xtra_a.clear
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

    Invalid = Face::Model::Event.new do |miss_a, xtra_a|
      a = [ ]
      join = -> ar { ar.map { |x| "\"#{ x }\"" } * ', ' }
      if miss_a
        a << "missing required field(s) - #{ join[ miss_a ] }"
      end
      if xtra_a
        a << "had unrecognized field(s) - #{ join[ xtra_a ] }"
      end
      a * ' and '
    end

    -> do  # `if_valid`
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
        if @miss_a.length.nonzero? || @xtra_a.length.nonzero?
          if if_no.arity.zero?
            if_no[ ]
          else
            if_no[ Invalid[
              miss_a: ( @miss_a.dup if @miss_a.length.nonzero? ),
              xtra_a: ( @xtra_a.dup if @xtra_a.length.nonzero? ) ] ]
          end
        else
          if_yes[ ]
        end
      end
    end.call

    def index
      sx = @section_sexp.child :items
      if @entity_name_x
        @box.add :name, @entity_name_x  # aesthetics
      end
      if sx
        sx.children :assignment_line do |al|
          al.with_scanner do |scn|
            @box.add scn.scan( :name ).fetch( 1 ).gsub( '-', '_' ).intern,
              scn.scan( :value ).fetch( 1 )
          end
        end
      end
      required_field_names.each do |i|
        @miss_a << i if ! @box.has? i
      end
      @box._order.each do |i|
        @xtra_a << i if ! @fld_box.has? i
      end
      @is_raw = false
    end

    def jsonesque  # one line
      index if @is_raw  # doesn't care about valid
      a = [ ]
      place = -> kx, vx do
        a << "#{ kx }: #{ vx.inspect }"
      end
      @box.each do |kx, vx|
        place[ kx, vx ]
      end
      "{ #{ a * ', ' } }"
    end
  end
end
