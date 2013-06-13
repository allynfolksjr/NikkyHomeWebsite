

class NikkyHome < Sinatra::Base

  set :logging, true # Sends log to STDOUT

  configure do
    set :static_cache_control, [:public, :max_age => 60]
  end

  get '/' do
    haml :index, :locals => {:page_title => "Nikky Southerland"}
  end

  get '/tech-cred' do
    haml :tech_cred, :locals => {:page_title => "Tech Cred"}
  end

  get '/contact-me' do
    haml :contact_me, :locals => {:page_title => "Contact Nikky"}
  end

  get '/js/nikky.js' do
    coffee :nikky
  end

  get '/resume' do
    # markdown :resume, :layout_engine => :haml
    haml :resume, :locals => {:page_title => "Nikky's Resume"}
  end

  get '/projects' do
    haml :projects, :locals => {:page_title => "Nikky's Projects"}
  end

  helpers do
    def activeLink(link)
      return "%li.active" if request.path_info == link
      # haml "%li"
    end

  end

end

