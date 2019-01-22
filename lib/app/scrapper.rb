# require 'rubygems'
# require 'nokogiri'
# require 'open-uri'
#require 'json'

class Scrapper
	attr_accessor :url_dept, :urls_town, :email_town

	def initialize(url_dept)
		@url_dept = url_dept
		@urls_town = []
		@email_town = {}
	end 

	#1 Première méthode : Collecte de l'email d'une mairie d'une ville du Val d'Oise
	def get_townhall_email(townhall_url)
		page = Nokogiri::HTML(open(townhall_url)) #/ on indique un site URL neutre qui sera indiqué dans la prochaine méthode

		email = page.xpath('//*[contains(text(), "@")]').text
		town = page.xpath('//*[contains(text(), "Adresse mairie de")]').text.split #/ on divise la string pour pouvoir récupérer uniquement le nom de la ville

		#@email_town << {town[3] => email} #/ on indique la position du nom de la ville dans la string pour la récupérer
		@email_town[town[3]] = email #/ on indique la position du nom de la ville dans la string pour la récupérer
		@email_town
	end

	#2 Deuxième méthode : Collecte de toutes les URLs des villes du Val d'Oise
	def get_townhall_urls
		page = Nokogiri::HTML(open(@url_dept))
		
		urls = page.xpath('//*[@class="lientxt"]/@href') #/ toutes les URLs appartiennent à la classe lientxt

		urls.each do |url| #/ pour chaque URLs récupérées, il faut leur indiquer l'url parent "http://annuaire-des-mairies.com"
			url = "http://annuaire-des-mairies.com" + url.text[1..-1] #/ A l'url parent, on ajoute les urls récupérées du deuxième caractère au dernier caractère, car on veut se débarasser du point devant.
			@urls_town << url		
		end
		return @urls_town
	end

	def save_as_JSON

			File.open("db/emails.json","w") do |email|
  				@email_town.each do |mail|
  					email.write(mail.to_json + "\n" )
  				end
			end	
	end

	def save_as_Google_sheet

			File.open("db/emails.json","w") do |email|
  				@email_town.each do |mail|
  					email.write(mail.to_json + "\n" )
  				end
			end	
	end
	
	def perform
		get_townhall_urls

		@urls_town.each do |townhall_url| #/ pour chaque URL d'une ville du Val d'Oise, on associe l'adresse mail de la mairie
			get_townhall_email(townhall_url)
		end

		save_as_JSON
	end
end

