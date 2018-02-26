# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  name        :string
#  external_id :string
#  channel     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class User < ApplicationRecord
end
