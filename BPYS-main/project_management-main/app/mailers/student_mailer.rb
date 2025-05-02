class StudentMailer < ApplicationMailer
    default from: 'admin@projeniz.com'
  
    def group_reminder_email(student)
      @student = student
      mail(to: @student.email, subject: "Grup Oluşturmayı Unutma!")
    end
  end
  