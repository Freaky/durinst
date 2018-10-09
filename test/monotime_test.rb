require 'test_helper'

class MonotimeTest < Minitest::Test
  include Monotime

  def test_that_it_has_a_version_number
    refute_nil ::Monotime::VERSION
  end

  def test_instant_monotonic
    10.times do
      assert Instant.now <= Instant.now
    end
  end

  def test_instant_equality
    a = Instant.now
    dur = Duration::from_nanos(1)
    assert_equal a, a
    assert_equal a.hash, a.dup.hash
    assert((a <=> a).zero?)
    assert(a < a + dur)
    assert(a > a - dur)
    refute_equal a, a + dur
  end

  def test_instant_elapsed
    a = Instant.now
    sleep 0.01
    elapsed = a.elapsed

    assert elapsed >= Duration.from_secs(0.01)
    assert elapsed <= Duration.from_secs(0.02)
  end

  def test_duration_equality
    a = Duration.from_secs(1)
    b = Duration.from_secs(2)
    assert_equal a, Duration.from_secs(1)
    assert_equal a.hash, Duration.from_secs(1).hash
    refute_equal a, b
    assert a < b
    assert b > a
  end

  def test_duration_maths
    one_sec = Duration.from_secs(1)
    two_secs = Duration.from_secs(2)
    three_secs = Duration.from_secs(3)

    assert_equal one_sec * 2, two_secs
    assert_equal two_secs / 2, one_sec
    assert_equal one_sec + two_secs, three_secs
    assert_equal two_secs - one_sec, one_sec
  end

  def test_sleeps
    ten_ms = Duration.from_millis(10)

    t = Instant.now
    a = t.sleep(ten_ms)

    # Sleeping slightly less than the requested period is perfectly legitimate.
    # Interlace another sleep test in the hope this is sufficient.
    assert_includes 5..50, Duration.measure { ten_ms.sleep }.to_millis

    b = t.sleep(ten_ms)

    assert_includes 5..50, a.to_millis
    assert a > b
    assert b.negative?
  end

  def test_duration_unary
    one_sec = Duration.from_secs(1)
    minus_one_sec = Duration.from_secs(-1)

    assert_equal one_sec, minus_one_sec.abs
    assert_equal one_sec.abs, minus_one_sec.abs
    assert_equal(-one_sec, minus_one_sec)
    assert_equal one_sec, -minus_one_sec
  end

  def test_instant_hashing
    inst0 = Instant.now
    inst1 = inst0 + Duration.from_nanos(1)
    inst2 = inst0 + Duration.from_secs(1)
    inst3 = inst0 + Duration.from_secs(10)

    hash = {inst0 => 0, inst1 => 1, inst2 => 2, inst3 => 3}

    assert_equal hash[inst0], 0
    assert_equal hash[inst1], 1
    assert_equal hash[inst2], 2
    assert_equal hash[inst3], 3

    assert_equal hash.keys.sort, [inst0, inst1, inst2, inst3]
  end

  def test_duration_hashing
    dur0 = Duration.new
    dur1 = Duration.from_nanos(1)
    dur2 = Duration.from_secs(1)
    dur3 = Duration.from_secs(10)

    hash = {dur0 => 0, dur1 => 1, dur2 => 2, dur3 => 3}

    assert_equal hash[dur0], 0
    assert_equal hash[dur1], 1
    assert_equal hash[dur2], 2
    assert_equal hash[dur3], 3

    assert_equal hash.keys.sort, [dur0, dur1, dur2, dur3]
  end

  def test_duration_format
    assert_equal '1s', Duration.from_secs(1).to_s
    assert_equal '1.5s', Duration.from_secs(1.5).to_s
    assert_equal '1.25s', Duration.from_secs(1.25).to_s
    assert_equal '1.2s', Duration.from_secs(1.25).to_s(1)
    assert_equal '1.3s', Duration.from_secs(1.26).to_s(1)
    assert_equal '2s', Duration.from_secs(1.6).to_s(0)

    assert_equal '1ms', Duration.from_millis(1).to_s
    assert_equal '1.5ms', Duration.from_millis(1.5).to_s
    assert_equal '1.25ms', Duration.from_millis(1.25).to_s
    assert_equal '1.2ms', Duration.from_millis(1.25).to_s(1)
    assert_equal '1.3ms', Duration.from_millis(1.26).to_s(1)
    assert_equal '2ms', Duration.from_millis(1.6).to_s(0)

    assert_equal '1μs', Duration.from_micros(1).to_s
    assert_equal '1.5μs', Duration.from_micros(1.5).to_s
    assert_equal '1.25μs', Duration.from_micros(1.25).to_s
    assert_equal '1.2μs', Duration.from_micros(1.25).to_s(1)
    assert_equal '1.3μs', Duration.from_micros(1.26).to_s(1)
    assert_equal '2μs', Duration.from_micros(1.6).to_s(0)

    assert_equal '1ns', Duration.from_nanos(1).to_s
  end

  def test_duration_format_zero_stripping
    # Zeros should not be stripped if precision = 0
    assert_equal '100s', Duration.from_secs(100).to_s(0)
    assert_equal '100ns', Duration.from_nanos(100).to_s
  end
end
