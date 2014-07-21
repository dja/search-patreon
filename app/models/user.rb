class User < ActiveRecord::Base
	searchkick
	has_many :projects
end
