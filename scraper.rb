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
url = 'http://planning.cornwall.gov.uk/online-applications/search.do?action=advanced&searchType=Appeal' #link to the advanced search page on the local authority website
url_beginning = "http://planning.cornwall.gov.uk" #the first bit of the url (ending with "gov.uk")
council = "Cornwall" #specify the council name
startDate = "01/01/2017" #specify decision date start
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

pp links_array
