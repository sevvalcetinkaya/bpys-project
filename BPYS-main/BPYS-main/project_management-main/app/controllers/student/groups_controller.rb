class Student::GroupsController < ApplicationController
  layout "student"
  before_action :authenticate_user!
 

  def index
    @group = current_user.group
  end

  def new
    @group = Group.new
  end

  def create
    quota = SystemSetting.find_by(key: "group_quota")&.value.to_i
    student_ids = params[:group][:student_ids].reject(&:blank?).map(&:to_i)
  
    # Grup liderini de dahil et
    full_group_size = student_ids.size + 1
  
    if quota.positive? && full_group_size > quota
      flash[:alert] = "Grup kotası aşılamaz. Maksimum #{quota} kişi olabilir."
      redirect_to new_student_group_path and return
    end
  
    # Aynı öğrencinin başka bir grupta olup olmadığını kontrol et
    already_grouped = student_ids.any? do |id|
      User.find(id).group.present?
    end
  
    if already_grouped
      flash[:alert] = "Seçilen öğrencilerden biri zaten bir gruba kayıtlı."
      redirect_to new_student_group_path and return
    end
    @group = Group.new(group_params)
    @group.leader = current_user
  
    # Grup ismini otomatik olarak oluştur
    @group.name = "Grup #{SecureRandom.hex(3).upcase}"  # Örn: Grup A1B2C3
  
    if @group.save
      # Lideri gruba otomatik olarak ekle
      GroupMembership.create(group: @group, student: current_user)
  
      # Seçilen öğrenci ID'lerini ekle
      if params[:group][:student_ids]
        student_ids = params[:group][:student_ids].reject(&:blank?)
        student_ids.each do |student_id|
          GroupMembership.create(group: @group, student_id: student_id)
        end
      end
  
      redirect_to student_groups_path, notice: "Grup başarıyla oluşturuldu."
    else
      render :new
    end
    end
  private

  def group_params
    params.require(:group).permit(:name, student_ids: [])
  end

  
  

  
end
