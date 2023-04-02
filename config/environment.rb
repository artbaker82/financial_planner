require 'bundler/setup'
Bundler.require(:default)

Mongoid.load!(File.expand_path('mongoid.yml', 'config'))

Dir.glob(File.expand_path('../app/components/**/*.rb', __FILE__)).each { |file| require file }

Dir.glob(File.expand_path('../app/models/**/*.rb', __FILE__)).each { |file| require file }

# todo edit this file to make it work with console.rb
