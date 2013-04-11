module Skylab::PubSub

  class API::Tricks::Guess

    # given a path and a maxdepth, find the first list of 1 or more modules
    # at the same level of depth that respond to `emits`.

    def guess                     # result is false or a nonzero length array
      res = false  # if you do not succeed you fail
      begin
        @tok_a = normalized_relative_pathname_tokens or break
        load_subproduct_core_file or break
        @anchor_mod = load_anchor_mod or break
        res = scan_the_depths( 1 ) or break
      end while nil
      res
    end

  protected

    def initialize prefix, paystream, infostream, path
      @prefix, @paystream, @infostream = prefix, paystream, infostream
      @path = path
      nil
    end

    def normalized_relative_pathname_tokens
      nrpn = normalized_relative_pathname
      if nrpn
        nrpn = nrpn.sub_ext( '' )
        nrpn.to_s.split '/'
      end
    end

    def normalized_relative_pathname
      @pathname = ::Pathname.new( @path ).expand_path
      slpn = ::Skylab.dir_pathname
      if 0 != @pathname.to_s.index( slpn.to_s )
        error "expected #{ @pathname } to be under #{ slpn }"
      else
        @pathname.relative_path_from slpn
      end
    end

    def error msg
      @infostream.puts "#{ @prefix }#{ msg }"
      false
    end

    def load_subproduct_core_file
      @subp = @tok_a.shift
      require "skylab/#{ @subp }/core"
      true
    end

    def load_anchor_mod
      if @tok_a.length.zero?
        error "expecting more than just #{ @subp.inspect } for a file!"
      else
        parts = [ @subp, * @tok_a ]
        parts.reduce ::Skylab do |modul, part|
          MetaHell::Boxxy::FUN.fuzzy_const_get[ modul, part ]
        end
      end
    end

    def scan_the_depths depth
      if API::FUN.looks_like_emitter_module[ @anchor_mod ]
        [ @anchor_mod ]
      elsif depth.zero?
        error "can't procede - does not respond to `emits` - #{ @anchor_mod }"
      else
        @child_relconst_a = []
        @relname = "#{ @anchor_mod.name }::"
        res = _scan_the_depths @anchor_mod, depth - 1
        if res then res else
          len = @child_relconst_a.length
          error "did not find a module that `emits` among ::#{ @anchor_mod } #{
            }or its #{ len } loaded #{ 1 == len ? 'child' : 'children' } #{
            }#{ depth } #{ }level#{ 's' if depth != 1 } #{
            }below it#{ if len.nonzero? then ": (#{
              @child_relconst_a.join ', ' })" end }"
        end
      end
    end

    def _scan_the_depths modul, depth
      yeilt = modul.constants.reduce [] do |y, const|
        name = "#{ modul.name }::#{ const }"
        @child_relconst_a << ( name[ @relname.length .. -1 ] )
        if modul.const_defined? const, false  # give autoloading a chance to be avoided!
          mod = modul.const_get const, false
          if API::FUN.looks_like_emitter_module[ mod ]
            y << mod
          end
        end
        y
      end
      if yeilt.length.zero? and depth > 0
        dpth = depth - 1
        yeilt = modul.constants.reduce [] do |y, const|  # this time, both
          mod = modul.const_get const, false  # autoload the module if nec,
          ylt = _scan_the_depths mod, dpth  # and do the descent.
          y.concat ylt if ylt
          y
        end
      end
      yeilt if yeilt.length.nonzero?
    end
  end
end
