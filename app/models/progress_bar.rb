# @author = Patrick
# Simple ProgressBar class, to keep track of the progress
class ProgressBar < ActiveRecord::Base

    # constants
    DEFAULT_MAX = 100.0
    DEFAULT_ZERO = 0.0

    # callbacks
    after_initialize :after_init
    before_save :percent 

    # The method will be called after the constructor, it sets default values of the attributes if they are not nil
    def after_init
      self[:max]  ||= DEFAULT_MAX   #will set the default value only if it's nil
      self[:current] ||= DEFAULT_ZERO
      self[:percentage] ||= DEFAULT_ZERO
    end

    # The set_max function sets the new maximum value of the progress bar
    # This value should be greater than 0
    #
    # * *Arguments*    :
    #   - max ->  value should be greater 0, will be parsed to float
    def set_max(max)
      self[:max] = (max > 0 ? max : 1)
    end

    # The increment function adds to the current progress value
    # The current progress, can't go higher than the maximum
    #
    # * *Arguments*    :
    #   - amount ->  value which will be added to the current progress
    def increment(amount = 1)
       self[:start_time] ||= Time.now
       self[:current] = (self[:current] + amount < self[:max] ? self[:current] + amount : self[:max])
       self.save
       self[:previous_time] ||= Time.now
    end

    # The time_to_finish method calculates the secondes needed to finish
    # based on the average time between increments
    def time_to_finish
      past_time = Time.now - self[:start_time]
      seconds_to_go = past_time * self[:max] / self[:current] - past_time
      puts "time to go: #{seconds_to_go.round}s"
    end

    # The time_to_finish method calculates the secondes needed to finish
    # based on the average time between increments
    def inspect
      "#<ProgressBar:#{self[:current]}/#{self[:max]}>"
    end

    private

    # The percent function calculates the percentage
    # This method is called before every update, so it will be up to date
    def percent
       self[:percentage] = (self[:current] <= self[:max] ? self[:current]/self[:max]*100 : self[:max])
    end
end
