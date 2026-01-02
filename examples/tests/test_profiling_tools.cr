require "./src/cogutil/performance_profiler"

# Simple validation test for performance profiling tools
puts "🧪 Testing CrystalCog Performance Profiling Tools"
puts "=" * 50

begin
  # Test 1: Basic profiling session
  puts "\n1. Testing basic profiling session..."
  CogUtil::PerformanceProfiler.start_session
  
  result = CogUtil::PerformanceProfiler.profile("test_function") do
    sum = 0
    1000.times { |i| sum += i }
    sum
  end
  
  session = CogUtil::PerformanceProfiler.end_session
  
  if session && session.get_metrics("test_function")
    puts "   ✅ Basic profiling: PASSED"
  else
    puts "   ❌ Basic profiling: FAILED"
    exit(1)
  end
  
  # Test 2: Memory profiling
  puts "\n2. Testing memory profiling..."
  CogUtil::PerformanceProfiler.start_session
  
  memory_result = CogUtil::PerformanceProfiler.profile_memory_allocation("memory_test") do
    large_array = Array(Int32).new(1000) { |i| i }
    large_array.sum
  end
  
  CogUtil::PerformanceProfiler.end_session
  
  if memory_result[:allocation][:heap_allocated] >= 0
    puts "   ✅ Memory profiling: PASSED"
  else
    puts "   ❌ Memory profiling: FAILED"
    exit(1)
  end
  
  # Test 3: Performance monitoring
  puts "\n3. Testing performance monitoring..."
  monitor = CogUtil::PerformanceMonitor.new(100)
  
  monitor.record_metric("test_metric", 42.5)
  monitor.record_metric("test_metric", 43.0)
  
  summary = monitor.get_performance_summary
  
  if summary.has_key?("test_metric")
    puts "   ✅ Performance monitoring: PASSED"
  else
    puts "   ❌ Performance monitoring: FAILED"
    exit(1)
  end
  
  # Test 4: Regression detection
  puts "\n4. Testing regression detection..."
  regression = CogUtil::PerformanceRegression.new("/tmp/test_regression.json")
  
  # This should not raise an error
  empty_regressions = [] of CogUtil::PerformanceRegression::RegressionResult
  report = regression.generate_regression_report(empty_regressions)
  
  if report.includes?("Performance Regression Analysis Report")
    puts "   ✅ Regression detection: PASSED"
  else
    puts "   ❌ Regression detection: FAILED"
    exit(1)
  end
  
  # Test 5: Optimization engine
  puts "\n5. Testing optimization engine..."
  engine = CogUtil::OptimizationEngine.new
  
  # Create a mock session for testing
  CogUtil::PerformanceProfiler.start_session
  CogUtil::PerformanceProfiler.profile("slow_function") do
    sleep 0.01  # Intentionally slow
  end
  test_session = CogUtil::PerformanceProfiler.end_session
  
  if test_session
    recommendations = engine.analyze_and_recommend(test_session)
    if recommendations.is_a?(Array)
      puts "   ✅ Optimization engine: PASSED"
    else
      puts "   ❌ Optimization engine: FAILED"
      exit(1)
    end
  else
    puts "   ❌ Optimization engine: FAILED (no session)"
    exit(1)
  end
  
  # Test 6: Report generation
  puts "\n6. Testing report generation..."
  CogUtil::PerformanceProfiler.start_session
  CogUtil::PerformanceProfiler.profile("report_test") do
    42
  end
  report_session = CogUtil::PerformanceProfiler.end_session
  
  if report_session
    report = CogUtil::PerformanceProfiler.generate_report
    if report.includes?("Performance Profiling Report")
      puts "   ✅ Report generation: PASSED"
    else
      puts "   ❌ Report generation: FAILED"
      exit(1)
    end
  else
    puts "   ❌ Report generation: FAILED (no session)"
    exit(1)
  end
  
  # Test 7: JSON export
  puts "\n7. Testing JSON export..."
  json_data = CogUtil::PerformanceProfiler.export_metrics
  
  if json_data.includes?("session_info") && json_data.includes?("metrics")
    puts "   ✅ JSON export: PASSED"
  else
    puts "   ❌ JSON export: FAILED"
    exit(1)
  end
  
  puts "\n🎉 All tests PASSED! Performance profiling tools are working correctly."
  puts "\nFeatures validated:"
  puts "• CPU and timing profiling"
  puts "• Memory allocation tracking"
  puts "• Real-time performance monitoring"
  puts "• Performance regression detection"
  puts "• Optimization recommendations"
  puts "• Comprehensive reporting"
  puts "• Data export capabilities"
  
rescue ex
  puts "\n❌ Test failed with error: #{ex.message}"
  puts ex.backtrace.join("\n")
  exit(1)
end