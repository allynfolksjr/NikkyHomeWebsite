class NikkyHome < Sinatra::Base

  configure do
    set :static_cache_control, [:public, :max_age => 60]
  end

  get '/' do
    haml :index, :locals => {:page_title => "Nikky!"}
  end

  get '/about-me' do
    haml :about_me, :locals => {:page_title => "About Nikky"}
  end

  get '/contact-me' do
    haml :contact_me, :locals => {:page_title => "Contact Nikky"}
  end

  get '/js/index.js' do
    coffee :index
  end

  get '/resume' do
    # markdown :resume, :layout_engine => :haml
    haml :resume, :locals => {:page_title => "Nikky's Resume"}
  end

  helpers do
    def activeLink(link)
      return "%li.active" if request.path_info == link
      # haml "%li"
    end

  end



end
