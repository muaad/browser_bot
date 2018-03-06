# == Schema Information
#
# Table name: optimized_sites
#
#  id             :integer          not null, primary key
#  name           :string
#  root_url       :string
#  action         :string
#  enabled        :boolean          default(FALSE)
#  implementation :string           default("Internal")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class OptimizedSiteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
