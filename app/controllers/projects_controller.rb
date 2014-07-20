class ProjectsController < ApplicationController

	def new

	end

	def create

	end

	def syncPatreon
		1...100.times do |i|
			newData = []
			newData = HTTParty.get('https://www.kimonolabs.com/api/alkpwwa0?apikey=s04YPYzlvOCmvEbB03dRSBCWBtUQoY02&p='+i.to_s)
			next if newData.response.code != "200"
			newData["results"]["projects"].each do |e|
				next if e["name"].nil? || e["name"]["href"].nil?
				Project.create(site: "Patreon", name: e["name"]["text"], url: e["name"]["href"].gsub!(/\D/, ""))
				User.create(name: e["creator"]["text"], patreon: e["creator"]["href"].split(e["creator"]["href"].match(/http:..www.patreon.com./)))
			end
		end
	end
end
