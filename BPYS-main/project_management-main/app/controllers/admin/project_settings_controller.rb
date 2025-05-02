module Admin
    class ProjectSettingsController < ApplicationController
      before_action :authenticate_user!
      before_action :require_admin
  
      def edit
        @deadline = Setting.find_or_initialize_by(key: 'project_selection_deadline')
       # Son proje seçim tarihinden önce proje seçimi yapmış olan gruplar
        @groups_with_projects = groups_with_projects(@deadline.value_as_date)
      # Proje seçimi yapmamış gruplar
        @groups_without_project = groups_without_project(@deadline.value_as_date)
      end
  
      def update
        @deadline = Setting.find_or_initialize_by(key: 'project_selection_deadline')
        if @deadline.update(value: params[:setting][:value])
          redirect_to edit_admin_project_setting_path, notice: "Proje seçim son tarihi güncellendi."
        else
          render :edit
        end
      end
  
      def assign_random_projects
        deadline = Setting.find_by(key: 'project_selection_deadline')&.value_as_date
        if deadline.nil?
          return redirect_to edit_admin_project_setting_path, alert: "Proje seçim tarihi belirlenmemiş."
        end
  
        groups_without_project = groups_without_project(deadline)
        if groups_without_project.empty?
          return redirect_to edit_admin_project_setting_path, alert: "Proje seçimi yapmamış grup bulunmamaktadır."
        end
  
        available_projects = Project.where.not(id: groups_without_project.map(&:project_id))
  
        # Gruplara rastgele projeleri ata
        groups_without_project.each do |group|
          project = available_projects.sample
          group.update(project: project) if project
          available_projects -= [project] # Seçilen projeyi çıkar
        end
  
        redirect_to edit_admin_project_setting_path, notice: "Rastgele projeler başarıyla atandı."
      end
  
      private

      def groups_with_projects(deadline)
        Group.joins(:project)
             .where('groups.created_at <= ?', deadline.end_of_day)  # Tarihe kadar oluşturulan gruplar
             .where.not(projects: { id: nil })  # Proje seçmiş gruplar
      end
  
      def groups_without_project(deadline)
        Group.left_outer_joins(:project)
             .where(projects: { id: nil })  # Projesi olmayan grupları filtreler
             .where('groups.created_at <= ?', deadline.end_of_day) # Tarihe kadar oluşturulan gruplar
      end
  
      def require_admin
        redirect_to root_path unless current_user.admin?
      end
    end
  end
  