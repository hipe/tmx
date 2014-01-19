module Skylab::FileMetrics

  class Services::Find # [#sl-118] one day they will be unified

    class << self
      private :new

      def valid build, reasons
        new.instance_exec do
          build[ self ]
          collapse reasons
        end
      end
    end

    def concat_paths path_a
      ( @path_a ||= [ ] ).concat path_a if path_a.length.nonzero?
    end

    def add_path *path
      concat_paths path
    end

    def concat_skip_dirs skip_dir_a
      ( @skip_dir_a ||= [ ] ).concat skip_dir_a if skip_dir_a.length.nonzero?
    end

    def concat_names name_a
      ( @name_a ||= [ ] ).concat name_a if name_a.length.nonzero?
    end

    def extra= x
      if @extra
        raise "won't clobber existing extra."
      else
        @extra = x
      end
      x
    end

  private

    def initialize
      @path_a = @skip_dir_a = @extra = @name_a = nil
    end  # didactic

    -> do  # `collapse`
      define_method :collapse do |reasons|
        did_error = false
        error = -> msg do
          did_error ||= true
          reasons[ msg ]
          nil
        end
        attrs = ATTRS_.dup
        while atr = attrs.pop
          arr = instance_variable_get atr.ivar
          if atr.req
            if ! arr || arr.length.zero?
              break( error[ "has no #{ atr.label }" ] )
            end
          end
          if arr
            if arr.length.zero?
              break( error[ "has zero-length #{ atr.label } ary" ] )  # internal
            end
            if arr.index { |x| ! x }
              break( error [ "has false-ish #{ atr.label }" ] )
            end
          end
        end
        if did_error then false else
          freeze  # result is self
        end
      end

      Attr_ = ::Struct.new :ivar, :lbl, :req

      ATTRS_ = [
        Attr_[ :@path_a, 'paths', :required ],
        Attr_[ :@skip_dir_a, 'skip dirs' ],
        Attr_[ :@name_a, 'names' ]
      ]

    end.call

  public

    -> do  # `string`

      shellescape_path = FUN.shellescape_path

      define_method :string do
        part_a = [ "find" ]
        part_a.concat @path_a.map(& shellescape_path )
        if @skip_dir_a
          part_a <<  '-not \( -type d \( -mindepth 1 -a'
          part_a << @skip_dir_a.map do |p|
            "-name '#{ shellescape_path[ p ] }'"
          end.join( ' -o ' )
          part_a << '\) -prune \)'
        end
        part_a << @extra if @extra
        if @name_a
          part_a << "\\( #{
            @name_a.map do |p|
              "-name '#{ shellescape_path[ p ] }'"  # yes "'" is nec.
            end.join( ' -o ' )
          } \\)"
        end
        part_a * ' '
      end
    end.call

    # undef_method :to_s  # catches errors, we should be explicit
    alias_method :to_s, :string  # so we can keep some charming legacy code

  end
end
