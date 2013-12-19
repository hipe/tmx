module Skylab::MetaHell

  module Module

    Resolve__ = -> else_p, create_p, path_s, mod do
      path_a = mod.name.split CONST_SEP__
      delt_a = path_s.split FILE_SEP__
      while part = delt_a.shift
        if BACK_TOKEN__ == part
          path_a.pop
        else
          path_a.push part
        end
      end
      if path_a.length.nonzero?
        path_a.reduce ::Object do |m, s|
          if m.const_defined? s, false
            m.const_get s, false
          elsif m.const_probably_loadable? s  # etc
            m.const_get s, false
          elsif create_p
            m.const_set s, create_p.call
          elsif else_p
            break else_p[]
          else
            m.const_get s, false  # trigger the error, presumably
          end
        end
      end
    end

    Resolve_ = Resolve__.curry[ nil ]
    Resolve = Resolve_.curry[ nil ]

    BACK_TOKEN__ = '..'.freeze
    CONST_SEP__ = '::'.freeze
    FILE_SEP__ = '/'.freeze

    -> do  # #storypoint-55
      o = ::Module.new
      Mutex = -> p, method_name=nil do
        mut_h = { }
        -> *a do  # self should be a client module.
          r = did =  nil
          mut_h.fetch object_id do
            mut_h[ object_id ] = did = true
            r = module_exec( *a, & p )
          end
          did or raise o::Say_failure[ self, method_name ]
          r
        end
      end
      o::Say_failure = -> mod, method_name do
        if method_name
          "#{ o::Me[] } failure - cannot call `#{ method_name }` more #{
          }than once on a #{ mod }"
        else
          "#{ o::Me[] } failure - #{ mod }"
        end
      end
      o::Me = -> { "#{ Module }::Mutex" }
    end.call
  end
end
