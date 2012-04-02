﻿#!/usr/bin/ruby
# encoding: utf-8
$time_start=Time.now.to_f*1000
def mlog(text)
 puts "%8f | %s" % [(Time.now.to_f*1000-$time_start),text.to_s]
end
mlog 'before require gtk2'
require 'gtk2'
mlog 'before require ruiby'
require_relative '../lib/ruiby'
mlog 'after require ruiby'


class RubyApp < Ruiby_gtk
    def initialize
		mlog "befor init"
        super("Testing Ruiby",900,0)
		mlog 'after init'
		after(1) { mlog("first update") }
    end
	
	
def component()        
  mlog 'before Component'
  stack do
    sloti(htoolbar(
		"open/tooltip text on button"=>proc { edit(__FILE__) },
		"close/fermer le fichier"=>nil,
		"undo/defaire"=>nil,
		"redo/refaire"=>proc { alert("e") }
	   ))
    sloti(label( <<-EEND ,:font=>"Arial 12"))
     This window is test & demo of Ruiby capacity,
	   ~ 170 Lines of code,
     (Ruiby version is #{Ruiby::VERSION})
	EEND
	
    
    separator
    flow {
      @left=stack {
        frame("") { table(2,10,{set_column_spacings: 3}) do
          row { cell_right(label  "mode de fontionnement"); cell(button("set") { alert("?") }) }
          row { cell_right label  "vitesse"               ; cell(entry("aa"))  }
          row { cell_right label  "size"                  ; cell ientry(11,{:min=>0,:max=>100,:by=>1})  }
          row { cell_right label  "feeling"               ; cell islider(10,{:min=>0,:max=>100,:by=>1})  }
          row { cell_right label  "speedy"                ; cell(toggle_button("on","off",false) {|w| w.label=w.active?() ? "Off": "On" })  }
          row { cell       label  "acceleration type"     ; cell hradio_buttons(%w{aa bb cc},1)  }
          row { cell      label  "mode on"               ; cell check_button("",false)  }
          row { cell      label  "mode off"              ; cell check_button("",true)  }
          row { cell_left label  "Variable"              ; cell combo({"aaa"=>1,"bbb"=>2,"ccc"=>3},1) }
          row { p 4;cell_left label  "Couleur"               ; cell color_choice()  }
        end }
        frame("Buttons in frame") {
          flow { sloti(button("packed with sloti()") {alert("button packed with sloti()")}) 
		         @bref=sloti(button("bb")) ;  button("packed with slot()") ; 
		  }
        }
        flow do
          stack {
            button("Couleur") {
              #alert("alert !") ; error("error !") ; ask("ask !") ;trace("trace !") ;
              @color=ask_color()
            }
            sloti(label('Epaisseur'))
            @epaisseur=sloti(islider(1,{:min=>1,:max=>30,:by=>1}))
          }
          @ldraw=[] ; @color=  ::Gdk::Color.parse("#33EEFF");
          canvas(100,100,{ 
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
        end 
      }
      separator
      notebook do
        page("","#home") { label("A Notebook Page with icon as button-title",{font: "Arial 18"}) }
        page("List & grid") {
			flow {
				frame("List") {
					stack {
						@list=list("Demo",0,100)
						flow {
							button("s.content") { alert("Selected= #{@list.selection()}") }
							button("s.index") { alert("iSelected= #{@list.index()}") }
						}
					}
				}
				frame("Grid") {
					stack { stacki {
						@grid=grid(%w{nom prenom age},100,150)
						flow {
							button("s.content") { alert("Selected= #{@grid.selection()}") }
							button("s.index") { alert("iSelected= #{@grid.index()}") }
						}
					} }
				}
			}
			10.times { |i| @list.add_item("Hello #{i}") }
			@grid.set_data((1..30).map { |n| ["e#{n}",n,1.0*n]})
        }
        page("Property Edit.") {
          flowi {
			sloti(button("#harddisk") { alert("image button!")})
			tt={int: 1,float: 1.0, array: [1,2,3], hash: {a:1, b:2}}
			propertys("props editable",tt,{edit: true}) { |a| log(a.inspect);log(tt.inspect) }
			propertys("props show",tt)
		  }
		  calendar()
	    }
        page("Big PropEditor") {
			h={};70.times { |i| h[i]= "aaa#{i+100}" }
			propertys("very big propertys editable",h,{edit: true,scroll: [100,400]}) { |a| log(a.inspect);log(h.inspect) }
        }
        page("Source Editor") {
		  @editor=source_editor(:width=>200,:height=>300,:lang=> "ruby", :font=> "Courier new 8",:on_change=> proc { edit_change }).editor
		  @editor.buffer.text='def comp'+'onent'+File.read(__FILE__).split(/comp[o]nent/)[1]
        }
		page("Menu") {
			stack {
				menu_bar {
					menu("File Example") {
						menu_button("Open") { alert("o") }
						menu_button("Close") { alert("i") }
						menu_separator
						menu_checkbutton("Lock...") { |w| 
							w.toggle
							append_to(@f) { button("ee #{}") }
						}
					}
					menu("Edit Example") {
						menu_button("Copy") { alert("a") }
					}
				} 
				@f=stacki { }
			}
		}
        page("Accordion") {
			flow {
				accordion do
					("A".."G").each do |cc| 
						aitem("#{cc} Flip...") do
								5.times { |i| 
									alabel("#{cc}e#{i}") { alert("#{cc} x#{i}") }
								}
						end
					end
				end
				label "x"
			}
		}
		page("Pan & Scrolled") do
			stack {
				sloti(label("Test scrolled zone"))
				separator
				stack_paned 300,0.5 do [
				  vbox_scrolled(-1,100) { 
					30.times { |i| 
					  flow { sloti(button("eeee#{i}"));sloti(button("eeee")) }
					}
				  },
				  vbox_scrolled(100,100) { 
					30.times { |i| 
					  flow { sloti(button("eeee#{i}"));sloti(button("eeee"));sloti(button("aaa"*100)) }
					}
				  }] end
			  }
	    end      
	  end # end notebook
    } # end flow
    sloti(button("Test Specials Actions...") { p @bref ; do_special_actions() })
    sloti( button("Exit") { exit! })
	mlog 'after Component'
  end
end # endcomponent
  def edit_change()
	alert("please, do not change my code..")
  end

  def do_special_actions()
    log("Coucou")
    prompt("test prompt()!\nveuillezz saisir un text de lonqueur \n plus grande que trois") { |reponse| reponse && reponse.size>3 }
    log("append before :",slot_append_before( button("new before") ,@bref) )
    log("append after :",slot_append_after(  button("new after"),@bref)   )
    log("file : " , ask_file_to_read(".","*.rb")  )
    log("file : ", ask_file_to_write(".","*.rb") )
    log("dir : " , ask_dir() )
    100.times { |i| log("#{i} "+ ("*"*(i+1))) }
  end
end
# test autoload plugins
Exemple.new

Ruiby.start do
    window = RubyApp.new
end
