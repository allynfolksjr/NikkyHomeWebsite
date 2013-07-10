

class NikkyHome < Sinatra::Base

  set :logging, true # Sends log to STDOUT

  configure do
    set :static_cache_control, [:public, :max_age => 60]
  end

  get '/' do
    haml :index, locals: {page_title: "Nikky Southerland"}
  end

  get '/technologies' do
    haml :technologies, locals: {page_title: "Technologies"}
  end

  get '/contact-me' do
    haml :contact_me, locals: {page_title: "Contact Nikky"}
  end

  get '/js/nikky.js' do
    coffee :nikky
  end

  get '/resume' do
    # markdown :resume, :layout_engine => :haml
    haml :resume, locals: {page_title: "Nikky's Resume"}
  end

  get '/projects' do
    haml :projects, locals: {page_title: "Nikky's Projects"}
  end

  get '/about-me' do
    haml :about_me, locals: {page_title: "About Nikky"}
  end

  helpers do
    def activeLink(link)
      return "%li.active" if request.path_info == link
    end

  end

end

