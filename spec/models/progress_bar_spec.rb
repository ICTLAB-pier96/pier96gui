require 'rails_helper'

RSpec.describe ProgressBar, type: :model do
 it "initializes with the default values" do
    progress = ProgressBar.new
    expect(progress.max).to be 100.0
    expect(progress.current).to be 0.0
    expect(progress.percentage).to be 0.0
  end

 it "can set a custom max correctly" do
    progress = ProgressBar.new
    progress.set_max 1000
    expect(progress.max).to be 1000.0
    progress.set_max -100
    expect(progress.max).to be 1.0
    progress.destroy
  end
 it "makes sure the progress value can't go higher than the max" do
    progress = ProgressBar.new
    progress.increment 200
    expect(progress.current).to be progress.max
    progress.destroy
  end

  it "makes calculates the correct percentage after an update" do
    progress = ProgressBar.new
    progress.increment 25
    expect(progress.percentage).to be 25.0
    progress.increment 25
    expect(progress.percentage).to be 50.0
    progress.destroy
  end
end
