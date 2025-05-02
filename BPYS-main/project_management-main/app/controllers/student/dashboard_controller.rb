module Student
  class DashboardController < ApplicationController 
    layout "student"
    before_action :only_students
    
    def index
      @project_selection_deadline = Setting.find_by(key: 'project_selection_deadline')&.value_as_date
    end
  end
end
