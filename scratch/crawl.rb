require 'mechanize'

base_url = 'http://www.socialserve.com'
starting_url = "#{base_url}/tenant/CA/Search.html?type=rental&region_id=32090"

agent = Mechanize.new

search_page = agent.get(starting_url)

search_form = search_page.forms[0]

search_form.radiobuttons_with(name: 's8')[0].check
search_form.radiobuttons_with(name: 'rental_voucher_programs_5')[0].check
search_form.fields_with(name: 'high_rent')[0].options[-1].select
search_form.fields_with(name: 'showmax')[0].options[-1].select

search_results_page = agent.submit(search_form, search_form.buttons.first)

def collect_links(search_results_page)
  house_links = []
  search_results_page.links.each do |link|
    house_links << link.uri.to_s if link.uri.to_s =~ %r{\/ViewUnit\/}
  end

  house_links.uniq!
end

house_links = collect_links search_results_page

next_button = search_results_page.links_with(text: 'next')[0]
next_links = []
if house_links.count < 101
  next_page = next_button.click
  next_links = collect_links next_page
end

first_house = agent.get("#{base_url}#{next_links[0]}")

table_cells = first_house.search('td')

def parse_one_to_one(table_cells)
  datums = [ "Property Type", "Bedrooms", "Bathrooms", "Pets" ]
  complete_data = {}

  table_cells.each_with_index do |cell, index|
    cell_first_content = cell.children[0].to_s.strip.chop

    if datums.include?(cell_first_content)
      pp table_cells[index + 1].children

      complete_data.merge!({
        cell_first_content.to_sym => table_cells[index + 1].children[1].children[0].to_s
      })
    end
  end
end

complete_data = parse_one_to_one(table_cells)

def parse_question_marks(table_cells)

  table_cells.each_with_index do |cell, index|
    if cell.children[2].to_s.match("Pets\:")
      pp table_cells[index + 1].children[1].children[0].to_s.strip
    end
  end

end

# parse_pets(table_cells)
