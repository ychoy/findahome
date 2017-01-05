require 'mechanize'

class SocialCrawler
  attr_reader :base_url

  def initialize
    @base_url = 'http://www.socialserve.com'
    @search_url = "#{@base_url}/tenant/CA/Search.html?type=rental&region_id=32090"
    @agent = Mechanize.new
  end

  def fetch_search_results_page
    search_page = @agent.get(search_url)
    search_form = search_page.forms[0]

    maximized_search_form = mark_search_form_with_max_values(search_form)

    search_results_page = agent.submit(
      maximized_search_form, maximized_search_form.buttons.first
    )

    search_results_page
  end

  def collect_house_links(search_results_page)
    house_links = []
    search_results_page.links.each do |link|
      house_links << link.uri.to_s if link.uri.to_s =~ %r{\/ViewUnit\/}
    end

    house_links.uniq!
  end

  def collect_home_metadata(home_url)
  end

  private

  def mark_search_form_with_max_values(search_form)
    search_form.radiobuttons_with(name: 's8')[0].check
    search_form.radiobuttons_with(name: 'rental_voucher_programs_5')[0].check
    search_form.fields_with(name: 'high_rent')[0].options[-1].select
    search_form.fields_with(name: 'showmax')[0].options[-1].select
  end
end
