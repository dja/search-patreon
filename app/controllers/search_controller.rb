class SearchController < ApplicationController

	def new

	end

	def search
		if params[:query].present? && params[:query] != "*"
		  @user = User.search(params[:query].match(/user.u=\w+\s*$|\w+\s*$/).to_s).first
		else
		  ""
		end
		@top_users = User.where("monthly_pledge IS NOT NULL").order(monthly_pledge: :desc, patrons: :asc).limit(5)
	end

	def autocomplete
		query = params[:query].match(/user.u=\w+\s*$|\w+\s*$/).to_s
		@arr = []
		User.search(query, autocomplete: true, limit: 10).each do |u|
			@arr << {patreon: u.patreon, name: u.name, youtube: u.youtube}
		end
    	render json: @arr
  	end
end
