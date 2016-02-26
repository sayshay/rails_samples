module PerformanceHelpers
  def fill_in_performance_form_with_artist_and_festival(performance_form_id, artist, festival)
    within(performance_form_id) do
      select artist.name, :from => 'performance_artist_id'
      select festival.name, :from => 'performance_party_id'
    end
  end

  def fill_in_performance_form_with_artist_and_stage(performance_form_id, artist, stage)
    within(performance_form_id) do
      select artist.name, :from => 'performance_artist_id'
      select stage.name, :from => 'performance_stage_id'
    end
  end

  def create_new_performance(artist, stage)
    fill_in_performance_form_with_artist_and_stage('#new_performance', artist, stage)
    click_button 'Create Performance'
  end
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
  config.include PerformanceHelpers
end