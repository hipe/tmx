module Skylab::Cull

  class Models::Data::Source::Flyweight

    Models::Field::Box.of self, Models::Data::Source.field_box

    def initialize
      @box = MetaHell::Formal::Box::Open.new
      @miss_a = [ ]
    end

    def set name, section_sexp
      @box.clear
      @miss_a.clear
      @is_raw = true
      @name = name
      @section_sexp = section_sexp
    end

    def explain
      index if @is_raw  # doesn't care about valid
      a = field_names.reduce [] do |m, i|
        v = send i
        m << "#{ i }: #{ v.inspect }" if ! v.nil?
        m
      end
      "{ #{ a * ', ' } }"
    end

    def name
      @name
    end

    def url
      if_valid do
        @box.fetch :url
      end
    end

    def tags
      if_valid do
        if @box.has? :tags
          @box.fetch :tags
        end
      end
    end

    -> do  # `tags`
      comma_rx = /[ ]*,[ ]*/
      define_method :tag_a do
        t = tags and t.split( comma_rx )
      end
    end.call

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
        if @miss_a.length.zero?
          if_yes[ ]
        elsif 1 == if_no.arity
          if_no[ @miss_a.dup ]
        else
          if_no[ ]
        end
      end
    end.call

    def index
      if @name
        @box.add :name, @name  # kind of eew, kind of meh
      end
      sx = @section_sexp.detect :items
      if sx
        sx.each :assignment_line do |al|
          al.with_scanner do |scn|
            @box.add scn.scan( :name ).fetch( 1 ).gsub( '-', '_' ).intern,
              scn.scan( :value ).fetch( 1 )
          end
        end
      end
      required_field_names.each do |i|
        @miss_a << i if ! @box.has? i
      end
      @is_raw = false
    end
  end
end
