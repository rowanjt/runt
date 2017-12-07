#!/usr/bin/env ruby

require 'minitest_helper'

class RuntModuleTest < Minitest::Test
  using CoreExtensions::DatePrecision
  using CoreExtensions::TimePrecision

  def test_last
    assert Runt::Last == -1
  end

  def test_last_of
    assert Runt::Last_of == -1
  end

  def test_second_to_last
    assert Runt::Second_to_last == -2
  end

  def test_const
    assert_equal Runt::Monday, Runt.const('monday')
  end

  def test_day_name
    i=0
    Date::DAYNAMES.each do |n|
      assert_equal Date::DAYNAMES[i], Runt.day_name(i)
      i=i+1
    end
  end

  def test_month_name
    Date::MONTHNAMES.each_with_index do |name, index|
      next if name.nil? # first element is nil
      assert_equal Date::MONTHNAMES[index], Runt.month_name(index)
    end
  end

  def test_strftime
    d=DateTime.new(2006,2,26,14,45)
    assert_equal '02:45PM', Runt.format_time(d)
  end

  def test_time_class_dprecision
    time=Time.parse('Monday 06 November 2006 07:38')
    assert_equal(Runt::DPrecision::DEFAULT,time.date_precision)
  end

  def test_date_class_dprecision
    date=Date.today
    assert_equal(Runt::DPrecision::DAY,date.date_precision)
  end

  def test_datetime_class_dprecision
    date=DateTime.civil
    assert_equal(Runt::DPrecision::SEC,date.date_precision)
  end

  def test_time_plus
    time=Time.local(2006, 12, 9, 5, 56, 12)
    # Default precision is minute
    assert_equal(Runt::PDate.min(2006,12,9,5,56),Runt::DPrecision.to_p(time))
    refute_equal(Time.parse("Sat Dec 09 05:56:00 -0500 2006"),time)
  end

end
