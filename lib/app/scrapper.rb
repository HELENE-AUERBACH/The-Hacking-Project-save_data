require_relative './page_of_html_document'
require 'json' # Require the JSON library

class Scrapper
  attr_reader :all_townhall_urls_hashes_array # array de hashes des e-mails des mairies du Département du Val d'Oise (France)
  
  def get_townhall_email(townhall_url)
    # Retourne l’e-mail d'une mairie à partir de l'URL de la page particulière de cette mairie, si cet e-mail a pu être trouvé,
    # renvoie nil sinon
    townhall_email = nil
    page = PageOfHtmlDocument.new(townhall_url).page # Ouvre et parse la page HTML dont on donne l'URL et la stocke dans la variable locale page
    if !page.nil? && page.instance_of?(Nokogiri::HTML::Document)
      #title = page.xpath('/html/head/title').text
      #puts "Je vais scrapper la page intitulée \"#{title}\" (\"#{townhall_url}\")."
      townhall_email = page.xpath("/html/body/div[1]/main/section[2]/div/table/tbody/tr[4]/td[2]").text
    end
    townhall_email
  end

  def get_townhall_urls(department_url)
    # Retourne les URLs des pages des mairies de toutes les villes du département à partir de l'URL de la page particulière de ce département,
    # si ces URLs ont pu être trouvés, sous la forme d'un array de hashes qui associent au nom de chaque ville du département l'e-mail
    # (s'il a pu être trouvé, ou nil sinon) de sa mairie,
    # et renvoie nil si ces URLs n'ont pas pu être trouvées
    all_townhall_urls_hashes_array = []
    page = PageOfHtmlDocument.new(department_url).page # Ouvre et parse la page HTML dont on donne l'URL et la stocke dans la variable locale page
    if !page.nil? && page.instance_of?(Nokogiri::HTML::Document)
      #title = page.xpath('/html/head/title').text
      #puts "Je vais scrapper la page intitulée \"#{title}\" (\"#{department_url}\")."
      all_townhall_urls_links = page.xpath("//a[contains(@class, 'lientxt')]")
      if !all_townhall_urls_links.nil? && all_townhall_urls_links.instance_of?(Nokogiri::XML::NodeSet)
        puts "Il y a #{all_townhall_urls_links.length} URLs de pages pour les mairies de ce département."
        all_townhall_urls_links.each do |townhall_url_link|
          town_name = townhall_url_link.text
          # Remplacement du "." qui débute le lien trouvé par "https://www.annuaire-des-mairies.com"
          townhall_url = "https://www.annuaire-des-mairies.com" + townhall_url_link['href'][1..(townhall_url_link['href']).length-1]
          #puts "La page de la Mairie de la ville de \"#{town_name}\" a pour URL \"#{townhall_url}\"."
          if !town_name.nil? && !townhall_url.nil?
            townhall_email = get_townhall_email(townhall_url)
            all_townhall_urls_hashes_array << {town_name => townhall_email}
          end
        end
      end
    end
    all_townhall_urls_hashes_array
  end

  def save_as_JSON(file_name)
    if check_name(file_name) # On vérifie le nom du fichier à créer via une méthode check_name (cf. plus bas)
      if !@all_townhall_urls_hashes_array.nil? && @all_townhall_urls_hashes_array.instance_of?(Array) && @all_townhall_urls_hashes_array.length > 0
        simple_hash = {} 
        @all_townhall_urls_hashes_array.each { |hash| simple_hash.merge!(hash) } # Transforme un tableau de hashes en un seul hash
        puts "\nTournicoti, tournicoton, voici un majestueux Hash de #{simple_hash.count} keys :\n #{simple_hash}!!!\n" 
        File.open("./db/" + file_name, "w") do |file| # le chemin relatif est donné par rapport au répertoire d'où est lancée l'application app.rb
          file.write(JSON.pretty_generate(simple_hash))
        end
      else
        puts "Impossible de sauvegarder le résultat du scrapping dans un fichier au format JSON."
      end
    else
      puts "Impossible de créer un fichier de nom \"#{file_name}\"."
    end
  end
  
  def perform
    department_url = "https://www.annuaire-des-mairies.com/val-d-oise.html"
    @all_townhall_urls_hashes_array = get_townhall_urls(department_url)
    puts "Voici le fameux array de hashes des e-mails des mairies du Département du Val d'Oise (France) :"
    puts "#{@all_townhall_urls_hashes_array}"
    puts "J'en profite pour le sauvegarder pour la postérité dans un fichier nommé \"emails.json\" au format JSON que vous pourrez trouver sous le répertoire \"./db\"."
    save_as_JSON("emails.json")
  end

  private # Toutes les méthodes définies ci-après sont privées : il est interdit de pouvoir les appeler en dehors du code de la classe (donc interdit même dans le "main" ici-même dans ce fichier)

  def check_name(file_to_save_name)
    # Vérification simple du format du nom du fichier à sauvegarder.
    # Si le nom est ok, ça renvoie TRUE, sinon ça renvoie FALSE.
    # On veut vérifier que le file_to_save_name n'est ni nil, ni une instance d'une autre classe que celle des String, ni une chaîne vide :
    !file_to_save_name.nil? && file_to_save_name.instance_of?(String) && !file_to_save_name.strip.empty?
  end
end
