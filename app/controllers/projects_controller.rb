class ProjectsController < ApplicationController

	def new

	end

	def create

	end

	def syncPatreon
		data = HTTParty.get('https://www.kimonolabs.com/api/8iz9vpyk?apikey='+ENV['KIMONO_API_KEY'])
		return if data.response.code != "200"
		data["results"]["projects"].each do |e|
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
	end

	def addNewProjectCrawlUrlToKimono(page)
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8iz9vpyk/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: ['http://www.patreon.com/discoverNext&p='+page] })
	end

	def addProjectCrawlUrlsToKimono(urls)
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8iz9vpyk/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: urls })
	end

	def startProjectsCrawl
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8iz9vpyk/startcrawl', body: { apikey: ENV['KIMONO_API_KEY'] })
	end

	def addCrawlUrlsToKimono
		urls = []
		1...300.times do |i|
			urls << 'http://www.patreon.com/discoverNext?p='+i.to_s+'&ty=&srt=2'
		end
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8l5fbuh8/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: urls })
	end

	def getPatreonIds
		data = HTTParty.get('https://www.kimonolabs.com/api/8l5fbuh8?apikey='+ENV['KIMONO_API_KEY'])
		return if data.response.code != "200"
		urls = []
		data["results"]["links"].each do |l|
			urls << l["link"]
		end
		addProjectCrawlUrlsToKimono(urls)
	end

	def startCrawl
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8l5fbuh8/startcrawl', body: { apikey: ENV['KIMONO_API_KEY'] })
	end
end
