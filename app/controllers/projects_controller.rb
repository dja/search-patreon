class ProjectsController < ApplicationController

	def new

	end

	def create

	end

	def syncPatreon
		data = HTTParty.get('https://www.kimonolabs.com/api/8iz9vpyk?apikey='+ENV['KIMONO_API_KEY'])
		return if data.response.code != "200"
		data["results"]["projects"].each do |e|
			next if e["name"].nil? || e["link"].nil?
			username = e["creator"]["href"].match(/user.u=\w+\s*$|\w+\s*$/).to_s.downcase
			u = User.find_or_create_by(patreon: username) do |user|
				user.name = e["creator"]["text"]
			end
			# raise e.inspect
			projectid = e["link"].match(/\w+\s*$/).to_s
			Project.find_or_create_by(url: projectid) do |project|
				project.site 		  = "Patreon"
				project.name 		  = e["name"]
				project.created_date  = e["publish-date"]
				project.patrons 	||= e["patrons"]
				project.user 	 	  = u
			end
		end
		redirect_to root_url
	end

	def addNewProjectCrawlUrlToKimono(page)
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8iz9vpyk/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: ['http://www.patreon.com/discoverNext&p='+page] })
	end

	# Step 1
	def addCrawlUrlsToKimono
		urls = []
		1...300.times do |i|
			urls << 'http://www.patreon.com/discoverNext?p='+i.to_s+'&ty=&srt=2'
		end
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8l5fbuh8/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: urls })
		startCrawl if response.response.code == "200"
		redirect_to root_url
	end

	# Part of Step 1
	def startCrawl
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8l5fbuh8/startcrawl', body: { apikey: ENV['KIMONO_API_KEY'] })
	end

	# Step 2
	def getPatreonIds
		data = HTTParty.get('https://www.kimonolabs.com/api/8l5fbuh8?apikey='+ENV['KIMONO_API_KEY'])
		return if data.response.code != "200"
		urls = []
		data["results"]["links"].each do |l|
			urls << l["link"]
		end
		addProjectCrawlUrlsToKimono(urls)
		flash[:alert] = "This can take some time to update online. Check back in a few hours and choose 'Get All Projects'"
		redirect_to root_url
	end

	# Part of Step 2
	def addProjectCrawlUrlsToKimono(urls)
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8iz9vpyk/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: urls })
		startProjectsCrawl if response.response.code == "200"
	end

	# Part of Step 2
	def startProjectsCrawl
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/8iz9vpyk/startcrawl', body: { apikey: ENV['KIMONO_API_KEY'] })
	end
end
