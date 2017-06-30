# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

# require 'scraperwiki'
# require 'mechanize'
#
# agent = Mechanize.new
#
# # Read in a page
# page = agent.get("http://foo.com")
#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".

#!/usr/bin/env ruby

require 'scraperwiki'

# Saving data:
# unique_keys = [ 'id' ]
# data = { 'id'=>12, 'name'=>'violet', 'age'=> 7 }
# ScraperWiki.save_sqlite(unique_keys, data)

require 'nokogiri'
require 'json'
require 'rubygems'
require 'mechanize'
require 'csv'

# SPECIFY YOUR VARIBLES HERE:
url = 'http://planning.broads-authority.gov.uk/online-applications/search.do?action=advanced&searchType=Appeal' #link to the advanced search page on the local authority website
url_beginning = "http://planning.broads-authority.gov.uk" #the first bit of the url (ending with "gov.uk")
council = "Broads_Authority" #specify the council name
startDate = "01/07/2014" #specify decision date start
endDate = "31/03/2017" #specify decision date end

# this is to instantiate a new mechanize object
agent = Mechanize.new

# this is to fetch the webpage
page = agent.get(url)

# this is to print the page to see what html names are used for
# the form and fields
#pp page

# this is to fetch the form
search_form = page.form('searchCriteriaForm')

# this is to set the values of two fields of the form
search_form['date(appealLodgedStart)'] = startDate
search_form['date(appealLodgedEnd)'] = endDate

# this is to submit the form
page = agent.submit(search_form)

# this is to create an empty array to store the links (results)
links_array = []

# the following loop is to find all links on the page which include
# the "appealDetails" wording and store them in the links_array
# then, to move to the "next" page and do the same,
# until there is no "next"

loop do
	page.links.each do |link|
		if link.href.include?"appealDetails"
		links_array.push(link.href)
		end
	end

	if link = page.link_with(:text => "Next")
	page = link.click
	else break
	end
end

# this is to convert the links to strings,
# then, to suplement urls with the missing text:
# "http://planning.xxxxxxxx.gov.uk"

links_array.map! do |item|
	item.to_s
	item = "#{url_beginning}#{item}"
end

# pp links_array

# this is to define empty arrays where we will store all the details
# on individual applications
reference_array = []
address_array = []
nature_array = []
type_array = []
outcome_array = []
decdate_array = []

# the following .each method is to scrap the data on the aplications'
# reference number, address, nature
# appeal type, decision, decision date
# Then, to store the scraped data in the relevant arrays

links_array.each do |appeal|

# this is to instantiate a new mechanize object
    agent = Mechanize.new

# this is to fetch the webpage and parse HTML using Nokogiri
    sub_page = ScraperWiki::scrape(appeal)
    parse_sub_page = Nokogiri::HTML(sub_page)
	
	# *****
# this is to parse the data, remove spaces and push the data
# to the relevant arrays. The code also removes comas from
# the nature descriptions. Please check and amend the td
# positions in brackets: []

	reference = parse_sub_page.css('#appealDetails').css('td')[0].text
	reference_tidied = reference.strip
	reference_array.push(reference_tidied)

	address = parse_sub_page.css('#appealDetails').css('td')[2].text
	address_tidied = address.strip
	address_array.push(address_tidied)

	nature = parse_sub_page.css('#appealDetails').css('td')[3].text
	nature_tidied = nature.strip
	nature_array.push(nature_tidied)
	nature_array.each do |nature|
		nature.gsub(",","")
	end

	type = parse_sub_page.css('#appealDetails').css('td')[5].text
	type_tidied = type.strip
	type_array.push(type_tidied)

	outcome = parse_sub_page.css('#appealDetails').css('td')[6].text
	outcome_tidied = outcome.strip
	outcome_array.push(outcome_tidied)

	decdate = parse_sub_page.css('#appealDetails').css('td')[11].text
	decdate_tidied = decdate.strip
	decdate_array.push(decdate_tidied)

end

# this is to add one more array: council name
counting = links_array.count
council_array = Array.new(counting,council)

# *****
# this is to transpose the data in the arrays in order to
# change the layout of data

table = [reference_array, address_array, nature_array, type_array, outcome_array, decdate_array, links_array, council_array].transpose
pp table

# this is the loop to save the data in the SQlite table

# i = 0

# while i < counting

# data = { "reference"=>reference_array[i], "altreference" =>altreference_array[i], "received"=>received_array[i], "validated"=>validated_array[i], "address"=>address_array[i], "proposal"=>proposal_array[i], "outcome"=>outcome_array[i], "decided"=>decided_array[i], "links"=>links_array[i], "council"=>council_array[i] }
# unique_keys = [ "reference" ]
# ScraperWiki::save_sqlite(unique_keys, data, table_name = "basildon",verbose=2)

# i = i + 1
# end


