class Student::GroupsController < ApplicationController
  layout "student"
  before_action :authenticate_user!
  before_action :check_group_creation_deadline, only: [:new, :create]

  def index
    @group = current_user.group
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.leader = current_user
  
    if @group.save
      # Lideri gruba otomatik olarak ekle
      GroupMembership.create(group: @group, student: current_user)
  
      # Seçilen öğrenci ID'lerini ekle
      if params[:group][:student_ids]
        student_ids = params[:group][:student_ids].reject(&:blank?) # boşlukları sil
        student_ids.each do |student_id|
          GroupMembership.create(group: @group, student_id: student_id)
        end
      end
  
      redirect_to student_groups_path, notice: "Grup başarıyla oluşturuldu."
    else
      render :new
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to student_groups_path, notice: "Grup başarıyla silindi."
  end
  

private

def check_group_creation_deadline
  deadline_str = Setting.find_by(key: 'group_creation_deadline')&.value
  deadline = Date.parse(deadline_str) rescue nil

  if deadline.present? && Date.today > deadline
    redirect_to student_groups_path, alert: "Grup oluşturma süresi dolmuştur."
  end
end


  private

  def group_params
    params.require(:group).permit(:name, student_ids: [])
  end

  
  

  
end
