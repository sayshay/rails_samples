module NewStageHelpers
  def create_stage_with_name(name)
    within('#new_stage') do
      fill_in 'Name', :with => name
    end
    click_button 'Create Stage'
  end

  def fill_in_stage_form_with_name_and_festival(stage_form_id, name, festival_name)
    within(stage_form_id) do
      fill_in 'Name', :with => name
      select festival_name, :from => 'stage_party_id'
    end
  end

  #def create_new_stage(artist, festival)
  #  within('#new_stage') do
  #    fill_in 'Name', :with => @stage.name
  #    select festival.name, :from => 'stage_party_id'
  #    select artist.title, :from => 'stage_artist_id'
  #  end
  #  click_button 'Create Stage'
  #end
  #
  #def create_new_stage_with_selected_festival_and_artist(selected_festival, selected_artist)
  #  visit "/stages/new?artist=#{selected_artist.id}&festival=#{selected_festival.id}"
  #
  #  within('#new_stage') do
  #    fill_in 'Name', :with => @stage.name
  #  end
  #  click_button 'Create Stage'
  #end
end

RSpec.configure do |config|
  config.include NewStageHelpers
end