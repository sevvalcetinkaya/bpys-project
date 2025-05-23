class ProjectApplication < ApplicationRecord
  
  belongs_to :user 
  belongs_to :project

  enum status: { pending: 0, accepted: 1, rejected: 2 }
end
