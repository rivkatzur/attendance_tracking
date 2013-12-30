class Holiday < ActiveRecord::Base
  unloadable

  validates_uniqueness_of :date
  validates_presence_of :description
end
