class ProjectsController < ApplicationController

	def new

	end

	def create

	end

	def syncPatreon
		1..2.times do |i|
			newData = []
			newData = HTTParty.get('https://www.kimonolabs.com/api/alkpwwa0?apikey=s04YPYzlvOCmvEbB03dRSBCWBtUQoY02&p='+i.to_s)
			next if newData.response.code != "200"
			newData["results"]["projects"].each do |e|
				next if e["name"].nil? || e["name"]["href"].nil?
				username = e["creator"]["href"].split(e["creator"]["href"].match(/http:..www.patreon.com./).to_s)[1]
				u = User.find_or_create_by(patreon: username) do |user|
					user.name = e["creator"]["text"]
				end
				Project.find_or_create_by(url: e["name"]["href"].gsub!(/\D/, "")) do |project|
					project.site = "Patreon"
					project.name = e["name"]["text"]
					project.created_date = e["date"]
					project.patrons = e["patrons"]
					project.user = u
				end
			end
		rescue if newData["results"]["projects"].count == 0
		end
	end
end
