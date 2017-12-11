#!/usr/bin/env ruby

require 'minitest_helper'

class SugarTest < Minitest::Test
  # include Runt::Sugar

  def setup
    @date = Runt::PDate.day(2008,7,1)
  end

  def test_before_date_exclusive
    actual = Runt::Sugar.send('before_2010-01-01')
    assert actual.include? Date.new(2009,12,30)
    refute actual.include? Date.new(2010,1,1)
  end

  def test_after_date_exclusive
    actual = Runt::Sugar.send('after_2010-01-01')
    assert actual.include? Date.new(2010,1,2)
    refute actual.include? Date.new(2010,1,1)
    refute actual.include? Date.new(2009,12,30)
  end

  def test_year
    actual = Runt::Sugar.send(:year_2010)
    assert actual.include? Time.new(2010,1,15,10,30,00)
    refute actual.include? Time.new(2011,11,29,10,30,00)
  end

  def test_yearly_for_single_month
    actual = Runt::Sugar.send(:yearly_december)
    assert actual.include? Time.new(2016,12,28,10,30,00)
    assert actual.include? Time.new(2017,12,27,00,00,00)
    refute actual.include? Time.new(2017,11,29,10,30,00)
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
      	  assert_equal expected, actual
      	end
      end

      expected = Runt::DIWeek.new(Runt.const(st_day))
      actual = Runt::Sugar.send('weekly_' + st_day)
      assert_equal expected, actual
    end
  end

  def test_method_missing_should_define_re_month
    assert_equal Runt::REMonth.new(3,14), Runt::Sugar.send(:monthly_3rd_to_14th)
    assert_equal Runt::REMonth.new(10), Runt::Sugar.send(:monthly_10th)
  end

  def test_method_missing_should_define_re_year
    # Imperfect but "good enough" for now
    Runt::Sugar.months.each do |st_month|
      st_mon_number = Runt.const(st_month)
      st_day = rand(27) + 1

      Runt::Sugar.months.each do |end_month|
      	end_mon_number = Runt.const(end_month)
      	next if st_mon_number > end_mon_number
      	end_day = rand(27) + 1
        if st_mon_number == end_mon_number && st_day > end_day
      	  st_day, end_day = end_day, st_day
      	end

        expected = Runt::REYear.new(st_mon_number, st_day, end_mon_number, end_day)
        actual = Runt::Sugar.send("yearly_#{st_month}_#{st_day}_to_#{end_month}_#{end_day}")
        assert_equal expected, actual
      end

      # no end month / day
      expected = Runt::REYear.new(st_mon_number, st_day, st_mon_number, st_day)
      actual = Runt::Sugar.send("yearly_#{st_month}_#{st_day}")
      assert_equal expected, actual
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
