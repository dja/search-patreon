class UsersController < ApplicationController

	def downloadUsers
		newData = HTTParty.get('https://www.kimonolabs.com/api/5uuu1ucw?apikey='+ENV['KIMONO_API_KEY'])
		return if newData.response.code != "200" || newData.parsed_response["count"] == 0
		users = newData["results"]["users"]
		users.each do |u|
			username = u["patreon"].match(/user.u=\w+\s*$|\w+\s*$/).to_s.downcase
			User.find_or_create_by(patreon: username) do |user|
				user.twitter  		||= u["twitter"][1..-1] if u["twitter"].present?
				user.youtube  		||= u["youtube"].match(/(channel.*)|(user.*)|\w+\s*$/).to_s if u["youtube"].present?
				user.facebook 		||= u["facebook"].match(/(pages.*)|\w+\s*$/).to_s if u["facebook"].present?
				user.patrons		||= u["patrons"] if u["patrons"].present?
				user.monthly_pledge	||= u["monthly-pledge"].gsub(/[^\d\.]/, '').to_i if u["monthly-pledge"].present?
				user.facebook_count ||= getFacebookLikes(u["facebook"].match(/(pages.*)|\w+\s*$/).to_s) if u["facebook"].present?
				user.youtube_count ||= getYoutubeFollowerCount(u["youtube"].match(/\w+\s*$/).to_s) if u["youtube"].present?
			end
		end
	end

	def getFacebookLikes(username)
		data = HTTParty.get("http://graph.facebook.com/"+username)
		data = JSON.parse(data)
		return data['likes']
	end

	def getYoutubeFollowerCount(username)
		data = HTTParty.get("https://www.googleapis.com/youtube/v3/channels?part=id%2C+statistics&forUsername="+username+"&key="+ENV["YOUTUBE_API_KEY"])
		return nil if data.parsed_response["items"].count == 0
		count = data.parsed_response["items"].first["statistics"]["subscriberCount"]
		return count
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
