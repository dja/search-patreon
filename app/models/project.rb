class Project < ActiveRecord::Base
	searchkick autocomplete: ["name"], operator: "or"

	belongs_to :user
end
