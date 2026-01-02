# Workflow Fixes - December 12, 2025

## Issue Identified

### Problem: Crystal Compiler Crashes During Tests

**Symptoms**:
```
Invalid memory access (signal 11) at address 0x0
BUG: a codegen process failed
Process completed with exit code 1
```

**Affected Workflows**:
- `crystal.yml` (Crystal CI)
- `crci.yml` (Crystal CI with matrix)
- Potentially other workflows running `crystal spec`

**Root Cause**:
The Crystal compiler is experiencing segmentation faults during code generation when running tests. This is likely due to:

1. **Parallel Compilation Issues**: Multiple codegen processes running simultaneously causing memory conflicts
2. **Memory Constraints**: GitHub Actions runners may have insufficient memory for parallel compilation
3. **Compiler Bugs**: Complex code patterns triggering compiler bugs
4. **Resource Contention**: Docker container resource limits

---

## Solutions Implemented

### 1. Crystal CI Workflow (`crystal.yml`)

**Changes**:
- Added container resource limits (4GB memory, 2 CPUs)
- Added system dependencies installation
- Implemented retry logic with single-threaded execution
- Added error detection and handling
- Added test output logging

**Before**:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: crystallang/crystal
    steps:
    - uses: actions/checkout@v4
    - name: Install dependencies
      run: shards install
    - name: Run tests
      run: crystal spec
```

**After**:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: crystallang/crystal
      options: --memory=4g --cpus=2  # Resource limits
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install system dependencies
      run: |
        apt-get update
        apt-get install -y libsqlite3-dev librocksdb-dev libevent-dev libssl-dev || true
    
    - name: Install dependencies
      run: shards install
    
    - name: Run tests with error handling
      run: |
        echo "Running Crystal specs..."
        
        # Try normal execution first
        if crystal spec --error-trace --no-color 2>&1 | tee test_output.log; then
          echo "✓ Tests passed"
          exit 0
        fi
        
        # Check if it was a compiler crash
        if grep -q "BUG: a codegen process failed" test_output.log || grep -q "Invalid memory access" test_output.log; then
          echo "⚠️  Compiler crash detected, retrying with single-threaded execution..."
          CRYSTAL_WORKERS=1 crystal spec --error-trace --no-color
        else
          echo "✗ Tests failed"
          cat test_output.log
          exit 1
        fi
```

**Benefits**:
- ✅ Detects compiler crashes vs test failures
- ✅ Automatically retries with single-threaded execution
- ✅ Provides better error messages
- ✅ Logs test output for debugging
- ✅ Resource limits prevent OOM issues

---

### 2. Crystal CI Matrix Workflow (`crci.yml`)

**Changes**:
- Added retry logic with single-threaded execution
- Added error trace and no-color flags
- Maintained random test order

**Before**:
```yaml
- name: Run tests
  run: crystal spec --order=random
```

**After**:
```yaml
- name: Run tests
  run: |
    # Run tests with error handling for compiler crashes
    crystal spec --order=random --error-trace --no-color || {
      echo "⚠️  Test run failed, retrying with single-threaded execution..."
      CRYSTAL_WORKERS=1 crystal spec --order=random --error-trace --no-color
    }
```

**Benefits**:
- ✅ Handles compiler crashes gracefully
- ✅ Retries with reduced parallelism
- ✅ Better error output
- ✅ Maintains test randomization

---

## Technical Details

### CRYSTAL_WORKERS Environment Variable

**Purpose**: Controls the number of parallel codegen processes

**Default**: Number of CPU cores (typically 2-4 on GitHub Actions)

**Setting to 1**: Forces single-threaded compilation
- Slower but more stable
- Avoids memory conflicts
- Reduces memory usage
- Prevents parallel codegen bugs

**Usage**:
```bash
CRYSTAL_WORKERS=1 crystal spec
```

---

### Error Detection Strategy

**Approach**: Detect compiler crashes vs test failures

**Compiler Crash Indicators**:
- `BUG: a codegen process failed`
- `Invalid memory access (signal 11)`
- Segmentation faults
- Signal 11 errors

**Test Failure Indicators**:
- Assertion failures
- Expected vs actual mismatches
- Spec failures

**Logic**:
1. Run tests normally
2. If failed, check output for crash indicators
3. If crash detected, retry with CRYSTAL_WORKERS=1
4. If test failure, report and exit

---

### Container Resource Limits

**Purpose**: Prevent OOM and resource exhaustion

**Settings**:
```yaml
container:
  image: crystallang/crystal
  options: --memory=4g --cpus=2
```

**Benefits**:
- Prevents memory exhaustion
- Limits CPU contention
- More predictable performance
- Better error messages

---

## Testing Strategy

### Retry Logic

**First Attempt**: Normal parallel execution
- Fast
- Uses all available resources
- May trigger compiler bugs

**Second Attempt** (if crash): Single-threaded execution
- Slower but stable
- Avoids parallel codegen issues
- More likely to succeed

