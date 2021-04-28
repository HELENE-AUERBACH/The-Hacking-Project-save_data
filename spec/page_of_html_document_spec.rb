require 'nokogiri' # Appelle la gem Nokogiri, LE parseur HTML de référence pour Ruby
require 'open-uri' # Appelle la gem Open-URI, indispensable pour ouvrir une URL
require_relative '../lib/app/page_of_html_document'

describe "the initialize method" do
  it "should return page, and page is not nil" do
    expect(PageOfHtmlDocument.new("https://www.google.com").page).not_to be_nil
  end

  it "should return nil if the \"url_to_scrap\" argument is nil either is NOT a nonempty String or if this URL can't be found, etc." do
    expect(PageOfHtmlDocument.new(nil).page).to eq(nil)
    expect(PageOfHtmlDocument.new([]).page).to eq(nil)
    expect(PageOfHtmlDocument.new({}).page).to eq(nil)
    expect(PageOfHtmlDocument.new("").page).to eq(nil)
    expect(PageOfHtmlDocument.new("   ").page).to eq(nil)
    expect(PageOfHtmlDocument.new("http://www.ma_page_sur_Toto.fr").page).to eq(nil)
    expect(PageOfHtmlDocument.new('127.0.0.1').page).to eq(nil)
    expect(PageOfHtmlDocument.new("ma_page_sur_Toto.html").page).to eq(nil)
    # J'ai voulu tester l'erreur 500 qu'avait eue Kleber DA CUNHA le jour-même de la correction de son exercice validant,
    # mais, "manque de bol!", aujourd'hui, le serveur répond pour "https://www.nosdeputes.fr/deputes" :( 
    #expect(PageOfHtmlDocument.new("https://www.nosdeputes.fr/deputes").page).to eq(nil)
  end
end
     
