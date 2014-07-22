class HooksController < ApplicationController

	def new_project_callback

	end

	def new_user_info_callback
	    if params[:username].present?
	      	return "hello"
	    end

	    # The webhook doesn't require a response but let's make sure
	    # we don't send anything
	    render nothing: true
	  end
	end
end