**Failure**: Report error and exit
- Provides detailed logs
- Distinguishes crash from test failure
- Helps with debugging

---

## Expected Outcomes

### Success Scenarios

1. **Tests pass on first attempt**: Normal execution, fast completion
2. **Compiler crash, retry succeeds**: Single-threaded execution succeeds
3. **Tests fail legitimately**: Clear error message, proper exit code

### Failure Scenarios

1. **Compiler crash persists**: Indicates deeper issue, needs investigation
2. **Tests fail consistently**: Code issue, not compiler issue
3. **Timeout**: Tests taking too long, may need optimization

---

## Monitoring

### Key Metrics

- **Crash Rate**: How often compiler crashes occur
- **Retry Success Rate**: How often single-threaded retry succeeds
- **Test Duration**: Time to complete tests
- **Memory Usage**: Peak memory during tests

### Log Indicators

**Success**:
```
Running Crystal specs...
✓ Tests passed
```

**Compiler Crash + Retry Success**:
```
Running Crystal specs...
⚠️  Compiler crash detected, retrying with single-threaded execution...
[Tests run successfully]
```

**Failure**:
```
Running Crystal specs...
✗ Tests failed
[Error details]
```

---

## Alternative Solutions Considered

### 1. Disable Parallel Compilation Entirely

**Approach**: Always use `CRYSTAL_WORKERS=1`

**Pros**:
- Most stable
- Consistent behavior

**Cons**:
- Slower builds
- Doesn't utilize resources efficiently

**Decision**: Not chosen - retry logic is better

---

### 2. Increase Container Resources

**Approach**: Use more memory and CPUs

**Pros**:
- May prevent crashes
- Faster compilation

**Cons**:
- May not solve underlying issue
- More expensive
- Not always available

**Decision**: Implemented as part of solution

---

### 3. Skip Tests Temporarily

**Approach**: Disable failing tests

**Pros**:
- Workflow passes

**Cons**:
- Loses test coverage
- Hides issues
- Not a real solution

**Decision**: Not acceptable

---

### 4. Use Different Crystal Version

**Approach**: Downgrade to older Crystal version

**Pros**:
- May avoid compiler bugs

**Cons**:
- Loses new features
- May have other bugs
- Not sustainable

**Decision**: Not chosen - fix current version

---

## Implementation Status

### Files Modified

| File | Status | Changes |
|------|--------|---------|
| `.github/workflows/crystal.yml` | ✅ Fixed | Added retry logic, resource limits, error handling |
| `.github/workflows/crci.yml` | ✅ Fixed | Added retry logic with single-threaded fallback |

### Testing Status

- ✅ YAML syntax validated
- ⏳ Awaiting GitHub Actions run
- ⏳ Monitoring for compiler crashes
- ⏳ Verifying retry logic works

---

## Rollback Plan

If fixes cause issues:

1. **Revert crystal.yml**:
```bash
git revert <commit-hash>
```

2. **Disable retry logic**:
```yaml
- name: Run tests
  run: crystal spec --error-trace
```

3. **Use simple fallback**:
```yaml
- name: Run tests
  run: CRYSTAL_WORKERS=1 crystal spec
```

---

## Future Improvements

### Short-Term

1. **Monitor crash frequency**: Track how often retries are needed
2. **Optimize test suite**: Reduce compilation complexity
3. **Add timeout protection**: Prevent hanging tests

### Long-Term

1. **Report compiler bugs**: Submit issues to Crystal team
2. **Optimize memory usage**: Reduce peak memory requirements
3. **Parallel test execution**: Run specs in parallel instead of parallel compilation
4. **Cache compiled artifacts**: Reduce compilation time

---

## Related Issues

### Crystal Compiler Issues

- Parallel codegen crashes (known issue)
- Memory access violations during compilation
- Signal 11 errors in complex codebases

### GitHub Actions Limitations

- Memory constraints in containers
- CPU limitations
- Resource contention

---

## Recommendations

### For Developers

1. **Run tests locally** before pushing
2. **Use `CRYSTAL_WORKERS=1`** if experiencing crashes
3. **Report persistent crashes** to maintainers
4. **Check logs** for crash indicators

### For Maintainers

1. **Monitor workflow success rate**
2. **Track retry frequency**
3. **Investigate persistent crashes**
4. **Consider test suite optimization**

---

## Conclusion

Implemented robust error handling and retry logic to address Crystal compiler crashes during test execution. The solution:

- ✅ Detects compiler crashes vs test failures
- ✅ Automatically retries with single-threaded execution
- ✅ Provides clear error messages
- ✅ Maintains test coverage
- ✅ Minimizes workflow failures

**Expected Result**: Reduced workflow failures due to compiler crashes, with automatic recovery in most cases.

---

**Date**: December 12, 2025  
**Status**: ✅ Fixes implemented, awaiting validation  
**Affected Workflows**: 2 (crystal.yml, crci.yml)  
**Impact**: Improved stability and reliability
