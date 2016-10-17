module Skylab::TMX

  class Models_::Installation

    class ManifestStream_via_Installation___

      def self.[] o
        new( o ).execute
      end

      def initialize inst

        @const_path_head = inst.participating_gem_const_path_head
        @exe_pfx = inst.participating_exe_prefix
        @gems_dir = inst.single_gems_dir
        @gem_pass_prefix = inst.participating_gem_prefix
      end

      def execute

        # first, find every known exe (~40) thru one filesystem glob call.

        exe_st = Common_::Stream.via_nonsparse_array(
          ::Dir[ "#{ @gems_dir }/#{ @gem_pass_prefix }*/bin/#{ @exe_pfx }*" ] )


        sep = ::Regexp.escape ::File::SEPARATOR
        _rxs = Gem_name_tools_[].RXS

        rx = /\A
          (?<gem_path> .+ #{ sep } (?<entry> #{ _rxs } ) )
          #{ sep } bin #{ sep }
          (?<exe_entry>#{ @exe_pfx }.+)
        \z/x

        md = nil
        prev_md = nil

        match_3 = -> exe_path do

          prev_md = md
          md = rx.match exe_path
          [ md[ :gem_name ], md[ :version ], md[ :exe_entry ] ]
        end

        category_gemname = nil
        category_version = nil
        items = nil

        stem_via_range = @gem_pass_prefix.length .. -1

        proto = Gem_Name_Elements_.new(
          nil, nil, nil, @const_path_head, @exe_pfx )

        flush = -> do

          gem_name = prev_md[ :gem_name ]

          gne = proto.dup
          gne.stem = gem_name[ stem_via_range ]
          gne.gem_name = gem_name
          gne.gem_path = prev_md[ :gem_path ]

          Models_::Node::Manifest.new(
            items, Load_Ticket_.new( gne ) )
        end

        body_p = nil
        p = -> do

          # then, group the exe's by sidesystem. we need to chunk them in this
          # manner because we expose the sidesystem differently based on whether
          # or not it has an eponymous exe ("tmx-flex2treetop", for eg.), and
          # and we won't know whether it does or not unless we look at all of
          # them (per sidesystem).

          exe_path = exe_st.gets
          if exe_path

            category_gemname, category_version, item = match_3[ exe_path ]
            items = [ item ]
            p = body_p
            body_p[]
          else
            self._COVER_ME_just_nothing
          end
        end

        body_p = -> do

          # assume there is a category and one or more items

          begin
            exe_path = exe_st.gets
            if exe_path
              gemname, version, item = match_3[ exe_path ]
              if category_gemname == gemname
                # "normal"

                if category_version != version
                  self._IMPLEMENT_ME
                end

                items.push item
                redo
              end
              # flush point
              result = flush[]
              category_gemname = gemname
              category_version = version
              items = [ item ]
              break
            end
            # end of stream
            result = flush[]
            p = EMPTY_P_
          end while nil
          result
        end

        Common_.stream do
          p[]
        end
      end

      EMPTY_P_ = -> { NIL_ }
    end
  end
end
