require 'sass/plugin/rack'

Bundler.require

#h/t http://blog.bts.co/post/991947650/using-sinatra-with-sass-scss
Sass::Plugin.options[:template_location] = 'views/stylesheets'
use Sass::Plugin::Rack

require './nikky_home'
run NikkyHome
