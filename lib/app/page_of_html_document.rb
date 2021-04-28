#Les deux requires de gems suivants ne sont plus directement nécessaires car ils sont gérés automatiquement par "Bundler.require" dans "app.rb"
#require 'nokogiri' # Appelle la gem Nokogiri, LE parseur HTML de référence pour Ruby
#require 'open-uri' # Appelle la gem Open-URI, indispensable pour ouvrir une URL

class PageOfHtmlDocument
  attr_reader :page

  def initialize(url_to_scrap)
    # Ouvre l'URL souhaitée "url_to_scrap" sous Nokogiri et la stocke dans l'attribut "page" qui est retourné si l'URL a pu être trouvée
    # renvoie nil sinon
    page = nil
    if !url_to_scrap.nil? && url_to_scrap.instance_of?(String) && !url_to_scrap.strip.empty?
      #puts "L'URL qui vous intéresse est : \"#{url_to_scrap}\"."
      begin
        page = Nokogiri::HTML(URI.open(url_to_scrap))
      rescue Timeout::Error
        puts "Malheureusement, le site ne répond tout simplement pas et la demande a expiré."
        #exit # Sortie de l'application
      rescue OpenURI::HTTPError => e
        if e.message == '400 Bad Request'
          puts "Malheureusement, la requête \"#{url_to_scrap}\" est incorrecte." # handle 400 error
          #exit
        elsif e.message == '404 Not Found'
          puts "Malheureusement, la page \"#{url_to_scrap}\" n'a pas été trouvée." # handle 404 error
          #exit
        elsif e.message == '500 Internal Server Error'
          puts "Malheureusement, le serveur Web rencontre une difficulté pour trouver la page \"#{url_to_scrap}\"." # handle 500 error
          #exit
        else
          raise e
          #exit
        end
      rescue Errno::ENOENT
        puts "Malheureusement, le fichier \"#{url_to_scrap}\" n'a pas été trouvé." # handle "No such file or directory @ rb_sysopen" error
        #exit
      rescue SocketError # handle "Failed to open TCP connection to ... (getaddrinfo: Name or service not known)" error
        puts "Malheureusement, l'URL \"#{url_to_scrap}\" est incorrecte." # Le domaine peut ne pas exister (DNS error)
        #exit
      rescue Errno::ECONNREFUSED
        puts "Malheureusement, il n'y a aucun serveur en cours d'exécution sur l'adresse IP à laquelle vous voulez vous connecter."
        #exit
      end
    end
    @page = page
  end
end
