RUIBY
=====

A simple helper for building simple GUI ruby application rapidly.

'simple' meen 'without great look&feel precision' 

Inspirations from Shoes.

Hrsd codes (gtk) comme from green_shoes.

Based on gtk at first, should evolve for support awt (jruby) Forms (IronRuby) Qt...


Status
======
In developpement :
* basic widget works (stack/flow/button/label/entry....)
* threading support ok ( gui_invoke { } )
* in development : source editor, video
* waiting : data grid, list, treeview, systray

Demo Hard copy at :
http://regisaubarede.posterous.com/

Code:
http://github.com/raubarede/Ruiby

License
=======
LGPL, CC BY-SA

Exemple 
======
see samples in "./sample" directory


```ruby
def component()        
  stack do
    slot(label( <<-EEND
     This window is done with 55 LOC...
     50 lines for create widgets, but don't do any traitment !
     I will use that for Inscape extensions (SCADA Synoptics in SVG) 
    EEND
    ))
    separator
    flow {
      @left=stack {
        frame("") { table(2,10,{set_column_spacings: 3}) do
          row { cell label  "mode de fontionnement" ; cell(button("set") { alert("?") }) }
          row { cell label  "vitesse"               ; cell entry("aa")  }
          row { cell label  "size"                  ; cell ientry(11,{:min=>0,:max=>100,:by=>1})  }
          row { cell label  "feeling"               ; cell islider(10,{:min=>0,:max=>100,:by=>1})  }
        end }
      }
      separator
      notebook do
        page("Page of Notebook") {
          table(2,2) {
            row { cell(button("eeee"));cell(button("dddd")) }
            row { cell(button("eeee"));cell(button("dddd")) }
          }
        }
        page("eee","#home") {
          sloti(button("Eeee"))
          sloti(button("#harddisk") { alert("image button!")})
          sloti(label('#cdrom'))
        }
      end
      frame("") do
        stack {
          sloti(label("Test scrolled zone"))
          separator
          vbox_scrolled(-1,100) { 
            100.times { |i| 
              flow { sloti(button("eeee#{i}"));sloti(button("eeee")) }
            }
          }
          vbox_scrolled(100,100) { 
            100.times { |i| 
              flow { sloti(button("eeee#{i}"));sloti(button("eeee"));sloti(button("aaa"*100)) }
            }
          }
        }
      end      
    }
    sloti( button("Exit") { exit! })
  end
end # endcomponent
```


