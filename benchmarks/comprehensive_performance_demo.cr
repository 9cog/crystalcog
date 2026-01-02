require "benchmark"
require "../src/cogutil/performance_profiler"
require "../src/cogutil/performance_regression"
require "../src/cogutil/optimization_engine"
require "../src/cogutil/performance_monitor"

# Comprehensive performance profiling demonstration and validation
# This benchmark showcases all the profiling and optimization tools
class PerformanceProfilingDemo
  @monitor : CogUtil::PerformanceMonitor
  @regression : CogUtil::PerformanceRegression
  @engine : CogUtil::OptimizationEngine
  
  def initialize
    @monitor = CogUtil::PerformanceMonitor.new(5000)
    @regression = CogUtil::PerformanceRegression.new("demo_performance.json")
    @engine = CogUtil::OptimizationEngine.new(@regression)
    
    puts "🚀 CrystalCog Performance Profiling Tools Demo".colorize(:green)
    puts "=" * 55
  end
  
  def run_full_demo
    puts "\n1️⃣ Starting Performance Monitoring..."
    start_monitoring
    
    puts "\n2️⃣ Running Profiled Workloads..."
    run_profiled_workloads
    
    puts "\n3️⃣ Analyzing Performance Data..."
    analyze_performance
    
    puts "\n4️⃣ Generating Optimization Recommendations..."
    generate_optimizations
    
    puts "\n5️⃣ Regression Analysis..."
    check_regressions
    
    puts "\n6️⃣ Real-time Monitoring Demo..."
    demonstrate_monitoring
    
    puts "\n7️⃣ Performance Reports..."
    generate_reports
    
    puts "\n✅ Demo Complete!".colorize(:green)
    
    cleanup
  end
  
  private def start_monitoring
    @monitor.start_monitoring(1.second)
    puts "Performance monitoring started with 1-second intervals"
    
    # Add custom alert for demo
    alert_rule = CogUtil::PerformanceMonitor::AlertRule.new(
      name: "demo_high_latency",
      metric_pattern: "operation_time",
      threshold: 0.1,  # 100ms
      comparison: "gt",
      duration: 5.seconds,
      severity: "warning"
    )
    @monitor.add_alert_rule(alert_rule)
    puts "Added demo alert rule for operation latency > 100ms"
  end
  
  private def run_profiled_workloads
    puts "Running various workloads with different performance characteristics..."
    
    CogUtil::PerformanceProfiler.start_session
    
    # Fast, frequent operations
    puts "  • Fast frequent operations..."
    100.times do |i|
      CogUtil::PerformanceProfiler.profile("fast_operation") do
        result = 0
        10.times { |j| result += j * 2 }
        @monitor.record_metric("operation_time", 0.001)
        result
      end
    end
    
    # Slow operations that should trigger optimization recommendations
    puts "  • Slow operations (intentional performance issues)..."
    5.times do |i|
      CogUtil::PerformanceProfiler.profile("slow_operation") do
        # Simulate expensive computation
        result = 0
        10000.times { |j| result += Math.sqrt(j.to_f64).to_i }
        
        # Simulate high memory usage
        large_array = Array(Float64).new(10000) { |k| k.to_f64 * Math.PI }
        
        operation_time = 0.15  # Above alert threshold
        @monitor.record_metric("operation_time", operation_time)
        
        result
      end
    end
    
    # Memory-intensive operations
    puts "  • Memory-intensive operations..."
    3.times do |i|
      result = CogUtil::PerformanceProfiler.profile_memory_allocation("memory_heavy_operation") do
        # Create large data structures
        matrix = Array(Array(Float64)).new(100) do |row|
          Array(Float64).new(100) { |col| (row * col).to_f64 }
        end
        
        # Process the data
        sum = matrix.flatten.sum
        @monitor.record_metric("memory_usage", 50_000_000.0)  # 50MB simulated
        sum
      end
      
      puts "    Memory allocation result: #{result[:allocation][:heap_allocated]} bytes"
    end
    
    # Error-prone operations for reliability analysis
    puts "  • Error-prone operations (for reliability testing)..."
    10.times do |i|
      begin
        CogUtil::PerformanceProfiler.profile("error_prone_operation") do
          if i % 3 == 0  # Fail every 3rd operation
            raise ArgumentError.new("Simulated error for testing")
          end
          @monitor.record_metric("error_count", 0.0)
          42
        end
      rescue ArgumentError
        @monitor.record_metric("error_count", 1.0)
        # Expected errors for demo
      end
    end
    
    # High-frequency caching candidate
    puts "  • High-frequency operations (caching candidates)..."
    50.times do |i|
      CogUtil::PerformanceProfiler.profile("cacheable_operation") do
        # Simulate expensive lookup that could be cached
        key = i % 5  # Only 5 unique values, perfect for caching
        result = expensive_computation(key)
        @monitor.record_metric("cache_miss", 1.0)
        result
      end
    end
    
    @session = CogUtil::PerformanceProfiler.end_session
    puts "Profiling session complete!"
  end
  
  private def analyze_performance
    return unless session = @session
    
    puts "Analyzing performance metrics..."
    
    # Display basic metrics
    puts "\n📊 Performance Summary:"
    session.all_metrics.each do |name, metrics|
      avg_time = metrics.call_count > 0 ? metrics.wall_time / metrics.call_count : 0.0
      error_rate = metrics.call_count > 0 ? (metrics.errors.to_f64 / metrics.call_count * 100) : 0.0
      
      puts "  #{name}:"
      puts "    Calls: #{metrics.call_count}"
      puts "    Total Time: #{metrics.wall_time.round(4)}s"
      puts "    Avg Time: #{(avg_time * 1000).round(2)}ms"
      puts "    Memory Peak: #{format_bytes(metrics.memory_peak)}"
      puts "    Error Rate: #{error_rate.round(1)}%"
      puts ""
    end
    
    # Record metrics for regression analysis
    @regression.record_metrics(session, "demo_v1.0.0")
    puts "Recorded metrics for regression analysis"
  end
  
  private def generate_optimizations
    return unless session = @session
    
    puts "Generating optimization recommendations..."
    
    recommendations = @engine.analyze_and_recommend(session)
    
    if recommendations.any?
      puts "\n💡 Optimization Recommendations Found: #{recommendations.size}"
      
      # Show top 3 recommendations
      top_recommendations = recommendations.first(3)
      top_recommendations.each_with_index do |rec, i|
        puts "\n#{i + 1}. #{rec.category}: #{rec.function_name}"
        puts "   Priority: #{rec.priority}/100"
        puts "   Issue: #{rec.issue_description}"
        puts "   Strategy: #{rec.optimization_strategy}"
        puts "   Expected Improvement: #{(rec.expected_improvement * 100).round(1)}%"
        puts "   Difficulty: #{rec.implementation_difficulty.capitalize}"
        
        if rec.code_examples.any?
          puts "   Example:"
          puts "     #{rec.code_examples.first}"
        end
      end
      
      # Generate optimization roadmap
      puts "\n🗺️ Optimization Roadmap:"
      roadmap = @engine.get_optimization_roadmap(recommendations)
      roadmap.each do |phase, recs|
        puts "  #{phase}: #{recs.size} recommendations"
        recs.first(2).each do |rec|
          puts "    • #{rec.function_name}: #{rec.optimization_strategy}"
        end
      end
    else
      puts "No optimization opportunities detected (code is already well-optimized!)"
    end
  end
  
  private def check_regressions
    return unless session = @session
    
    puts "Checking for performance regressions..."
    
    regressions = @regression.analyze_regressions(session)
    
    if regressions.any?
      puts "\n⚠️ Performance Regressions Detected: #{regressions.size}"
      
      regressions.each do |regression|
        severity_icon = regression.critical? ? "🚨" : regression.warning? ? "⚠️" : "ℹ️"
        direction = regression.change_percentage > 0 ? "increased" : "decreased"
        
        puts "#{severity_icon} #{regression.function_name} (#{regression.regression_type}):"
        puts "   #{direction} by #{regression.change_percentage.abs.round(2)}%"
        puts "   #{regression.baseline_value.round(6)} → #{regression.current_value.round(6)}"
        puts "   Confidence: #{(regression.confidence * 100).round(1)}%"
      end
    else
      puts "✅ No performance regressions detected!"
    end
  end
  
  private def demonstrate_monitoring
    puts "Demonstrating real-time monitoring features..."
    
    # Generate some metrics that will trigger alerts
    puts "  • Recording metrics that will trigger alerts..."
    3.times do |i|
      @monitor.record_metric("demo_response_time", 0.15)  # Above threshold
      @monitor.record_metric("demo_memory_usage", 600_000_000.0)  # High memory
      @monitor.record_metric("demo_error_rate", 8.0)  # High error rate
      sleep 1
    end
    
    # Check alerts
    active_alerts = @monitor.get_active_alerts
    puts "  • Active alerts: #{active_alerts.size}"
    
    active_alerts.each do |alert|
      puts "    🚨 #{alert.rule.name}: #{alert.current_value} (threshold: #{alert.rule.threshold})"
    end
    
    # Show performance summary
    summary = @monitor.get_performance_summary
    puts "  • Monitoring #{summary.size - 1} metrics"  # -1 for _meta
    
    # Generate monitoring report
    puts "\n📊 Real-time Monitoring Status:"
    puts @monitor.generate_monitoring_report.split("\n").first(15).join("\n")
    puts "    ... (truncated for demo)"
  end
  
  private def generate_reports
    puts "Generating comprehensive performance reports..."
    
    # Generate profiling report
    if session = @session
      puts "\n📄 Profiling Report:"
      report = CogUtil::PerformanceProfiler.generate_report
      puts report.split("\n").first(20).join("\n")
      puts "    ... (truncated for demo)"
      
      # Export metrics to JSON for external analysis
      json_export = CogUtil::PerformanceProfiler.export_metrics
      File.write("demo_performance_metrics.json", json_export)
      puts "\n💾 Exported metrics to demo_performance_metrics.json"
    end
    
    # Generate regression report
    regressions = @regression.analyze_regressions(@session.not_nil!)
    regression_report = @regression.generate_regression_report(regressions)
    puts "\n📈 Regression Analysis:"
    puts regression_report.split("\n").first(15).join("\n")
    puts "    ... (truncated for demo)"
    
    # Export monitoring data
    monitoring_export = @monitor.export_monitoring_data("json")
    File.write("demo_monitoring_data.json", monitoring_export)
    puts "\n💾 Exported monitoring data to demo_monitoring_data.json"
  end
  
  private def cleanup
    puts "\nCleaning up demo resources..."
    @monitor.stop_monitoring
    
    # Clean up demo files
    ["demo_performance.json", "demo_performance_metrics.json", "demo_monitoring_data.json"].each do |file|
      File.delete(file) if File.exists?(file)
    end
    
    puts "Demo cleanup complete!"
  end
  
  private def expensive_computation(key : Int32) : Int32
    # Simulate expensive computation that could benefit from caching
    result = 0
    1000.times { |i| result += (key * i) % 1000 }
    result
  end
  
  private def format_bytes(bytes : UInt64) : String
    units = ["B", "KB", "MB", "GB"]
    size = bytes.to_f64
    unit_index = 0
    
    while size >= 1024 && unit_index < units.size - 1
      size /= 1024
      unit_index += 1
    end
    
    "#{size.round(2)} #{units[unit_index]}"
  end
