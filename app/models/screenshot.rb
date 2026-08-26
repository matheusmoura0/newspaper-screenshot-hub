class Screenshot < ApplicationRecord
  belongs_to :newspaper
  belongs_to :capture_run
end
