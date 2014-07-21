class UsersController < ApplicationController

	def syncUsers
		User.where(twitter: nil).each do |u|
			puts u.patreon
			newData = []
			newData = HTTParty.get('https://www.kimonolabs.com/api/d8ga9is8?apikey='+ENV['KIMONO_API_KEY']+'&kimpath1='+u.patreon)
			next if newData.response.code != "200" || newData["results"]["user"].count == 0
			user = newData["results"]["user"][0]
			u.twitter  ||= user["twitter"][1..-1] if user["twitter"].present?
			u.youtube  ||= user["youtube"].match(/(channel.*)|(user.*)|\w+\s*$/).to_s if user["youtube"].present?
			u.facebook ||= user["facebook"].match(/(pages.*)|\w+\s*$/).to_s if user["facebook"].present?
			u.save!
		end
	end
end
