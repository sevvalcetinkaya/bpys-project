class Admin::AllowedStudentsController < ApplicationController
  layout 'admin'
  def new
      @allowed_student = AllowedStudent.new
      @allowed_students = AllowedStudent.all
    end
    

  def import_csv
      require 'csv'
      file = params[:file]
      unless file
        redirect_to new_admin_allowed_student_path, alert: "Lütfen bir CSV dosyası seçin." and return
      end
    
      errors = []
      CSV.foreach(file.path, headers: true).with_index(2) do |row, i|
        email = row["email"]&.strip&.downcase
        name = row["name"]&.strip
        surname = row["surname"]&.strip
        student_number = row["student_number"]&.strip
    
        # Hatalı veri kontrolü
        if email.blank? || name.blank? || surname.blank? || student_number.blank?
          errors << "Satır #{i}: Eksik bilgi. Email, isim, soyisim ve öğrenci numarası zorunludur."
          next
        end
    
        AllowedStudent.find_or_create_by(email: email) do |student|
          student.name = name
          student.surname = surname
          student.student_number = student_number
        end
      end
    
      if errors.any?
        flash[:alert] = "CSV yüklemesi tamamlandı, ancak bazı satırlar atlandı:\n#{errors.join("\n")}"
      else
        flash[:notice] = "CSV başarıyla yüklendi."
      end
      redirect_to new_admin_allowed_student_path
  end
  def destroy
    student = AllowedStudent.find(params[:id])
    student.destroy
    redirect_to new_admin_allowed_student_path, notice: "Öğrenci silindi."
  end
    
end
