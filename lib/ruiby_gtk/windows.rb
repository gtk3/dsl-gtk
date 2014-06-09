# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL
###############################################################################################
#            windows.rb : main ruiby windows  
###############################################################################################

class Ruiby_gtk < Gtk::Window
  include ::Ruiby_dsl
  include ::Ruiby_threader
  def initialize(title,w,h)
    super()
    init_threader()
    #threader(10) # must be call by user window, if necessary
    set_title(title)
    set_default_size(w,h)
    signal_connect "destroy" do 
        if @is_main_window
          @is_main_window=false
          Gtk.main_quit
        end
    end
    iconfn=Ruiby::DIR+"/../media/ruiby.png"
    set_icon(iconfn) if File.exists?(iconfn)
    p iconfn
    set_window_position Gtk::Window::Position::CENTER  # default, can be modified by window_position(x,y)
    @lcur=[self]
    @ltable=[]
    @current_widget=nil
    @cur=nil
    begin
      component  
    rescue
      error("COMPONENT() : "+$!.to_s + " :\n     " +  $!.backtrace[0..10].join("\n     "))
      exit(1)
    end
	Ruiby.apply_provider(self)
    begin
      show_all 
    rescue
      puts "Error in show_all : illegal state of some widget? "+ $!.to_s
    end
    if ARGV.any? {|v| v=="take-a-snapshot" }
      after(100) { 
        snapshot("#{Dir.exists?("media") ? "media/" : ""}snapshot_#{File.basename($0)}.png")
        after(100) { exit(0)  } 
      }
    end
  end
  def on_resize(&blk)
    self.resizable=true
    signal_connect("configure_event") { blk.call } if blk
  end
  def on_destroy(&blk) 
        signal_connect("destroy") { blk.call }
  end
  def ruiby_exit()
    Gtk.main_quit 
  end
  def component
    raise("Abstract: 'def component()' must be overiden in a Ruiby class")
  end

  # change position of window in the desktop. relative position works only in *nix
  # system.
  def rposition(x,y)
    if x==0 && y==0
      set_window_position Window::POS_CENTER
      return
    elsif     x>=0 && y>=0
      gravity= Gdk::Window::Gravity::NORTH_WEST
    elsif   x<0 && y>=0
      gravity= Gdk::Window::Gravity::NORTH_EAST
    elsif   x>=0 && y<0
      gravity= Gdk::Window::Gravity::SOUTH_WEST
    elsif   x<0 && y<0
      gravity= Gdk::Window::Gravity::SOUTH_EAST
    end
    move(x.abs,y.abs)
  end
  # show or supress the window system decoration
  def chrome(on=false)
    set_decorated(on)
  end
end

# can be included by a gtk windows, for  use ruiby.
# do an include, and then call ruiby_component() with bloc for use ruiby dsl
module Ruiby  
  include ::Ruiby_dsl
  include ::Ruiby_threader
  include ::Ruiby_default_dialog
  
  # ruiby_component() must be call one shot for a window, 
  # it initialise ruiby.
  # then append_to(),append_before()...  can be use fore dsl usage
  def ruiby_component()
    init_threader()
    @lcur=[self]
    @ltable=[]
    @current_widget=nil
    @cur=nil
    begin
      yield
    rescue
      error("ruiby_component block : "+$!.to_s + " :\n     " +  $!.backtrace[0..10].join("\n     "))
      exit!
    end
	Ruiby.apply_provider(self)
	show_all
  end
end

class Ruiby_dialog < Gtk::Window 
  include ::Ruiby_dsl
  include ::Ruiby_default_dialog
  def initialize() end
end