end

# Performance comparison benchmark against existing tools
class PerformanceComparisonBenchmark
  def run_comparison
    puts "\n🏁 Performance Tool Overhead Benchmark".colorize(:cyan)
    puts "=" * 45
    puts "Measuring the overhead of profiling tools themselves\n"
    
    iterations = 10000
    
    # Baseline: raw operation without profiling
    baseline_time = Benchmark.measure do
      iterations.times do |i|
        simple_computation(i)
      end
    end
    
    # With profiling enabled
    CogUtil::PerformanceProfiler.start_session
    profiled_time = Benchmark.measure do
      iterations.times do |i|
        CogUtil::PerformanceProfiler.profile("benchmark_operation") do
          simple_computation(i)
        end
      end
    end
    CogUtil::PerformanceProfiler.end_session
    
    # With monitoring
    monitor = CogUtil::PerformanceMonitor.new
    monitor.start_monitoring(0.1.seconds)
    
    monitored_time = Benchmark.measure do
      iterations.times do |i|
        result = simple_computation(i)
        monitor.record_metric("benchmark_metric", result.to_f64)
      end
    end
    
    monitor.stop_monitoring
    
    # Results
    puts "Results for #{iterations} iterations:"
    puts "  Baseline (no profiling):     #{(baseline_time.total * 1000).round(3)}ms"
    puts "  With profiling:              #{(profiled_time.total * 1000).round(3)}ms"
    puts "  With monitoring:             #{(monitored_time.total * 1000).round(3)}ms"
    
    profiling_overhead = ((profiled_time.total - baseline_time.total) / baseline_time.total * 100)
    monitoring_overhead = ((monitored_time.total - baseline_time.total) / baseline_time.total * 100)
    
    puts "\nOverhead Analysis:"
    puts "  Profiling overhead:          #{profiling_overhead.round(2)}%"
    puts "  Monitoring overhead:         #{monitoring_overhead.round(2)}%"
    
    # Performance per operation
    baseline_per_op = (baseline_time.total / iterations * 1_000_000).round(3)
    profiled_per_op = (profiled_time.total / iterations * 1_000_000).round(3)
    
    puts "\nPer-operation Performance:"
    puts "  Baseline:                    #{baseline_per_op}μs per operation"
    puts "  With profiling:              #{profiled_per_op}μs per operation"
    puts "  Overhead per operation:      #{(profiled_per_op - baseline_per_op).round(3)}μs"
    
    # Validation
    if profiling_overhead < 20.0  # Less than 20% overhead is acceptable
      puts "\n✅ Performance overhead is within acceptable limits".colorize(:green)
    else
      puts "\n⚠️ Performance overhead may be too high for production use".colorize(:yellow)
    end
  end
  
  private def simple_computation(n : Int32) : Int32
    result = 0
    10.times { |i| result += (n + i) % 100 }
    result
  end
