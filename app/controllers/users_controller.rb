class UsersController < ApplicationController

	def downloadUsers
		newData = HTTParty.get('https://www.kimonolabs.com/api/5uuu1ucw?apikey='+ENV['KIMONO_API_KEY'])
		return if newData.response.code != "200" || newData.parsed_response["count"] == 0
		users = newData["results"]["users"]
		users.each do |u|
			username = u["patreon"].match(/\w+\s*$/).to_s
			User.find_or_create_by(patreon: username) do |user|
				user.twitter  	||= u["twitter"][1..-1] if u["twitter"].present?
				user.youtube  	||= u["youtube"].match(/(channel.*)|(user.*)|\w+\s*$/).to_s if u["youtube"].present?
				user.facebook 	||= u["facebook"].match(/(pages.*)|\w+\s*$/).to_s if u["facebook"].present?
			end
		end
	end

	def addNewCrawlUrlToKimono(url)
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/5uuu1ucw/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: ['http://www.patreon.com/'+url] })
	end

	def addCrawlUrlsToKimono
		urls = []
		User.all.each do |u|
			urls << 'http://www.patreon.com/'+u.patreon
		end
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/5uuu1ucw/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: urls })
	end

	def startCrawl
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/5uuu1ucw/startcrawl', body: { apikey: ENV['KIMONO_API_KEY'] })
	end
end
