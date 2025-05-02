class Setting < ApplicationRecord
    def value_as_date
      Date.parse(value) rescue nil
    end
  
  end