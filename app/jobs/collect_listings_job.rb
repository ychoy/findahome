require 'mechanize'

class CollectListingsJob < ApplicationJob
  queue_as :default

  # Time to collect some motherfucking listings.
  #
  #
  def perform(*args)
    agent = Mechanize.new

    page = agent.get(url)

    form = page.forms[0]

    form.radiobuttons_with(name: 's8')[0].check
    form.radiobuttons_with(name: 'rental_voucher_programs_5')[0].check
    form.fields_with(name: 'high_rent')[0].options[-1].select
    form.fields_with(name: 'showmax')[0].options[-1].select

    new_page = agent.submit(form, form.buttons.first)
    pp new_page
  end
end
