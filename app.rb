require 'bundler'
Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper'


Val_Oise = Scrapper.new("http://annuaire-des-mairies.com/val-d-oise.html").perform
#/ Nous avons choisi comme nom d'instance Val d'Oise.