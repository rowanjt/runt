#!/usr/bin/env ruby

require 'minitest_helper'

class SugarTest < Minitest::Test
  # include Runt::Sugar

  def setup
    @date = Runt::PDate.day(2008,7,1)
  end

  def test_method_missing_should_be_called_for_invalid_name
    assert_raises ::NoMethodError do
      Runt::Sugar.some_tuesday
    end
  end

  def test_method_missing_should_define_dimonth
    Runt::Sugar.ordinals.each do |ordinal|
      Runt::Sugar.days.each do |day|
    	  name = ordinal + '_' + day
    	  result = Runt::Sugar.send(name)
    	  expected = Runt::DIMonth.new(Runt.const(ordinal), Runt.const(day))
    	  assert_equal expected.to_s, result.to_s
    	end
    end
  end

  def test_method_missing_should_define_diweek
    assert_equal Runt::DIWeek.new(Runt::Monday), Runt::Sugar.monday
    assert_equal Runt::DIWeek.new(Runt::Tuesday), Runt::Sugar.tuesday
    assert_equal Runt::DIWeek.new(Runt::Wednesday), Runt::Sugar.wednesday
    assert_equal Runt::DIWeek.new(Runt::Thursday), Runt::Sugar.thursday
    assert_equal Runt::DIWeek.new(Runt::Friday), Runt::Sugar.friday
    assert_equal Runt::DIWeek.new(Runt::Saturday), Runt::Sugar.saturday
    assert_equal Runt::DIWeek.new(Runt::Sunday), Runt::Sugar.sunday
  end

  def test_parse_time
    assert_equal [13,2], Runt::Sugar.parse_time('1','02','pm')
    assert_equal [1,2], Runt::Sugar.parse_time('1','02','am')
  end

  def test_method_missing_should_define_re_day
    assert_equal Runt::REDay.new(8,45,14,00), Runt::Sugar.send(:daily_8_45am_to_2_00pm)
  end

  def test_method_missing_should_define_re_week
    Runt::Sugar.days.each do |st_day|
      Runt::Sugar.days.each do |end_day|
      	if Runt.const(st_day) <= Runt.const(end_day)
          expected = Runt::REWeek.new(Runt.const(st_day), Runt.const(end_day))
          actual = Runt::Sugar.send('weekly_' + st_day + '_to_' + end_day)
      	  assert_equal expected.to_s, actual.to_s
      	end
      end
    end
  end

  def test_method_missing_should_define_re_month
    assert_equal Runt::REMonth.new(3,14), Runt::Sugar.send(:monthly_3rd_to_14th)
  end

  def test_method_missing_should_define_re_year
    # Imperfect but "good enough" for now
    Runt::Sugar.months.each do |st_month|
      Runt::Sugar.months.each do |end_month|
      	st_mon_number = Runt.const(st_month)
      	end_mon_number = Runt.const(end_month)
      	next if st_mon_number > end_mon_number
      	st_day = rand(27) + 1
      	end_day = rand(27) + 1
        if st_mon_number == end_mon_number && st_day > end_day
      	  st_day, end_day = end_day, st_day
      	end

        expected = Runt::REYear.new(st_mon_number, st_day, end_mon_number, end_day)
        actual = Runt::Sugar.send("yearly_#{st_month}_#{st_day}_to_#{end_month}_#{end_day}")
        assert_equal expected.to_s, actual.to_s
      end
    end
  end

  def test_after_should_define_after_te_with_inclusive_parameter
    result = Runt::Sugar.after(@date, true)
    assert_equal Runt::AfterTE.new(@date, true).to_s, result.to_s
    assert result.instance_variable_get("@inclusive")
  end

  def test_after_should_define_after_te_without_inclusive_parameter
    result = Runt::Sugar.after(@date)
    assert_equal Runt::AfterTE.new(@date).to_s, result.to_s
    assert !result.instance_variable_get("@inclusive")
  end

  def test_before_should_define_before_te_with_inclusive_parameter
    result = Runt::Sugar.before(@date, true)
    assert_equal Runt::BeforeTE.new(@date, true).to_s, result.to_s
    assert result.instance_variable_get("@inclusive")
  end

  def test_before_should_define_before_te_without_inclusive_parameter
    result = Runt::Sugar.before(@date)
    assert_equal Runt::BeforeTE.new(@date).to_s, result.to_s
    assert !result.instance_variable_get("@inclusive")
  end
end
