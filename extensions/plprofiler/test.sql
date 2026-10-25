CREATE EXTENSION plprofiler;

SELECT assert_true(pl_profiler_version() > 0, 'plprofiler: pl_profiler_version()');
