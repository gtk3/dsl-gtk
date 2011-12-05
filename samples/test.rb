﻿#!/usr/bin/ruby
# encoding: utf-8
require_relative 'ruiby'


class RubyApp < Ruiby_gtk
    def initialize
        super("Testing Ruiby",900,0)
    end
def component()        
  stack do
    slot(htoolbar(
		"open/tooltip text on button"=>proc { edit(__FILE__) },
		"close/fermer le fichier"=>nil,
		"undo/defaire"=>nil,
		"redo/refaire"=>proc { alert("e") },"ee"=>nil
	))
    slot(label( <<-EEND
     This window is demoof Ruiby
     50 lines for create widgets, but don't do any traitment !
	 ~ 100 LOC
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
          row { cell label  "speedy"                ; cell(toggle_button("on","off",false) {|w| w.label=w.active?() ? "Off": "On" })  }
          row { cell label  "acceleration type"     ; cell hradio_buttons(%w{aa bb cc},1)  }
          row { cell label  "mode on"               ; cell check_button("",false)  }
          row { cell label  "mode off"              ; cell check_button("",true)  }
          row { cell label  "Variable"              ; cell combo({"aaa"=>1,"bbb"=>2,"ccc"=>3},1) }
          row { cell label  "Couleur"               ; cell color_choice()  }
        end }
        frame("Buttons in frame") {
          flow { sloti(button("packed with sloti()") {alert("button packed with sloti()")}) 
		             @bref=sloti(button("bb")) ;  slot(button("packed with slot()")) ; }
        }
        flow do
          stack {
            slot(button("Couleur") {
              #alert("alert !") ; error("error !") ; ask("ask !") ;trace("trace !") ;
              @color=ask_color()
            })
            sloti(label('Epaisseur'))
            @epaisseur=sloti(islider(1,{:min=>1,:max=>30,:by=>1}))
          }
          @ldraw=[] ; @color=  ::Gdk::Color.parse("#33EEFF");
          slot(canvas(100,100,{ 
            :expose     => proc { |w,cr|  
              @ldraw.each do |line|
                next if line.size<3
                color,ep,pt0,*poly=*line
                cr.set_line_width(ep)
                cr.set_source_rgba(color.red/65000.0, color.green/65000.0, color.blue/65000.0, 1)
                cr.move_to(*pt0)
                poly.each {|px|    cr.line_to(*px) } 
                cr.stroke  
            end
            },          
            :mouse_down => proc { |w,e|   no= [e.x,e.y] ;  @ldraw << [@color,@epaisseur.value,no] ;  no    },
            :mouse_move => proc { |w,e,o| no= [e.x,e.y] ; (@ldraw.last << no) if no[0]!=o[0] || no[1]!=o[1] ; no },
            :mouse_up   => proc { |w,e,o| no= [e.x,e.y] ; (@ldraw.last << no) ; no}
            })
          )
        end 
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
    sloti(button("Test Specials Actions...") { p @bref ; do_special_actions() })
    sloti( button("Exit") { exit! })
  end
end # endcomponent

  def do_special_actions()
    log("Coucou")
    prompt("test prompt()!\nveuillezz saisir un text de lonqueur \n plus grande que trois") { |reponse| reponse && reponse.size>3 }
    log("append before :",slot_append_before( button("new before") ,@bref) )
    log("append after :",slot_append_after(  button("new after"),@bref)   )
    log("file : " , ask_file_to_read(".","*.rb")  )
    log("file : ", ask_file_to_write(".","*.rb") )
    log("dir : " , ask_dir()                      )
    100.times { |i| log("#{i} "*(i+1)) }
  end
end

Gtk.init
    window = RubyApp.new
Gtk.main
