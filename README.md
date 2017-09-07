# `test-queue` SimpleCov Implementation

This repo is used to minimally reproduce the SimpleCov setup for https://github.com/tmm1/test-queue.
Relies on the branch from my fork https://github.com/nikhilmat/test-queue/tree/nm-simplecov-support.

### Setup
Clone the repo and `bundle install`.

### Running SimpleCov Formatter in `TestQueue::Runner::RSpec#summarize`
The typical `test-queue` setup would involve loading the code or application, and forking afterward to quickly spawn workers. In this case, the master process will load all the code and then fork for the workers to actually run the test (assuming SimpleCov is correctly configured and started first thing in the load process). This will lead to coverage that includes all the class definitions, method definitions, and other code that is executed at _require_ time. This can be reproduced in this repository with:
```bash
bundle exec ruby bin/test-queue-naive.rb test_spec.rb
```

This will yield coverage that looks like the following:
```bash
us-nmathew1:test-queue-coverage nikhil.mathew$ cat coverage/.resultset.json
{
  "RSpec": {
    "coverage": {
      "/Users/nikhil.mathew/workspace/test-queue-coverage/test.rb": [
        1,
        1,
        null,
        1,
        0,
        null,
        null
      ]
    },
    "timestamp": 1504742377
  }
}
```
Even though the test was executed, the forked process did not report (because of using `Kernel#exit!`) and thus we only have coverage on the required code.

### Ruby's Coverage module and `Kernel#fork`
As shown above, we need to be able to also report the coverage from each process as a separate SimpleCov profile. However, Ruby's native Coverage module makes the assumption that we want to throw away any coverage collected before the fork so we do not duplicate it (https://bugs.ruby-lang.org/issues/9508#note-22).
Thus, we need to report in _both_ `TestQueue::Runner::RSpec#cleanup_worker` and `TestQueue::Runner::RSpec#summarize`. This is implemented in the PR for https://github.com/nikhilmat/test-queue/tree/nm-simplecov-support. Because we will report both of these as different profiles, together they will give us a complete picture of the coverage, both before and after the fork.

This example can be reproduced in the repository with:
```bash
bundle exec ruby bin/test-queue-coverage.rb test_spec.rb
```

This will yield coverage that looks like:
```
us-nmathew1:test-queue-coverage nikhil.mathew$ cat coverage/.resultset.json
{
  "test-queue-worker-1": {
    "coverage": {
      "/Users/nikhil.mathew/workspace/test-queue-coverage/test.rb": [
        0,
        0,
        null,
        0,
        1,
        null,
        null
      ]
    },
    "timestamp": 1504742721
  },
  "test-queue-master": {
    "coverage": {
      "/Users/nikhil.mathew/workspace/test-queue-coverage/test.rb": [
        1,
        1,
        null,
        1,
        0,
        null,
        null
      ]
    },
    "timestamp": 1504742721
  }
}
```
Notice how the `test-queue-worker-1` queue does indeed cover the `Test#blah` method execution (which is only able to be captured by running the test), but has `0` has the value for all code that is executed when the file is required. This is due to how Ruby's `Coverage.result` value changes when you fork the process. As long as we also have the `test-queue-master` profile, we can combine them to report the full test coverage for a suite.
