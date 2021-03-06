# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL

# create a dialog which contain a little editor
# text is colorize for ruby lang
class Editor < Ruiby_gtk 
    def initialize(w,filename,width=350,&blk)
      @filename=filename
      super("Edit #{filename[0..40]}",width,0)
      transient_for=w
      @blk=blk
    end	
    def component()
      stack do
          if ed=source_editor()
            @edit=slot(ed).editor
            @edit.buffer.text=File.exists?(@filename) ? File.read(@filename) : @filename
          end
          sloti( button("Exit") { 
           if @blk 
             ok=@blk.call(@edit.buffer.text)
             destroy() if ok 
           else
             destroy()
           end           
          })
      end
    end # endcomponent
end
# create a dialogue which sho data in a grid
# @title:	title of the dialog
# @w,h:		default width/heiht of the dialog
# @cations:	a list of title, for each colomn
# @data:	data in grid : array of array
# @options : give a list of button/bloc for append custom button for action
#           on a selected line
#
# Usage:
#	a=PopupTable.new("title of dialog",800,500,
#		%w{first-name last-name age},
#		[%w{regis aubarede 12},%w{siger ederabu 21},%w{baraque aubama 12},%w{ruiby ruby 1}],
#		{
#		  "Kill" => proc {|line| system("taskkill","/f","/pid",line[1]) ; refresh_process() },
#		  "Detail" => proc {|line| $app.alert(line) },
#		  "Refresh" => proc {|line|  refresh_process() },
#		  "button-orrient" => "h"
#	    })
#	. . . . . . .
#   a.update([%w{nelson mandela 99}])
#

class PopupTable < Ruiby_gtk 
	attr_reader :mgrid
    def initialize(title,width=350,height=600,captions=[["oups"]],data=[["no data"]],options={},&bloc)
		@bloc=bloc
		@captions=captions
		@data=data
		@options=options
		@options["button-orrient"] ||= "r"
        super(title,width,height)
    end	
	def update(data)
		@data=data
		@grid.set_data(@data)	
	end
	def component()
	  stack do
		flow {
			stacki { space;_button_list;space } if @options["button-orrient"] =~ /^l/i
			@grid=grid(@captions,100,150)
			stacki { space;_button_list;space } if @options["button-orrient"] =~ /^r/i
		}
		@mgrid=@grid
		@grid.set_data(@data)	
		flowi { button_list } if @options["button-orrient"] =~ /^h/i
		stacki { button_list } if @options["button-orrient"] =~ /^v/i
		sloti( button(" Exit ") { @bloc ? @bloc.call(@grid.get_data()) : destroy()} )
	  end
	end 
	def _button_list()
		@options.each do |name,action| 
			next unless   action.respond_to?(:call)
			button(name) {
				next unless  @grid.index()
				begin
					noline=@grid.index().to_s.to_i
					action.call(@data[noline] ) 
				rescue 
					error($!) 
				end
			}
		end
	end

end

# Create a Form dialogue dialogue. 
# @title:	title of the dialog
# @w,h:		default width/heiht of the dialog
# @data:	data in grid : hash, must be an exemple (each field must hacve a value with good type)
# @options : give a list of button/bloc for append custom button/action 
#
#	PopupForm.new("Process",0,0,{
#			"name" => "regis",
#			"last-name" => "aubarede",
#			"int" => 22
#			"float" => 22.333
#		},{
#			"Update" => proc {|w,data|  data['name']="siger" ; w.set_data(data)},
#			"Abort" => proc {|w,data|  w.destroy},
#		}
#	) { |hvalues| hvalues }

class PopupForm < Ruiby_gtk
    def initialize(title,width=350,height=600,data={},options={},opt={},&bloc)
		@bloc= bloc 
		@data=data
		@options=options
		@popt=opt
		@options["button-direction"] ||= "h"
		@title=title
        super(title[0..50],width,height)
    end	
	def update(data)
		@form.set_data(data)
	end
	def component()
	  stack do
		labeli(@title)
		@form=properties("",@data,@popt) { |a| @bloc.call(a) if @bloc }
		case @options["button-direction"] 
			when /^h/i then flowi  { button_list }
			when /^v/i then stacki { button_list }
		end
		sloti( button(" Exit ") { destroy() }) if @options.size==0
	  end
	end 
	def button_list()
		@options.each do |name,action| 
			next unless   action.respond_to?(:call)
			button(name) { action.call(@form,@form.get_data() )  rescue  error($!)  }
		end
	end

end

class Object
  def wtree(w)
    log "*"*60
    _wtree("   ",w)
    log "*"*60
  end
  def _wtree(header,w)
    log "#{header}--#{w.class} : #{w.text rescue ''}"
    if w.respond_to?(:children)
        cheader=header+"   |"
        w.children.each { |cw| _wtree(cheader,cw) } 
    end
 end
end
