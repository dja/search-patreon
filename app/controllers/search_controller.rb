class SearchController < ApplicationController

	def new

	end

	def search
		if params[:query].present?
		  @users = User.search(params[:query], page: params[:page])
		else
		  @users = ""
		end
	end

	def autocomplete
    	render json: User.search(params[:query], autocomplete: true, limit: 10).map(&:patreon)
  	end
end
