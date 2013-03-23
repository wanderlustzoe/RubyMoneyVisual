require_relative '../lib/finance/rates.rb'
include Finance

require 'flt'
require 'flt/d'
require 'minitest/unit'
require 'shoulda'

class TestRates < Test::Unit::TestCase
  context "an interest rate" do
    context "can compound with different periods" do
      should "compound monthly by default" do
        rate = Rate.new(0.15, :nominal)
        assert_equal D('0.16075'), rate.effective.round(5)
      end

      should "compound annually" do
        rate = Rate.new(0.15, :nominal, :compounds => :annually)
        assert_equal D('0.15'), rate.effective
      end

      should "compound continuously" do
        rate = Rate.new(0.15, :nominal, :compounds => :continuously)
        assert_equal D('0.16183'), rate.effective.round(5)
      end

      should "compound daily" do
        rate = Rate.new(0.15, :nominal, :compounds => :daily)
        assert_equal D('0.16180'), rate.effective.round(5)
      end

      should "compound quarterly" do
        rate = Rate.new(0.15, :nominal, :compounds => :quarterly)
        assert_equal D('0.15865'), rate.effective.round(5)
      end

      should "compound semiannually" do
        rate = Rate.new(0.15, :nominal, :compounds => :semiannually)
        assert_equal D('0.15563'), rate.effective.round(5)
      end

      should "accept a numerical value as the compounding frequency per year" do
        rate = Rate.new(0.15, :nominal, :compounds => 7)
        assert_equal D('0.15999'), rate.effective.round(5)
      end

      should "raise an exception if an unknown string is given" do
        assert_raises(ArgumentError){ Rate.new(0.15, :nominal, :compounds => :quickly) }
      end
    end

    should "accept a duration if given" do
      rate = Rate.new(0.0375, :effective, :duration => 360)
      assert_equal 360, rate.duration
    end

    should "be comparable to other interest rates" do
      r1 = Rate.new(0.15, :nominal)
      r2 = Rate.new(0.16, :nominal)
      assert_equal( 1, r2 <=> r1)
      assert_equal(-1, r1 <=> r2)
    end
    
    should "convert to a monthly value" do
      rate = Rate.new(0.0375, :effective)
      assert_equal D('0.003125'), rate.monthly
    end

    should "convert effective interest rates to nominal" do
      assert_equal D('0.03687'), Rate.to_nominal(D('0.0375'), 12).round(5)
      assert_equal D('0.03681'), Rate.to_nominal(D('0.0375'), Flt::DecNum.infinity).round(5)
    end

    should "raise an exception if an unknown value is given for :type" do
      assert_raises(ArgumentError){ Rate.new(0.0375, :foo) }
    end
  end
end
