class UsersController < ApplicationController

	def syncUsers
		newData = HTTParty.get('https://www.kimonolabs.com/api/5uuu1ucw?apikey='+ENV['KIMONO_API_KEY'])
		return if newData.response.code != "200" || newData.parsed_response["count"] == 0
		users = newData["results"]["users"]
		users.each do |u|
			username = u["patreon"].match(/user.u=\w+\s*$|\w+\s*$/).to_s.downcase
			User.find_or_create_by(patreon: username) do |user|
				user.twitter  		||= u["twitter"].match(/\w+\s*$/).to_s if u["twitter"].present?
				user.youtube  		||= u["youtube"].match(/(channel.*)|(user.*)|\w+\s*$/).to_s if u["youtube"].present?
				user.facebook 		||= u["facebook"].match(/(pages.*)|\w+\s*$/).to_s if u["facebook"].present?
				user.patrons		||= u["patrons"] if u["patrons"].present?
				user.monthly_pledge	||= u["monthly-pledge"].gsub(/[^\d\.]/, '').to_i if u["monthly-pledge"].present?
				user.facebook_count ||= getFacebookLikes(u["facebook"].match(/(pages.*)|\w+\s*$/).to_s) if u["facebook"].present?
				user.youtube_count	||= getYoutubeFollowerCount(u["youtube"].match(/(channel.*)|(user.*)|\w+\s*$/).to_s) if u["youtube"].present?
				user.twitter_count	||= getTwitterFollowerCount(u["twitter"].match(/\w+\s*$/).to_s) if u["twitter"].present?
			end
		end
		User.all.each do |user|
			user.facebook_count = getFacebookLikes(user.facebook.match(/(pages.*)|\w+\s*$/).to_s) if user.facebook.present?
			user.youtube_count	= getYoutubeFollowerCount(user.youtube.match(/(channel.*)|(user.*)|\w+\s*$/).to_s) if user.youtube.present?
			user.twitter_count	= getTwitterFollowerCount(user.twitter.match(/\w+\s*$/).to_s) if user.twitter.present?
			user.save!
		end
		redirect_to root_url
	end

	def getFacebookLikes(username)
		data = HTTParty.get("http://graph.facebook.com/"+username)
		data = JSON.parse(data)
		return data['likes']
	end

	def getYoutubeFollowerCount(username)
		data = HTTParty.get("https://www.googleapis.com/youtube/v3/channels?part=id%2C+statistics&forUsername="+username+"&key="+ENV["YOUTUBE_API_KEY"])
		return if data.parsed_response["items"].count == 0
		return data.parsed_response["items"].first["statistics"]["subscriberCount"]
	end
	
	def getTwitterFollowerCount(username)
		return $twitter.user(username).followers_count

		rescue Exception => err
		   logger.error("Twitter error: #{err.message}")
		   return nil
	end

	def addNewCrawlUrlToKimono(url)
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/5uuu1ucw/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: ['http://www.patreon.com/'+url] })
	end

	def addUsersCrawlUrlsToKimono
		urls = []
		User.all.each do |u|
			urls << 'http://www.patreon.com/'+u.patreon
		end
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/5uuu1ucw/update', body: { apikey: ENV['KIMONO_API_KEY'], urls: urls })
		startCrawl if response.response.code == "200"
		flash[:alert] = "This can take some time to update online. Check back in a few hours and choose 'Get All Creators'"
		redirect_to root_url
	end

	def startCrawl
		response = HTTParty.post('https://www.kimonolabs.com/kimonoapis/5uuu1ucw/startcrawl', body: { apikey: ENV['KIMONO_API_KEY'] })
	end
end
