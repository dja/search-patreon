class HooksController < ApplicationController

	def new_project_callback
	    if params[:projects].present?
			params[:projects].each do |e|
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

	    # The webhook doesn't require a response but let's make sure
	    # we don't send anything
	    render nothing: true
	end

	def new_user_info_callback
	    if params[:users].present?
			params[:users].each do |u|
				username = u["patreon"].match(/user.u=\w+\s*$|\w+\s*$/).to_s.downcase
				User.find_or_create_by(patreon: username) do |user|
					user.twitter  		||= u["twitter"][1..-1] if u["twitter"].present?
					user.youtube  		||= u["youtube"].match(/(channel.*)|(user.*)|\w+\s*$/).to_s if u["youtube"].present?
					user.facebook 		||= u["facebook"].match(/(pages.*)|\w+\s*$/).to_s if u["facebook"].present?
					user.patrons		||= u["patrons"] if u["patrons"].present?
					user.monthly_pledge	||= u["monthly-pledge"].gsub(/[^\d\.]/, '').to_i if u["monthly-pledge"].present?
					user.facebook_count ||= getFacebookLikes(u["facebook"].match(/(pages.*)|\w+\s*$/).to_s) if u["facebook"].present?
					user.youtube_count  ||= getYoutubeFollowerCount(u["youtube"].match(/\w+\s*$/).to_s) if u["youtube"].present?
				end
			end
	    end

	    # The webhook doesn't require a response but let's make sure
	    # we don't send anything
	    render nothing: true
	end
end
