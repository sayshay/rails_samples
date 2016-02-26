require 'spec_helper'

describe Categorization do
  subject(:categorization) { build :categorization }

  [:categorizable_id, :categorizable_type].each do |property|
    it { should respond_to property }
  end

  it { should validate_presence_of :category_id }
  it { should validate_presence_of :categorizable_id }

  it { should belong_to :category }
  it { should belong_to :categorizable }

end
