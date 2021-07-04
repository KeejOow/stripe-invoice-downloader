require 'stripe'
require "open-uri"
require "fileutils"

Stripe.api_key = 'TODO'

def list_invoices
  all_invoices = []

  while true do
	invoices = Stripe::Invoice.list({
	  starting_after: all_invoices[-1],
      limit: 100
	})
	all_invoices.concat(invoices["data"])

	break unless invoices["has_more"]
  end
  
  all_invoices
end

def download(url, path)
  URI(url).open { |remote| File.open(path, 'w') { |f| f.write(remote.read) } }
end

puts "Fetching all invoices"
list_invoices()
.each do |invoice|
  puts "Downloading #{invoice["number"]}"
  begin
  download(invoice["invoice_pdf"], "files/#{invoice["number"]}.pdf")
  rescue e
    puts e
  end
end
