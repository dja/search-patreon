class UsersController < ApplicationController

	# def syncUsers
	# 	User.where(twitter: nil).each do |u|
	# 		puts u.patreon
	# 		newData = []
	# 		newData = HTTParty.get('https://www.kimonolabs.com/api/5uuu1ucw?apikey='+ENV['KIMONO_API_KEY']+'&kimpath1='+u.patreon.downcase)
	# 		next if newData.response.code != "200" || newData["results"]["user"].count == 0
	# 		user = newData["results"]["user"][0]
	# 		u.twitter  ||= user["twitter"][1..-1] if user["twitter"].present?
	# 		u.youtube  ||= user["youtube"].match(/(channel.*)|(user.*)|\w+\s*$/).to_s if user["youtube"].present?
	# 		u.facebook ||= user["facebook"].match(/(pages.*)|\w+\s*$/).to_s if user["facebook"].present?
	# 		u.save!
	# 	end
	# end

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
