
class Scrapper
	attr_accessor :url_dept, :urls_town, :email_town
#/ On intègre trois éléments en tant que variables d'instance.

#1 Première étape : Initialisation - exécution de code à la création des instances
	def initialize(url_dept)
		@url_dept = url_dept
		@urls_town = []
		@email_town = {}
	end 

#2 Deuxième étape : Scrapping
#/ 2a - Collecte de l'email d'une mairie d'une ville du Val d'Oise
	def get_townhall_email(townhall_url)
		page = Nokogiri::HTML(open(townhall_url)) #/ on indique un site URL neutre qui sera indiqué dans la prochaine méthode

		email = page.xpath('//*[contains(text(), "@")]').text
		town = page.xpath('//*[contains(text(), "Adresse mairie de")]').text.split #/ on divise la string pour pouvoir récupérer uniquement le nom de la ville
		@email_town[town[3]] = email #/ on intègre sous forme de hash les emails à la classe @email_town
		@email_town
	end

#/ 2b - Collecte de toutes les URLs des villes du Val d'Oise
	def get_townhall_urls
		page = Nokogiri::HTML(open(@url_dept))
		
		urls = page.xpath('//*[@class="lientxt"]/@href') #/ toutes les URLs appartiennent à la classe lientxt

		urls.each do |url| #/ pour chaque URLs récupérées, il faut leur indiquer l'url parent "http://annuaire-des-mairies.com"
			url = "http://annuaire-des-mairies.com" + url.text[1..-1] #/ A l'url parent, on ajoute les urls récupérées du deuxième caractère au dernier caractère, car on veut se débarasser du point devant.
			@urls_town << url		
		end
		return @urls_town
	end

#3 Troisième étape : Sauvegarde des données
#/ 3a - via JSON
	def save_as_JSON
	  File.open("db/emails.json","w") do |mail|
  		mail.puts(JSON.pretty_generate(@email_town)) #/ pour afficher les mails verticalement, utilisation de la fonction "pretty_generate"
  	  end	
	end

#/ 3b - via Spreadsheet
	def save_as_spreadsheet
		session = GoogleDrive::Session.from_config("config.json")
		ws = session.spreadsheet_by_key("1UAtn3oB21_a_gUM5TL8OK6Ud7zp6Z7z6c8tGYV6J4HA").worksheets[0]

		i = 2
		ws[1,1]= "Ville"
		ws[1,2] = "Contact"
		@email_town.each_pair  do |key, value| #/ on aurait pû utiliser each mais each_pair est plus conseillé lorsqu'il y a deux éléments 
			ws[i,1] = key
			ws[i,2] = value
			i += 1
		end
		ws.save 
		ws.reload
	end

#/ 3c - via CSV
	def save_as_csv
		CSV.open("db/emails.csv", "w") do |csv|
			csv << ["Ville", "Contact"]
			@email_town.each_pair  do |key, value|
			csv << [key, value]
		end
		end
	end


#4 Quatrième étape : Exécution du code - TADAAAM
	def perform
		get_townhall_urls

		@urls_town.each do |townhall_url| #/ pour chaque URL d'une ville du Val d'Oise, on associe l'adresse mail de la mairie
			get_townhall_email(townhall_url)
		end

		save_as_JSON
		save_as_spreadsheet
		save_as_csv
	end
end

