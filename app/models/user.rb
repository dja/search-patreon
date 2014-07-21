class User < ActiveRecord::Base
	searchkick autocomplete: ['patreon']
	has_many :projects
end