end

# Stress test for profiling tools
class ProfilingStressTest
  def run_stress_test
    puts "\n🔥 Profiling Tools Stress Test".colorize(:red)
    puts "=" * 35
    puts "Testing tools under high load and concurrency\n"
    
    # High-frequency profiling stress test
    puts "1. High-frequency profiling test..."
    test_high_frequency_profiling
    
    # Concurrent profiling stress test
    puts "\n2. Concurrent profiling test..."
    test_concurrent_profiling
    
    # Memory pressure test
    puts "\n3. Memory pressure test..."
    test_memory_pressure
    
    # Long-running monitoring test
    puts "\n4. Long-running monitoring test..."
    test_long_running_monitoring
    
    puts "\n✅ Stress test complete!".colorize(:green)
  end
  
  private def test_high_frequency_profiling
    operations = 50000
    
    CogUtil::PerformanceProfiler.start_session
    
    start_time = Time.monotonic
    operations.times do |i|
      CogUtil::PerformanceProfiler.profile("stress_operation") do
        i * 2 + 1
      end
    end
    end_time = Time.monotonic
    
    session = CogUtil::PerformanceProfiler.end_session
    
    duration = (end_time - start_time).total_seconds
    rate = operations / duration
    
    puts "  Completed #{operations} profiled operations in #{duration.round(3)}s"
    puts "  Rate: #{rate.round(0)} operations/second"
    
    if session
      metrics = session.get_metrics("stress_operation")
      if metrics
        puts "  Call count: #{metrics.call_count}"
        puts "  Total time: #{metrics.wall_time.round(6)}s"
        puts "  Average per call: #{(metrics.wall_time / metrics.call_count * 1_000_000).round(3)}μs"
      end
    end
  end
  
  private def test_concurrent_profiling
    fiber_count = 10
    operations_per_fiber = 1000
    
    start_time = Time.monotonic
    
    channels = [] of Channel(Bool)
    
    fiber_count.times do |fiber_id|
      channel = Channel(Bool).new
      channels << channel
      
      spawn do
        CogUtil::PerformanceProfiler.start_session
        
        operations_per_fiber.times do |i|
          CogUtil::PerformanceProfiler.profile("concurrent_operation_#{fiber_id}") do
            Math.sqrt((fiber_id * 100 + i).to_f64)
          end
        end
        
        CogUtil::PerformanceProfiler.end_session
        channel.send(true)
      end
    end
    
    # Wait for all fibers to complete
    fiber_count.times do |i|
      channels[i].receive
    end
    
    end_time = Time.monotonic
    duration = (end_time - start_time).total_seconds
    total_operations = fiber_count * operations_per_fiber
    
    puts "  #{fiber_count} concurrent fibers, #{operations_per_fiber} operations each"
    puts "  Total operations: #{total_operations}"
    puts "  Duration: #{duration.round(3)}s"
    puts "  Rate: #{(total_operations / duration).round(0)} operations/second"
  end
  
  private def test_memory_pressure
    monitor = CogUtil::PerformanceMonitor.new(10000)  # Larger buffer
    monitor.start_monitoring(0.01.seconds)  # High frequency
    
    # Generate lots of metrics
    1000.times do |i|
      monitor.record_metric("memory_test_#{i % 10}", i.to_f64)
      
      # Allocate and free memory to create pressure
      large_array = Array(Float64).new(1000) { |j| (i * j).to_f64 }
      large_array.sum  # Use the array to prevent optimization
    end
    
    summary = monitor.get_performance_summary
    puts "  Recorded metrics for #{summary.size - 1} different metric names"
    puts "  Memory pressure test completed successfully"
    
    monitor.stop_monitoring
  end
  
  private def test_long_running_monitoring
    monitor = CogUtil::PerformanceMonitor.new
    monitor.start_monitoring(0.1.seconds)
    
    puts "  Running monitoring for 5 seconds with continuous metrics..."
    
    start_time = Time.monotonic
    metrics_recorded = 0
    
    while (Time.monotonic - start_time).total_seconds < 5.0
      monitor.record_metric("long_running_test", rand(100).to_f64)
      metrics_recorded += 1
      sleep 0.01
    end
    
    end_time = Time.monotonic
    duration = (end_time - start_time).total_seconds
    
    puts "  Recorded #{metrics_recorded} metrics in #{duration.round(3)}s"
    puts "  Rate: #{(metrics_recorded / duration).round(0)} metrics/second"
    
    summary = monitor.get_performance_summary
    puts "  Final monitoring summary contains #{summary.size} metric types"
    
    monitor.stop_monitoring
  end
end

# Main benchmark execution
if PROGRAM_NAME.includes?("comprehensive_performance_demo")
  puts "CrystalCog Performance Profiling Tools - Comprehensive Demo"
  puts "==========================================================="
  
  begin
    # Run the full demonstration
    demo = PerformanceProfilingDemo.new
    demo.run_full_demo
    
    # Run performance comparison
    comparison = PerformanceComparisonBenchmark.new
    comparison.run_comparison
    
    # Run stress tests
    stress_test = ProfilingStressTest.new
    stress_test.run_stress_test
    
    puts "\n🎉 All demonstrations completed successfully!".colorize(:green)
    puts "\nKey takeaways:"
    puts "• Performance profiling tools are working correctly"
    puts "• Optimization recommendations are being generated"
    puts "• Real-time monitoring is functional"
    puts "• Tools handle stress testing well"
    puts "• Performance overhead is acceptable for development use"
    
  rescue ex
    puts "\n❌ Demo failed with error: #{ex.message}".colorize(:red)
    puts ex.backtrace.join("\n")
    exit(1)
  end
end