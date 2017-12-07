#!/usr/bin/env ruby

require 'minitest_helper'

class SugarTest < Minitest::Test
  include Runt::Sugar

  def setup
    @date = Runt::PDate.day(2008,7,1)
  end

  def test_method_missing_should_be_called_for_invalid_name
    assert_raises ::NoMethodError do
      self.some_tuesday
    end
  end

  def test_method_missing_should_define_dimonth
    self.ordinals.each do |ordinal|
      self.days.each do |day|
    	  name = ordinal + '_' + day
    	  result = self.send(name)
    	  expected = Runt::DIMonth.new(Runt.const(ordinal), Runt.const(day))
    	  assert_expression expected, result
    	end
    end
  end

  def test_method_missing_should_define_diweek
    assert_expression(Runt::DIWeek.new(Runt::Monday), self.monday)
    assert_expression(Runt::DIWeek.new(Runt::Tuesday), self.tuesday)
    assert_expression(Runt::DIWeek.new(Runt::Wednesday), self.wednesday)
    assert_expression(Runt::DIWeek.new(Runt::Thursday), self.thursday)
    assert_expression(Runt::DIWeek.new(Runt::Friday), self.friday)
    assert_expression(Runt::DIWeek.new(Runt::Saturday), self.saturday)
    assert_expression(Runt::DIWeek.new(Runt::Sunday), self.sunday)
  end

  def test_parse_time
    assert_equal [13,2], parse_time('1','02','pm')
    assert_equal [1,2], parse_time('1','02','am')
  end

  def test_method_missing_should_define_re_day
    assert_expression(Runt::REDay.new(8,45,14,00), daily_8_45am_to_2_00pm)
  end

  def test_method_missing_should_define_re_week
    self.days.each do |st_day|
      self.days.each do |end_day|
      	if Runt.const(st_day) <= Runt.const(end_day)
      	  assert_expression Runt::REWeek.new(Runt.const(st_day), \
    	      Runt.const(end_day)), self.send('weekly_' + st_day + '_to_' + end_day)
      	end
      end
    end
  end

  def test_method_missing_should_define_re_month
    assert_expression(Runt::REMonth.new(3,14), monthly_3rd_to_14th)
  end

  def test_method_missing_should_define_re_year
    # Imperfect but "good enough" for now
    self.months.each do |st_month|
      self.months.each do |end_month|
      	st_mon_number = Runt.const(st_month)
      	end_mon_number = Runt.const(end_month)
      	next if st_mon_number > end_mon_number
      	st_day = rand(27) + 1
      	end_day = rand(27) + 1
        if st_mon_number == end_mon_number && st_day > end_day
      	  st_day, end_day = end_day, st_day
      	end
      	#puts "Checking #{st_month} #{st_day} - #{end_month} #{end_day}"
      	assert_expression Runt::REYear.new(st_mon_number, st_day, end_mon_number, end_day), \
      	  self.send('yearly_' + st_month + '_' + st_day.to_s + '_to_' + end_month + '_' + end_day.to_s)
      end
    end
  end

  def test_after_should_define_after_te_with_inclusive_parameter
    result = self.after(@date, true)
    assert_expression Runt::AfterTE.new(@date, true), result
    assert result.instance_variable_get("@inclusive")
  end

  def test_after_should_define_after_te_without_inclusive_parameter
    result = self.after(@date)
    assert_expression Runt::AfterTE.new(@date), result
    assert !result.instance_variable_get("@inclusive")
  end

  def test_before_should_define_before_te_with_inclusive_parameter
    result = self.before(@date, true)
    assert_expression Runt::BeforeTE.new(@date, true), result
    assert result.instance_variable_get("@inclusive")
  end

  def test_before_should_define_before_te_without_inclusive_parameter
    result = self.before(@date)
    assert_expression Runt::BeforeTE.new(@date), result
    assert !result.instance_variable_get("@inclusive")
  end

  private
  def assert_expression(expected, actual)
    assert_equal expected.to_s, actual.to_s
  end
end
